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
	"context"
	"fmt"
	"path/filepath"

	"github.com/jaredallard/overlay/.tools/internal/steps/stepshelpers"
)

// OriginalEbuildStep is a step that writes the source ebuild into the
// filesystem of the container at the provided path.
//
// Also populates the existing ebuilds directory for usage later.
type OriginalEbuildStep struct {
	// path is the path to write the ebuild to in the container.
	path string
}

// NewOriginalEbuildStep creates a new OriginalEbuildStep from the provided input.
func NewOriginalEbuildStep(input any) (StepRunner, error) {
	path, ok := input.(string)
	if !ok {
		return nil, fmt.Errorf("expected string, got %T", input)
	}

	return &OriginalEbuildStep{path}, nil
}

// Run runs the provided command inside of the step runner.
func (e OriginalEbuildStep) Run(ctx context.Context, env Environment) (*StepOutput, error) {
	outputPath := e.path
	if !filepath.IsAbs(outputPath) {
		outputPath = filepath.Join(env.workDir, e.path)
	}

	if err := stepshelpers.CopyFileBytesToContainer(ctx, env.containerID, env.in.OriginalEbuild.Raw, outputPath); err != nil {
		return nil, fmt.Errorf("failed to copy ebuild to container: %w", err)
	}

	// Best effort create the existing ebuilds directory.
	stepshelpers.RunCommandInContainer(ctx, env.containerID, nil, "mkdir", "-p", WellKnownExistingEbuilds)

	for _, e := range env.in.ExistingEbuilds {
		env.log.With("ebuild", e.RawName).Debug("copying existing ebuild to container")
		if err := stepshelpers.CopyFileBytesToContainer(ctx, env.containerID, e.Raw, filepath.Join(WellKnownExistingEbuilds, e.RawName)); err != nil {
			return nil, fmt.Errorf("failed to copy existing ebuild to container: %w", err)
		}
	}

	return &StepOutput{}, nil
}
