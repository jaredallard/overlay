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

	return nil, stepshelpers.CopyFileBytesToContainer(ctx, env.containerID, env.in.OriginalEbuild.Raw, outputPath)
}
