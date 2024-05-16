// Copyright (C) 2024 Jared Allard
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Package apt implements a slim APT repository parser for the purposes
// of getting the version of a package in a given repository.
package apt

import (
	"compress/gzip"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/blang/semver/v4"
	logger "github.com/charmbracelet/log"
	"github.com/jamespfennell/xz"

	"pault.ag/go/debian/control"
)

// log is the logger for this package.
var log = logger.NewWithOptions(os.Stderr, logger.Options{
	ReportCaller:    true,
	ReportTimestamp: true,
	Level:           logger.DebugLevel,
})

// Repository is a parsed version of a sources.list entry.
type Repository struct {
	// URL is the URL of the repository.
	URL string

	// Distribution is the distribution of the repository.
	Distribution string

	// Components are the components of the repository to search.
	Components []string
}

// Lookup are options for looking up a package. All options are required.
type Lookup struct {
	// SourcesEntry is the sources.list entry to use to look up the package.
	SourcesEntry string

	// Package is the package to look up.
	Package string

	// Architecture is the architecture to look up.
	// Defaults to "amd64".
	Architecture string
}

// GetPackageVersion returns the version of the package in the given
// repository.
func GetPackageVersion(l Lookup) (string, error) {
	// Default to AMD64 if not set.
	if l.Architecture == "" {
		l.Architecture = "amd64"
	}

	r, err := getRepositoryFromSourcesEntry(l.SourcesEntry)
	if err != nil {
		return "", fmt.Errorf("failed to get repository from sources entry: %w", err)
	}

	rel, err := parseRelease(r, l)
	if err != nil {
		return "", fmt.Errorf("failed to parse release: %w", err)
	}

	// Fine the packages entry in the indexes.
	//
	// TODO(jaredallard): This will only search the first component.
	// Rewrite to search each component later.
	var i *index
	for _, index := range rel.Indexes {
		for _, comp := range rel.Components {
			if strings.HasPrefix(index.Path, fmt.Sprintf("%s/binary-%s/Packages", comp, l.Architecture)) {
				i = &index
				break
			}
		}
	}
	if i == nil {
		return "", fmt.Errorf("failed to find Packages index")
	}

	// Find the package in the index.
	packages, err := parsePackages(i)
	if err != nil {
		return "", fmt.Errorf("failed to parse packages: %w", err)
	}

	var latestVersion *semver.Version
	for _, p := range packages {
		if p.Name != l.Package {
			continue
		}

		plog := log.With("package", p.Name, "version", p.Version)
		plog.Debug("found package")

		sv, err := semver.ParseTolerant(p.Version)
		if err != nil {
			plog.With("error", err).Warn("failed to parse version, skipping")
			// Can't compare it, skip it.
			continue
		}

		// Start w/ this version if it's the first one.
		if latestVersion == nil {
			latestVersion = &sv
			continue
		}

		// If this version is greater than the latest, update it.
		if sv.GT(*latestVersion) {
			latestVersion = &sv
		}
	}

	if latestVersion == nil {
		return "", fmt.Errorf("failed to find package: %s", l.Package)
	}

	return latestVersion.String(), nil
}

// getRepositoryFromSourcesEntry returns a repository from a sources
// list entry.
func getRepositoryFromSourcesEntry(entry string) (*Repository, error) {
	// ensure we're dealing with a deb entry
	if !strings.HasPrefix(entry, "deb ") {
		return nil, fmt.Errorf("invalid sources.list entry (missing deb prefix): %s", entry)
	}

	// remove the deb prefix
	entry = strings.TrimPrefix(entry, "deb ")

	// split the entry into parts
	parts := strings.Fields(entry)

	// ensure we have at least 2 parts
	if len(parts) < 2 {
		return nil, fmt.Errorf("invalid sources.list entry: %s", entry)
	}

	// create the repository
	return &Repository{
		URL:          parts[0],
		Distribution: parts[1],
		Components:   parts[2:],
	}, nil
}

