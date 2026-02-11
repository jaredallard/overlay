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
	"path/filepath"

	"github.com/jaredallard/overlay/.tools/internal/steps/stepshelpers"
)

//go:embed embed/generate-manifest.sh
var ebuildManifestGeneratorScript []byte

// EbuildStep is a step that reads an ebuild from the filesystem. It is
// used as the ebuild that will be written to disk. A manifest is
// generated from this ebuild.
type EbuildStep struct {
	// path is the path to the ebuild.
	path string
}

// NewEbuildStep creates a new EbuildStep from the provided input.
func NewEbuildStep(input any) (StepRunner, error) {
	path, ok := input.(string)
	if !ok {
		return nil, fmt.Errorf("expected string, got %T", input)
	}

	return &EbuildStep{path}, nil
}

// Run runs the provided command inside of the step runner.
func (e EbuildStep) Run(ctx context.Context, env Environment) (*StepOutput, error) {
	if !filepath.IsAbs(e.path) {
		e.path = filepath.Join(env.workDir, e.path)
	}

	if err := stepshelpers.CopyFileBytesToContainer(ctx, env.containerID, ebuildManifestGeneratorScript, "/generate-manifest.sh"); err != nil {
		return nil, fmt.Errorf("failed to create manifest generator script in container: %w", err)
	}

	env.log.Info("generating manifest")
	if err := stepshelpers.RunCommandInContainer(ctx, env.containerID, nil,
		"bash", "/generate-manifest.sh",
		env.in.OriginalEbuild.Category+"/"+env.in.OriginalEbuild.Name, e.path,
		WellKnownExistingEbuilds, env.in.LatestVersionEbuild,
	); err != nil {
		return nil, fmt.Errorf("failed to generate manifest: %w", err)
	}

	ebuildB, err := stepshelpers.ReadFileInContainer(ctx, env.containerID, e.path)
	if err != nil {
		return nil, fmt.Errorf("failed to read ebuild from container: %w", err)
	}

	manifestB, err := stepshelpers.ReadFileInContainer(ctx, env.containerID, "/.well-known/Manifest")
	if err != nil {
		return nil, fmt.Errorf("failed to read manifest from container: %w", err)
	}

	return &StepOutput{Ebuild: ebuildB, Manifest: manifestB}, nil
}
