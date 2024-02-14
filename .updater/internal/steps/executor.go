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
	"os/exec"

	logger "github.com/charmbracelet/log"

	"github.com/docker/docker/api/types/container"
	dockerclient "github.com/docker/docker/client"
)

// Executor runs the provided steps inside of a Docker container.
type Executor struct {
	log *logger.Logger
	env Enviromment
	s   Steps
}

// Environment is state that is passed to the steps ran by the executor.
type Enviromment struct {
	log *logger.Logger
	d   *dockerclient.Client

	// containerID is the ID of the container that the steps are ran in.
	containerID string
}

// Results are results of the steps that were run.
type Results struct {
	// Contents is the contents of the ebuild that was generated.
	Contents string
}

// NewExecutor creates a new executor with the provided steps.
func NewExecutor(log *logger.Logger, s Steps) Executor {
	return Executor{log, Enviromment{}, s}
}

// Run runs the provided steps and returns information about the run.
func (e *Executor) Run(ctx context.Context) (*Results, error) {
	dcli, err := dockerclient.NewClientWithOpts(dockerclient.FromEnv)
	if err != nil {
		return nil, fmt.Errorf("failed to create docker client: %w", err)
	}

	// TODO(jaredallard): Use the Docker API for this, but for now the CLI
	// is much better.
	bid, err := exec.Command("docker", "run", "-d", "--rm", "--entrypoint", "sleep", "gentoo/stage3", "inifinity").Output()
	if err != nil {
		return nil, fmt.Errorf("failed to create container: %w", err)
	}
	id := string(bid)
	e.log.With("id", id).Debug("created container")

	// assign the client to the environment for steps to use.
	e.env.d = dcli
	e.env.log = e.log
	e.env.containerID = id

	// Ensure the container is stopped when we're done.
	defer func() {
		e.log.With("id", id).Debug("stopping container")
		dcli.ContainerStop(ctx, e.env.containerID, container.StopOptions{})
	}()

	var results Results
	for _, step := range e.s {
		e.log.With("stepType", fmt.Sprintf("%T", step)).Debug("running step")
		out, err := step.Run(ctx, e.env)
		if err != nil {
			return nil, fmt.Errorf("failed to run step: %w", err)
		}

		if out != nil {
			results.Contents = out.Contents
		}
	}

	return &results, nil
}
