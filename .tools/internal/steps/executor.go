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
	"errors"
	"fmt"
	"os/exec"
	"strings"

	logger "github.com/charmbracelet/log"
	"github.com/jaredallard/overlay/.tools/internal/config"
	"github.com/jaredallard/overlay/.tools/internal/ebuild"

	"github.com/docker/docker/api/types/container"
	dockerclient "github.com/docker/docker/client"
)

const (
	// WellKnownExistingEbuilds is the path in the container where
	// existing ebuilds are stored for a package. These are older versions
	// of the current ebuild.
	WellKnownExistingEbuilds = "/.well-known/existing-ebuilds"
)

// Executor runs the provided steps inside of a Docker container.
type Executor struct {
	log *logger.Logger
	env Environment
	s   Steps
}

// Environment is state that is passed to the steps ran by the executor.
type Environment struct {
	log *logger.Logger
	d   *dockerclient.Client

	// containerID is the ID of the container that the steps are ran in.
	containerID string

	// workDir is the working directory of the container.
	workDir string

	in *ExecutorInput
}

// ExecutorInput is input to the executor. This should contain state
// that existed before the executor was ran.
type ExecutorInput struct {
	// Config is the configuration for the updater, which contains
	// configuration for some steps.
	Config *config.Config

	// OriginalEbuild is the original ebuild that can be used for
	// generating a new one.
	OriginalEbuild *ebuild.Ebuild

	// ExistingEbuilds is a list of existing ebuilds that are already
	// present that AREN'T the original ebuild.
	ExistingEbuilds []*ebuild.Ebuild

	// LatestVersion is the latest version of the package.
	LatestVersion string
}

// Results are results of the steps that were run.
type Results struct {
	StepOutput
}

// NewExecutor creates a new executor with the provided steps.
func NewExecutor(log *logger.Logger, s Steps, in *ExecutorInput) Executor {
	return Executor{log, Environment{in: in}, s}
}

// Run runs the provided steps and returns information about the run.
func (e *Executor) Run(ctx context.Context) (*Results, error) {
	dcli, err := dockerclient.NewClientWithOpts(dockerclient.FromEnv)
	if err != nil {
		return nil, fmt.Errorf("failed to create docker client: %w", err)
	}

	// TODO(jaredallard): Use the Docker API for this, but for now the CLI
	// is much better.
	bid, err := exec.Command(
		"docker", "run", "--init", "-d", "--rm", "--entrypoint", "sleep",
		"ghcr.io/jaredallard/overlay:updater", "infinity",
	).Output()
	if err != nil {
		var execErr *exec.ExitError
		if errors.As(err, &execErr) {
			return nil, fmt.Errorf("failed to run container: %s", string(execErr.Stderr))
		}

		return nil, fmt.Errorf("failed to run container: %w", err)
	}
	id := strings.TrimSpace(string(bid))
	e.log.With("id", id).Debug("created container")

	// assign the client to the environment for steps to use.
	e.env.d = dcli
	e.env.log = e.log
	e.env.containerID = id
	e.env.workDir = "/src/updater"

	// Ensure the container is stopped when we're done.
	defer func() {
		e.log.With("id", id).Debug("stopping container")
		dcli.ContainerStop(ctx, e.env.containerID, container.StopOptions{})
	}()

	var results Results
	for _, step := range e.s {
		e.log.With("stepType", fmt.Sprintf("%T", step.Runner)).With("args", step.Args).Debug("running step")
		out, err := step.Runner.Run(ctx, e.env)
		if err != nil {
			return nil, fmt.Errorf("failed to run step: %w", err)
		}

		// If there's output, merge it into the results. Last always wins.
		if out != nil {
			if out.Manifest != nil {
				results.Manifest = out.Manifest
			}

			if out.Ebuild != nil {
				results.Ebuild = out.Ebuild
			}
		}
	}

	return &results, nil
}
