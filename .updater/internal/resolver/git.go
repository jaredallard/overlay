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
	"strings"

	"github.com/jaredallard/overlay/.updater/internal/config"
)

// getGitVersion returns the latest version available from a git
// repository.
func getGitVersion(ce *config.Ebuild) (string, error) {
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
	var newVersion string
	scanner := bufio.NewScanner(bytes.NewReader(b))
	for scanner.Scan() {
		line := scanner.Text()
		if len(line) == 0 {
			continue
		}

		spl := strings.Split(line, "\t")
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
		newVersion = tag
		break
	}
	if newVersion == "" {
		return "", fmt.Errorf("failed to determine currently available versions")
	}

	return strings.TrimPrefix(newVersion, "v"), nil
}
