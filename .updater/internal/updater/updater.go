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
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"

	"github.com/davecgh/go-spew/spew"
	"github.com/jaredallard/overlay/.updater/internal/config"
)

type Update struct {
	// NewVersion is the new version available.
	NewVersion string
}

func CheckForUpdate(ebuild *config.Ebuild) (*Update, error) {
	if ebuild.Backend != config.GitBackend {
		return nil, fmt.Errorf("currently only the 'git' backend is supported")
	}

	ebuildDir := ebuild.Name
	if _, err := os.Stat(ebuildDir); os.IsNotExist(err) {
		return nil, fmt.Errorf("ebuild directory does not exist: %s", ebuildDir)
	}

	// Find the newest ebuild version based on the filename.
	files, err := os.ReadDir(ebuildDir)
	if err != nil {
		return nil, fmt.Errorf("failed to read ebuild directory: %w", err)
	}

	sort.Slice(files, func(i, j int) bool {
		return files[i].Name() > files[j].Name()
	})

	// Find the first ebuild file.
	var ebuildFile string
	for _, file := range files {
		if filepath.Ext(file.Name()) == ".ebuild" {
			ebuildFile = file.Name()
		}
	}
	if ebuildFile == "" {
		return nil, fmt.Errorf("no ebuild files found in directory: %s", ebuildDir)
	}

	fmt.Println(ebuildFile)

	return getGitUpdate(ebuild)
}

func getGitUpdate(ebuild *config.Ebuild) (*Update, error) {
	dir, err := os.MkdirTemp("", "updater")
	if err != nil {
		return nil, fmt.Errorf("failed to create temporary directory: %w", err)
	}
	defer os.RemoveAll(dir)

	spew.Dump(ebuild)

	cmd := exec.Command("git", "ls-remote", "--tags", ebuild.GitOptions.URL)
	cmd.Dir = dir
	b, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Fprintf(os.Stderr, "git ls-remote output: %s\n", b)
		return nil, fmt.Errorf("failed to run git ls-remote: %w", err)
	}

	return nil, nil
}
