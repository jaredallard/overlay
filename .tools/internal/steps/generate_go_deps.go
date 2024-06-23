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
	_ "embed"
	"fmt"

	"github.com/jaredallard/overlay/.tools/internal/steps/stepshelpers"
)

//go:embed embed/generate-go-deps.sh
var generateGoDepsScript []byte

// GenerateGoDepsStep generates a go dependency archive in the container
// at deps.tar.xz.
type GenerateGoDepsStep struct {
	mode string // "slim" or "full", defaults to "slim"
}

// NewGenerateGoDepsStep creates a new GenerateGoDepsStep from the
// provided input.
func NewGenerateGoDepsStep(input any) (StepRunner, error) {
	mode, ok := input.(string)
	if !ok && input != nil {
		return nil, fmt.Errorf("expected string, got %T", input)
	}

	if mode == "" {
		mode = "slim"
	}

	return &GenerateGoDepsStep{mode}, nil
}

// Run runs the provided command inside of the step runner.
func (e GenerateGoDepsStep) Run(ctx context.Context, env Environment) (*StepOutput, error) {
	if err := stepshelpers.CopyFileBytesToContainer(ctx, env.containerID, generateGoDepsScript, "/tmp/command.sh"); err != nil {
		return nil, fmt.Errorf("failed to create shell script in container: %w", err)
	}

	if err := stepshelpers.RunCommandInContainer(ctx, env.containerID,
		"bash", "/tmp/command.sh", e.mode,
	); err != nil {
		return nil, fmt.Errorf("failed to generate manifest: %w", err)
	}

	return &StepOutput{}, nil
}
