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
	"strings"

	"github.com/jaredallard/overlay/.tools/internal/steps/stepshelpers"
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

// UploadArtifactStep takes the provided path and uploads it from the
// container to a stable S3 bucket. This is used to store artifacts that
// are required by ebuilds (e.g., Go dependency archives) and retrieve
// them later.
//
// S3 configuration is provided by the environment. The file will be
// stored using the following structure:
//
//	<host>/<package_name>/<package_version>/<basename of path>
type UploadArtifactStep struct {
	// path is the path to the artifact.
	path string
}

// NewUploadArtifactStep creates a new UploadArtifactStep from the provided input.
func NewUploadArtifactStep(input any) (StepRunner, error) {
	path, ok := input.(string)
	if !ok {
		return nil, fmt.Errorf("expected string, got %T", input)
	}

	return &UploadArtifactStep{path}, nil
}

// Run runs the provided command inside of the step runner.
func (e UploadArtifactStep) Run(ctx context.Context, env Environment) (*StepOutput, error) {
	if !filepath.IsAbs(e.path) {
		e.path = filepath.Join(env.workDir, e.path)
	}

	// TODO(jaredallard): We should create the client once.
	s3Conf := env.in.Config.StepConfig.UploadArtifact

	if s3Conf.Host == "" {
		return nil, fmt.Errorf("s3 host was not set in the config")
	}

	if s3Conf.Bucket == "" {
		return nil, fmt.Errorf("s3 bucket was not set in the config")
	}

	// Without a doubt, the worse code I've ever written.
	hostWithSchema := strings.TrimPrefix(strings.TrimPrefix(s3Conf.Host, "http://"), "https://")
	mc, err := minio.New(hostWithSchema, &minio.Options{
		Creds:  credentials.NewEnvAWS(),
		Secure: strings.HasPrefix(s3Conf.Host, "https"),
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create minio client: %w", err)
	}

	uploadFileName := filepath.Base(e.path)

	// Example: <?prefix>/net-vpn/tailscale/1.66.1/deps.xz
	uploadPath := filepath.Join(
		s3Conf.Prefix, env.in.OriginalEbuild.Category, env.in.OriginalEbuild.Name, env.in.LatestVersion, uploadFileName,
	)

	out, size, wait, err := stepshelpers.StreamFileFromContainer(ctx, env.containerID, e.path)
	if err != nil {
		return nil, fmt.Errorf("failed to stream file from container: %w", err)
	}

	env.log.With("path", uploadPath, "size", size).Info("uploading artifact")
	inf, err := mc.PutObject(ctx, s3Conf.Bucket, uploadPath, out, size, minio.PutObjectOptions{
		SendContentMd5: true,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to upload artifact: %w", err)
	}

	if err := wait(); err != nil {
		return nil, fmt.Errorf("failed to wait for command to finish: %w", err)
	}

	env.log.With("size", inf.Size).Info("uploaded artifact")

	return nil, nil
}
