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

	"github.com/jaredallard/overlay/.tools/internal/steps"
	"gopkg.in/yaml.v3"
)

// Resolver is the resolver to use to determine if an update is available.
type Resolver string

// Contains the supported resolvers.
const (
	// GitResolver is the git resolver.
	GitResolver Resolver = "git"

	// APTResolver is a version resolver powered by an APT repository.
	APTResolver Resolver = "apt"
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

	cfg := Config{}
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

	// Resolver to use to determine if an update is available.
	// Currently only "git" is supported.
	Resolver Resolver `yaml:"resolver"`

	// GitOptions is the options for the git resolver.
	GitOptions GitOptions `yaml:"options"`

	// APTOptions is the options for the APT resolver.
	APTOptions APTOptions `yaml:"options"`

	// Steps are the steps to use to update the ebuild, if not set it
	// defaults to a copy the existing ebuild and regenerate the manifest.
	Steps steps.Steps `yaml:"steps"`
}

// UnmarshalYAML unmarshals the ebuild configuration from YAML while
// converting options into the appropriate type for the provided
// resolver.
func (e *Ebuild) UnmarshalYAML(unmarshal func(interface{}) error) error {
	var raw struct {
		Resolver Resolver  `yaml:"resolver"`
		Options  yaml.Node `yaml:"options"`
		Steps    steps.Steps
	}

	if err := unmarshal(&raw); err != nil {
		return err
	}

	e.Resolver = raw.Resolver
	e.Steps = raw.Steps

	switch e.Resolver {
	case GitResolver:
		if err := raw.Options.Decode(&e.GitOptions); err != nil {
			return fmt.Errorf("failed to decode git options: %w", err)
		}
	case APTResolver:
		if err := raw.Options.Decode(&e.APTOptions); err != nil {
			return fmt.Errorf("failed to decode APT options: %w", err)
		}
	default:
		return fmt.Errorf("unsupported resolver: %s", e.Resolver)
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

// GitOptions is the options for the git resolver.
type GitOptions struct {
	// URL is the URL to the git repository. Must be a valid option to
	// 'git clone'.
	URL string `yaml:"url"`

	// Tags denote if tags should be used as the version source.
	Tags bool `yaml:"tags"`
}

// APTOptions contains the options for the APT resolver.
type APTOptions struct {
	// Repository is the URL of the APT repository. Should match the
	// following format:
	//  deb http://archive.ubuntu.com/ubuntu/ focal main
	Repository string `yaml:"repository"`

	// Package is the name of the package to watch versions for.
	Package string `yaml:"package"`

	// StripRelease is a boolean that denotes if extra release information
	// (in the context of a semver) should be stripped. Defaults to true.
	StripRelease *bool `yaml:"strip_release"`
}
