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

package ebuild

import (
	_ "embed"
	"errors"
	"fmt"
	"io"
	"os/exec"
)

// manifestValidationScript contains the script used to validate
// Manifest files.
//
//go:embed embed/verify-manifest.sh
var manifestValidationScript string

// gentooImage is the docker image used for validating Manifest files.
var gentooImage = "ghcr.io/jaredallard/overlay:updater"

// Common errors.
var (
	// ErrManifestInvalid is returned when the manifest is out of date or
	// otherwise invalid in a semi-expected way.
	ErrManifestInvalid = errors.New("manifest is out of date or invalid")
)

// ValidateManifest ensures that the manifest at the provided path is
// valid for the given ebuild. This requires docker to be installed on
// the host and running.
func ValidateManifest(stdout, stderr io.Writer, packageDir, packageName string) error {
	cmd := exec.Command(
		"docker", "run",
		// Ensures we can use the network-sandbox feature.
		"--privileged",
		// Run bash and mount the ebuild repository at a predictable path.
		"--rm", "--entrypoint", "bash", "-v"+packageDir+":/ebuild/src:ro",
		gentooImage, "-c", manifestValidationScript, "", packageName,
	)
	cmd.Stdout = stdout
	cmd.Stderr = stderr
	if err := cmd.Run(); err != nil {
		var exitErr *exec.ExitError
		if errors.As(err, &exitErr) {
			if exitErr.ExitCode() == 2 {
				return ErrManifestInvalid
			}
		}

		return fmt.Errorf("unknown error while validating manifest: %w", err)
	}

	return nil
}
