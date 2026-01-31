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

package packages

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

// List contains all of the packages that should be updated.
type List map[string]Package

// Package is an package that should be updated by the updater.
type Package struct {
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

// LoadPackages returns a map of packages from the provided path.
func LoadPackages(path string) (List, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("failed to open ebuilds file: %w", err)
	}
	defer f.Close()

	pkgs := make(List)
	if err := yaml.NewDecoder(f).Decode(&pkgs); err != nil {
		return nil, fmt.Errorf("failed to decode ebuilds: %w", err)
	}

	return pkgs, nil
}

// UnmarshalYAML unmarshals the ebuild configuration from YAML while
// converting options into the appropriate type for the provided
// resolver.
func (p *Package) UnmarshalYAML(unmarshal func(interface{}) error) error {
	var raw struct {
		Resolver Resolver  `yaml:"resolver"`
		Options  yaml.Node `yaml:"options"`
		Steps    steps.Steps
	}

	if err := unmarshal(&raw); err != nil {
		return err
	}

	p.Resolver = raw.Resolver
	p.Steps = raw.Steps

	switch p.Resolver {
	case GitResolver:
		if err := raw.Options.Decode(&p.GitOptions); err != nil {
			return fmt.Errorf("failed to decode git options: %w", err)
		}
	case APTResolver:
		if err := raw.Options.Decode(&p.APTOptions); err != nil {
			return fmt.Errorf("failed to decode APT options: %w", err)
		}
	default:
		return fmt.Errorf("unsupported resolver: %s", p.Resolver)
	}

	return nil
}

// UnmarshalYAML unmarshals the ebuilds from YAML while carrying the
// name from the key into the ebuild name.
func (l List) UnmarshalYAML(unmarshal func(interface{}) error) error {
	pkgs := make(map[string]Package)
	if err := unmarshal(&pkgs); err != nil {
		return err
	}

	for name, ebuild := range pkgs {
		ebuild.Name = name
		l[name] = ebuild
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

	// Semver denotes if versions should be parsed as semver. Defaults to
	// false. If true, ConsiderPreReleases is ignored.
	DisableSemver bool `yaml:"disable_semver"`

	// ConsiderPreReleases denotes if pre-releases should be considered,
	// when a tag is used and the version is able to be parsed as a
	// semver. Defaults to false.
	ConsiderPreReleases bool `yaml:"consider_pre_releases"`

	// IgnoreVersions is a list of versions to always ignore (looking at
	// you, Zed). Globs are also supported via [filepath.Match].
	IgnoreVersions []string `yaml:"ignore_versions"`

	// VersionTransform is option configuration for transforming versions.
	VersionTransform VersionTransform `yaml:"version_transform"`
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

// VersionTransform contains transformation information for versions.
// When set, a version is transformed based on two conditions:
// - From: Used to transform _remote_ (e.g., Git) version into "To"
// - To: Used to transform _local_ (e.g., ebuild) versions into "From"
type VersionTransform struct {
	// From is a string to transform into "To".
	From string `yaml:"from"`

	// To is what "From" should be transformed into.
	To string `yaml:"to"`
}