// parseRelease parses the Release file for the given repository.
func parseRelease(r *Repository, _ Lookup) (*release, error) {
	// TODO(jaredallard): InRelease?
	releaseURL := fmt.Sprintf("%s/dists/%s/Release", r.URL, r.Distribution)

	req, err := http.NewRequest("GET", releaseURL, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to get release: %w", err)
	}
	defer resp.Body.Close()

	// TODO(jaredallard): GPG key support?
	pr, err := control.NewParagraphReader(resp.Body, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to parse release: %w", err)
	}

	// Read only one paragraph, because the release should only have one.
	p, err := pr.Next()
	if err != nil {
		return nil, fmt.Errorf("failed to read release: %w", err)
	}

	rel := release{
		Suite:         p.Values["Suite"],
		Codename:      p.Values["Codename"],
		Architectures: strings.Fields(p.Values["Architectures"]),
		Components:    strings.Fields(p.Values["Components"]),
		Description:   p.Values["Description"],
	}

	// Parse the indexes.
	indexes := make(map[string]*index)

	for _, hashName := range []string{"SHA512", "SHA256", "SHA1", "MD5Sum"} {
		if _, ok := p.Values[hashName]; !ok {
			continue
		}

		for _, v := range strings.Split(p.Values[hashName], "\n") {
			if v == "" {
				continue
			}

			// Split the line into parts.
			parts := strings.Fields(v)
			if len(parts) < 3 {
				return nil, fmt.Errorf("invalid hash line: %s", v)
			}

			path := parts[2]

			if _, ok := indexes[path]; !ok {
				size, err := strconv.Atoi(parts[1])
				if err != nil {
					return nil, fmt.Errorf("failed to parse size: %w", err)
				}

				indexes[path] = &index{
					URL:  fmt.Sprintf("%s/dists/%s/%s", r.URL, r.Distribution, path),
					Path: path,
					Size: int64(size),
				}
			}

			indexes[path].Hashes = append(indexes[path].Hashes, &hash{
				algo:  strings.TrimSuffix(strings.ToLower(hashName), "sum"),
				value: parts[0],
			})
		}
	}

	for _, v := range indexes {
		rel.Indexes = append(rel.Indexes, *v)
	}

	return &rel, nil
}

// parsePackages parses the Packages file for the given index.
func parsePackages(p *index) ([]Package, error) {
	// Fetch the index.
	req, err := http.NewRequest("GET", p.URL, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to get index: %w", err)
	}
	defer resp.Body.Close()

	r := resp.Body
	switch filepath.Ext(p.Path) {
	case ".gz":
		r, err = gzip.NewReader(r)
		if err != nil {
			return nil, fmt.Errorf("failed to create gzip reader: %w", err)
		}

	case ".xz":
		r = xz.NewReader(r)
	case "":
		// We don't need to handle compression if there is none.
		break

	default:
		return nil, fmt.Errorf("unsupported extension for index: %s", filepath.Ext(p.Path))
	}

	// Parse the index.
	pr, err := control.NewParagraphReader(r, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to parse index: %w", err)
	}

	// Read all paragraphs.
	var packages []Package
	for {
		p, err := pr.Next()
		if err != nil {
			if errors.Is(err, io.EOF) {
				break
			}

			return nil, fmt.Errorf("failed to read index: %w", err)
		}

		size, err := strconv.Atoi(p.Values["Size"])
		if err != nil {
			return nil, fmt.Errorf("failed to parse size: %w", err)
		}

		// TODO(jaredallard): Hashes

		// Parse the package.
		packages = append(packages, Package{
			Name:         p.Values["Package"],
			Maintainer:   p.Values["Maintainer"],
			Architecture: p.Values["Architecture"],
			Version:      p.Values["Version"],
			Filename:     p.Values["Filename"],
			Size:         int64(size),
			Description:  p.Values["Description"],
			Homepage:     p.Values["Homepage"],
			Vendor:       p.Values["Vendor"],
		})
	}

	return packages, nil
}
