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
	"io"
	"os"

	"github.com/docker/docker/api/types"
)

// CommandStep is a step that runs a command.
type CommandStep struct {
	command string
}

// NewCommNewCommandStepand creates a new CommandStep from the provided input.
func NewCommandStep(input any) (StepRunner, error) {
	cmd, ok := input.(string)
	if !ok {
		return nil, fmt.Errorf("expected string, got %T", input)
	}

	return &CommandStep{cmd}, nil
}

// Run runs the provided command inside of the step runner.
func (c CommandStep) Run(ctx context.Context, env Enviromment) (*StepOutput, error) {
	eresp, err := env.d.ContainerExecCreate(ctx, env.containerID, types.ExecConfig{
		Cmd: []string{"bash", "-eo", "pipefail", "-c", c.command},
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create exec: %w", err)
	}

	aresp, err := env.d.ContainerExecAttach(ctx, eresp.ID, types.ExecStartCheck{})
	if err != nil {
		return nil, fmt.Errorf("failed to attach to exec: %w", err)
	}
	defer aresp.Close()

	finChan := make(chan error, 1)
	go func() {
		defer close(finChan)

		_, err := io.Copy(os.Stdout, aresp.Reader)
		if err != nil {
			finChan <- fmt.Errorf("failed to copy output: %w", err)
		}

		finChan <- nil
	}()

	env.log.Info("running command: %s", c.command)
	if err := env.d.ContainerExecStart(ctx, eresp.ID, types.ExecStartCheck{}); err != nil {
		return nil, fmt.Errorf("failed to start exec: %w", err)
	}

	// wait for the output to finish, which means the command has finished.
	if err := <-finChan; err != nil {
		return nil, err
	}

	return &StepOutput{}, nil
}
