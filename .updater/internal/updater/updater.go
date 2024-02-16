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

// Package updater contains the main code for determining if an update
// is available for the given ebuild.
package updater

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/jaredallard/overlay/.updater/internal/config"
	"github.com/jaredallard/overlay/.updater/internal/ebuild"
)

type Update struct {
	// NewVersion is the new version available.
	NewVersion string

	// CurrentVersion is the current version available in the ebuild.
	CurrentVersion string
}

// CheckForUpdate returns an Update if an update is available for the given ebuild.
func CheckForUpdate(ce *config.Ebuild) (*Update, error) {
	if ce.Backend != config.GitBackend {
		return nil, fmt.Errorf("currently only the 'git' backend is supported")
	}

	ebuildDir := ce.Name
	if _, err := os.Stat(ebuildDir); os.IsNotExist(err) {
		return nil, fmt.Errorf("ebuild directory does not exist: %s", ebuildDir)
	}

	ebuilds, err := ebuild.ParseDir(ebuildDir)
	if err != nil {
		return nil, fmt.Errorf("failed to parse ebuilds: %w", err)
	}

	upd, err := getGitUpdate(ce)
	if err != nil {
		return nil, fmt.Errorf("failed to get git update: %w", err)
	}

	// HACK: Need to handle latest version.
	// Use the first ebuild as the current version.
	if len(ebuilds) > 0 {
		upd.CurrentVersion = ebuilds[0].Version
	}

	return upd, nil
}

// getGitUpdate returns an Update if an update is available for the given ebuild.
func getGitUpdate(ce *config.Ebuild) (*Update, error) {
	dir, err := os.MkdirTemp("", "updater")
	if err != nil {
		return nil, fmt.Errorf("failed to create temporary directory: %w", err)
	}
	defer os.RemoveAll(dir)

	cmd := exec.Command("git", "-c", "versionsort.suffix=-", "ls-remote", "--tags", "--sort=-v:refname", ce.GitOptions.URL)
	cmd.Dir = dir
	b, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Fprintf(os.Stderr, "git ls-remote output: %s\n", b)
		return nil, fmt.Errorf("failed to run git ls-remote: %w", err)
	}

	// Find the first tag that is not an annotated tag.
	var newVersion string
	scanner := bufio.NewScanner(bytes.NewReader(b))
	for scanner.Scan() {
		line := scanner.Text()
		if len(line) == 0 {
			continue
		}

		spl := strings.Split(line, "\t")
		if len(spl) != 2 {
			return nil, fmt.Errorf("unexpected output from git ls-remote: %s", line)
		}

		fqTag := spl[1]

		// Annotated tags are in the format "refs/tags/v1.2.3^{}".
		if strings.HasSuffix(fqTag, "^{}") {
			continue
		}

		// Strip the "refs/tags/" prefix.
		tag := strings.TrimPrefix(fqTag, "refs/tags/")
		newVersion = tag
		break
	}
	if newVersion == "" {
		return nil, fmt.Errorf("failed to determine currently available versions")
	}

	return &Update{NewVersion: strings.TrimPrefix(newVersion, "v")}, nil
}
