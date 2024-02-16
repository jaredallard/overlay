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

// RunCommandInContainer runs a command inside of a container.
func RunCommandInContainer(ctx context.Context, containerID string, origArgs ...string) error {
	args := []string{"exec", containerID, "bash", "-eo", "pipefail"}
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
