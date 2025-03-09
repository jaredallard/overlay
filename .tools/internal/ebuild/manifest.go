// Copyright (C) 2023 Jared Allard <jared@rgst.io>
// Copyright (C) 2023 Outreach <https://outreach.io>
//
// This program is free software: you can redistribute it and/or
// modify it under the terms of the GNU General Public License version
// 2 as published by the Free Software Foundation.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

package ebuild

import (
	"context"
	_ "embed"
	"fmt"
	"io"
	"io/fs"
	"os/exec"
	"path"
	"path/filepath"
	"strings"

	"github.com/jaredallard/overlay/.tools/internal/steps/stepshelpers"
	"github.com/pkg/errors"
)

// manifestValidationScript contains the script used to validate
// Manifest files.
//
//go:embed embed/verify-manifest.sh
var manifestValidationScript []byte

// gentooImage is the docker image used for validating Manifest files.
var gentooImage = "ghcr.io/jaredallard/overlay:updater"

// Common errors.
var (
	// ErrManifestInvalid is returned when the manifest is out of date or
	// otherwise invalid in a semi-expected way.
	ErrManifestInvalid = errors.New("manifest is out of date or invalid")
)

// copyDirectoryIntoContainer copies all files in the srcPath/ into
// destPath/ in the container.
func copyDirectoryIntoContainer(ctx context.Context, containerID, srcPath, destPath string) error {
	directories := make(map[string]struct{})

	if err := filepath.WalkDir(srcPath, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// We skip directories.
		if d.IsDir() {
			return nil
		}

		relPath, err := filepath.Rel(srcPath, path)
		if err != nil {
			return fmt.Errorf("could not create relative path for %q: %w", path, err)
		}

		dir := filepath.Dir(relPath)
		if _, ok := directories[dir]; !ok {
			if err := stepshelpers.RunCommandInContainer(ctx, containerID, "mkdir", "-p", filepath.Join(destPath, dir)); err != nil {
				return fmt.Errorf("failed to ensure directory %q: %w", dir, err)
			}
			directories[dir] = struct{}{}
		}

		if err := stepshelpers.CopyFileToContainer(ctx, containerID, filepath.Join(srcPath, relPath), filepath.Join(destPath, relPath)); err != nil {
			return fmt.Errorf("failed to copy %q into container: %w", relPath, err)
		}

		return nil
	}); err != nil {
		return fmt.Errorf("failed to walk srcDir: %w", err)
	}

	return nil
}

// ValidateManifest ensures that the manifest at the provided path is
// valid for the given ebuild. This requires docker to be installed on
// the host and running.
func ValidateManifest(stdout, stderr io.Writer, overlayDir, packageName string) error {
	ctx := context.TODO()

	bid, err := exec.Command(
		"docker", "run", "-d", "--rm", "--entrypoint", "sleep", gentooImage, "infinity",
	).Output()
	if err != nil {
		var execErr *exec.ExitError
		if errors.As(err, &execErr) {
			return fmt.Errorf("failed to run container: %s", string(execErr.Stderr))
		}

		return fmt.Errorf("failed to run container: %w", err)
	}
	containerID := strings.TrimSpace(string(bid))
	defer exec.Command("docker", "stop", containerID) //nolint:errcheck // Why: best effort

	lclPkgDir := filepath.Join(overlayDir, packageName)

	containerOverlayDir := "/ebuild/src"
	containerPkgDir := path.Join(containerOverlayDir, packageName)

	if err := copyDirectoryIntoContainer(ctx, containerID, lclPkgDir, containerPkgDir); err != nil {
		return fmt.Errorf("failed to copy ebuild contents into container: %w", err)
	}

	if err := copyDirectoryIntoContainer(ctx, containerID, filepath.Join(overlayDir, "metadata"), "/ebuild/src/metadata"); err != nil {
		return fmt.Errorf("failed to copy metadata directory into container: %w", err)
	}

	if err := stepshelpers.CopyFileBytesToContainer(ctx, containerID, manifestValidationScript, "/verify-manifest.sh"); err != nil {
		return fmt.Errorf("failed to copy validation script into container: %w", err)
	}

	if err := stepshelpers.RunCommandInContainer(ctx, containerID, "chmod", "+x", "/verify-manifest.sh"); err != nil {
		return fmt.Errorf("failed to mark validation script as executable: %w", err)
	}

	if err := stepshelpers.RunCommandInContainer(ctx, containerID, "/verify-manifest.sh", packageName); err != nil {
		return fmt.Errorf("ebuild failed to lint: %w", err)
	}

	return nil
}
