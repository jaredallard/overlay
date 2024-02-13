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

// Backend is the backend to use to determine if an update is available.
type Backend string

// Contains the supported backends.
const (
	// GitBackend is the git backend.
	GitBackend Backend = "git"
)

// Config is the configuration for the updater.
type Config map[string]Ebuild

// LoadConfig loads the updater configuration from the provided path.
func LoadConfig(path string) (Config, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("failed to open config file: %w", err)
	}
	defer f.Close()

	var cfg Config = make(map[string]Ebuild)
	if err := yaml.NewDecoder(f).Decode(&cfg); err != nil {
		return nil, fmt.Errorf("failed to decode config: %w", err)
	}

	return cfg, nil
}

// Ebuild is an ebuild that should be updated by the updater.
type Ebuild struct {
	// Name of the ebuild. This is only set when loaded from the config.
	// It is a readonly field.
	Name string `yaml:"name,omitempty"`

	// Backend to use to determine if an update is available.
	// Currently only "git" is supported.
	Backend Backend `yaml:"backend"`

	// GitOptions is the options for the git backend.
	GitOptions GitOptions `yaml:"options"`
}

// UnmarshalYAML unmarshals the ebuild configuration from YAML while
// converting options into the appropriate type for the provided
// backend.
func (e *Ebuild) UnmarshalYAML(unmarshal func(interface{}) error) error {
	var raw struct {
		Backend Backend   `yaml:"backend"`
		Options yaml.Node `yaml:"options"`
	}

	if err := unmarshal(&raw); err != nil {
		return err
	}

	e.Backend = raw.Backend

	switch e.Backend {
	case GitBackend:
		if err := raw.Options.Decode(&e.GitOptions); err != nil {
			return fmt.Errorf("failed to decode git options: %w", err)
		}
	default:
		return fmt.Errorf("unsupported backend: %s", e.Backend)
	}

	return nil
}

// UnmarshalYAML unmarshals the configuration from YAML while carrying
// over the ebuild name into the ebuild struct.
func (c Config) UnmarshalYAML(unmarshal func(interface{}) error) error {
	var ebuilds map[string]Ebuild

	if err := unmarshal(&ebuilds); err != nil {
		return err
	}

	for name, ebuild := range ebuilds {
		ebuild.Name = name
		c[name] = ebuild
	}

	return nil
}

// GitOptions is the options for the git backend.
type GitOptions struct {
	// URL is the URL to the git repository. Must be a valid option to
	// 'git clone'.
	URL string `yaml:"url"`

	// Tags denote if tags should be used as the version source.
	Tags bool `yaml:"tags"`
}
