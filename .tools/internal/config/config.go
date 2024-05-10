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

// Package config loads the updater configuration and stores the type
// definitions.
package config

import (
	"fmt"
	"os"

	"gopkg.in/yaml.v3"
)

// Config represents the configuration for the updater itself.
type Config struct {
	// StepConfig contains configuration for steps that support
	// updater-wide configuration.
	StepConfig struct {
		// UploadArtifact contains the configuration for where the
		// 'upload_artifact' step should upload the artifact to.
		UploadArtifact struct {
			// Bucket is the S3 bucket to upload the artifact to.
			Bucket string `yaml:"bucket"`

			// Host is the host of the S3 bucket.
			Host string `yaml:"host"`

			// Prefix is the prefix to use for the artifact when storing it in
			// S3.
			Prefix string `yaml:"prefix"`
		} `yaml:"upload_artifact"`
	} `yaml:"step_config"`
}

// LoadConfig loads the updater configuration from the provided path.
func LoadConfig(path string) (*Config, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("failed to open config file: %w", err)
	}
	defer f.Close()

	cfg := Config{}
	if err := yaml.NewDecoder(f).Decode(&cfg); err != nil {
		return nil, fmt.Errorf("failed to decode config: %w", err)
	}
	return &cfg, nil
}
