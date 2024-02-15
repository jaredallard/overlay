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

package steps

import (
	"archive/tar"
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"os/exec"
)

// EbuildStep is a step that reads an ebuild from the filesystem.
type EbuildStep struct {
	// path is the path to the ebuild.
	path string
}

// NewEbuildStep creates a new NewEbuildStep from the provided input.
func NewEbuildStep(input any) (StepRunner, error) {
	path, ok := input.(string)
	if !ok {
		return nil, fmt.Errorf("expected string, got %T", input)
	}

	return &EbuildStep{path}, nil
}

// Run runs the provided command inside of the step runner.
func (e EbuildStep) Run(ctx context.Context, env Environment) (*StepOutput, error) {
	cmd := exec.CommandContext(ctx, "docker", "cp", fmt.Sprintf("%s:%s", env.containerID, e.path), "-")
	b, err := cmd.Output()
	if err != nil {
		var exitErr *exec.ExitError
		if errors.As(err, &exitErr) {
			return nil, fmt.Errorf("failed to copy ebuild from container: %s", string(exitErr.Stderr))
		}

		return nil, fmt.Errorf("failed to copy ebuild from container: %w", err)
	}

	t := tar.NewReader(bytes.NewReader(b))
	_, err = t.Next()
	if err != nil {
		return nil, fmt.Errorf("failed to read tar: %w", err)
	}

	b, err = io.ReadAll(t)
	if err != nil {
		return nil, fmt.Errorf("failed to read tar: %w", err)
	}

	return &StepOutput{Contents: string(b)}, nil
}
