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
	"os"
	"os/exec"
)

// CommandStep is a step that runs a command.
type CommandStep struct {
	// cmd is the command provided to the step.
	cmd string
}

// NewCommandStep creates a new CommandStep from the provided input.
func NewCommandStep(input any) (StepRunner, error) {
	cmd, ok := input.(string)
	if !ok {
		return nil, fmt.Errorf("expected string, got %T", input)
	}

	return &CommandStep{cmd}, nil
}

// Run runs the provided command inside of the step runner.
func (c CommandStep) Run(ctx context.Context, env Environment) (*StepOutput, error) {
	cmd := exec.CommandContext(ctx, "docker", "exec", env.containerID, "bash", "-eo", "pipefail", "-c", c.cmd)
	cmd.Stderr = os.Stderr
	cmd.Stdout = os.Stdout
	if err := cmd.Run(); err != nil {
		return nil, fmt.Errorf("failed to run command '%s': %w", c.cmd, err)
	}

	return nil, nil
}
