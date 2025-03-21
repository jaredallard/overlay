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

package updater

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"slices"
	"strings"

	"github.com/blang/semver/v4"
	"github.com/jaredallard/overlay/.tools/internal/config/packages"
)

// getGitVersion returns the latest version available from a git
// repository.
func getGitVersion(ce *packages.Package) (string, error) {
	dir, err := os.MkdirTemp("", "updater")
	if err != nil {
		return "", fmt.Errorf("failed to create temporary directory: %w", err)
	}
	defer os.RemoveAll(dir)

	cmd := exec.Command("git", "-c", "versionsort.suffix=-", "ls-remote", "--tags", "--sort=-v:refname", ce.GitOptions.URL)
	cmd.Dir = dir
	b, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Fprintf(os.Stderr, "git ls-remote output: %s\n", b)
		return "", fmt.Errorf("failed to run git ls-remote: %w", err)
	}

	// Find the first tag that is not an annotated tag.
	var newestVersion string
	var newestSemverVersion *semver.Version
	scanner := bufio.NewScanner(bytes.NewReader(b))
	for scanner.Scan() {
		line := scanner.Text()
		if len(line) == 0 {
			continue
		}

		spl := strings.Fields(line)
		if len(spl) != 2 {
			return "", fmt.Errorf("unexpected output from git ls-remote: %s", line)
		}

		fqTag := spl[1]

		// Annotated tags are in the format "refs/tags/v1.2.3^{}".
		if strings.HasSuffix(fqTag, "^{}") {
			continue
		}

		// Strip the "refs/tags/" prefix.
		tag := strings.TrimPrefix(fqTag, "refs/tags/")

		// Ignore the version if told to do so.
		if slices.Contains(ce.GitOptions.IgnoreVersions, tag) {
			continue
		}

		// Attempt to parse as a semver, for other options.
		if sv, err := semver.ParseTolerant(tag); err == nil {
			isPreRelease := len(sv.Pre) > 0
			if isPreRelease && !ce.GitOptions.ConsiderPreReleases {
				// Skip the version if we're not considering pre-releases.
				continue
			}

			if newestSemverVersion == nil || sv.GT(*newestSemverVersion) {
				newestSemverVersion = &sv
				newestVersion = tag
			}
		}

		// Not told to use semver, break once we've found a version because
		// we rely on git sorting.
		if ce.GitOptions.DisableSemver {
			newestVersion = tag
			break
		}
	}

	// If we were told to use semver, and we found a semver version, use it.
	if !ce.GitOptions.DisableSemver && newestSemverVersion != nil {
		newestVersion = newestSemverVersion.String()
	}

	if newestVersion == "" {
		return "", fmt.Errorf("failed to determine currently available versions")
	}

	return strings.TrimPrefix(newestVersion, "v"), nil
}
