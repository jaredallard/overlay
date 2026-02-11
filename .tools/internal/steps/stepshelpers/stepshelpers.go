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

// Package stepshelpers contains various functions used for implementing
// steps.
package stepshelpers

import (
	"archive/tar"
	"bytes"
	"context"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// CopyFileBytesToContainer copies a file into a container using the
// provided bytes as the source.
func CopyFileBytesToContainer(ctx context.Context, containerID string, src []byte, dst string) error {
	tempFile, err := os.CreateTemp("", "copy-file-*."+filepath.Ext(dst))
	if err != nil {
		return fmt.Errorf("failed to create temporary file: %w", err)
	}
	defer os.Remove(tempFile.Name())

	if _, err := tempFile.Write(src); err != nil {
		return fmt.Errorf("failed to write to temporary file: %w", err)
	}

	if err := tempFile.Close(); err != nil {
		return fmt.Errorf("failed to close temporary file: %w", err)
	}

	return CopyFileToContainer(ctx, containerID, tempFile.Name(), dst)
}

// CopyFileToContainer copies a file into a container.
func CopyFileToContainer(ctx context.Context, containerID, src, dst string) error {
	cmd := exec.CommandContext(ctx, "docker", "cp", src, fmt.Sprintf("%s:%s", containerID, dst))
	if b, err := cmd.CombinedOutput(); err != nil {
		return fmt.Errorf("failed to copy file to container: %s", string(b))
	}

	return nil
}

// ReadFileInContainer reads a file from a container and returns the
// contents.
func ReadFileInContainer(ctx context.Context, containerID, path string) ([]byte, error) {
	cmd := exec.CommandContext(ctx, "docker", "cp", fmt.Sprintf("%s:%s", containerID, path), "-")
	b, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("failed to read file in container: %w", err)
	}

	t := tar.NewReader(bytes.NewReader(b))
	if _, err := t.Next(); err != nil {
		return nil, fmt.Errorf("failed to read tar: %w", err)
	}

	b, err = io.ReadAll(t)
	if err != nil {
		return nil, fmt.Errorf("failed to read tar: %w", err)
	}

	return b, nil
}

// StreamFileFromContainer streams a file from a container to the
// provided writer. Because this function streams the file using the
// exec package, the caller must call the returned wait function to wait
// for the command to finish and clean up resources.
//
// The returned int64 is the size of the file being streamed.
func StreamFileFromContainer(ctx context.Context, containerID, path string) (io.Reader, int64, func() error, error) {
	cmd := exec.CommandContext(ctx, "docker", "cp", fmt.Sprintf("%s:%s", containerID, path), "-")
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return nil, 0, nil, fmt.Errorf("failed to create stdout pipe: %w", err)
	}

	if err := cmd.Start(); err != nil {
		return nil, 0, nil, fmt.Errorf("failed to start command: %w", err)
	}

	// Process the output as a tar stream.
	t := tar.NewReader(stdout)
	th, err := t.Next()
	if err != nil {
		return nil, 0, nil, fmt.Errorf("failed to read tar: %w", err)
	}

	return t, th.Size, cmd.Wait, nil
}

// RunCommandInContainer runs a command inside of a container.
func RunCommandInContainer(ctx context.Context, containerID string, env map[string]string, origArgs ...string) error {
	args := []string{"exec"}
	for k, v := range env {
		args = append(args, "--env", fmt.Sprintf("%s=%s", k, v))
	}

	if len(origArgs) > 1 {
		args = append(args, "-xc", strings.Join(origArgs, " "))
	} else {
		args = append(args, origArgs...)
	}

	cmd := exec.CommandContext(ctx, "docker", args...)
	cmd.Stderr = os.Stderr
	cmd.Stdout = os.Stdout
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("failed to run command '%s': %w", strings.Join(origArgs, " "), err)
	}

	return nil
}
