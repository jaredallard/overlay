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

// CheckoutStep checks out a repository at the given path. If the Git
// resolver was used, it defaults to the URL provided in the GitOptions.
// Otherwise, it will use the URL provided.
//
// The latest version is used as the revision to checkout.
type CheckoutStep struct {
	url string
}

// NewCheckoutStep creates a new CheckoutStep from the provided input.
func NewCheckoutStep(input any) (StepRunner, error) {
	url, ok := input.(string)
	if !ok {
		return nil, fmt.Errorf("expected string, got %T", input)
	}

	return &CheckoutStep{url}, nil
}

// Run runs the provided command inside of the step runner.
func (c CheckoutStep) Run(ctx context.Context, env Environment) (*StepOutput, error) {
	cmds := [][]string{
		{"git", "-c", "init.defaultBranch=main", "init", env.workDir},
		{"git", "remote", "add", "origin", c.url},
		{"git", "-c", "protocol.version=2", "fetch", "origin", "v" + env.in.LatestVersion},
		{"git", "reset", "--hard", "FETCH_HEAD"},
	}

	for _, cmd := range cmds {
		if err := stepshelpers.RunCommandInContainer(ctx, env.containerID, cmd...); err != nil {
			return nil, fmt.Errorf("failed to run command %v: %w", cmd, err)
		}
	}

	return nil, nil
}
