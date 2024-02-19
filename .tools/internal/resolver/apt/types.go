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

package apt

import "time"

type release struct {
	Suite         string
	Codename      string
	Date          time.Time
	Architectures []string
	Components    []string
	Description   string

	Indexes []index
}

// hash is a hashed value of a file. Contains the algorithm name as well
// as the value.
type hash struct {
	algo, value string
}

// index represents a file in a release.
// See: https://wiki.debian.org/DebianRepository/Format
type index struct {
	// URL is the location of this index.
	URL string

	// Path is the path to the index as denoted in the index.
	Path string

	// Size is the size of the index in bytes.
	Size int64

	Hashes []*hash
}

// Package represents an APT package as it exists on an APT repository.
// See: https://wiki.debian.org/DebianRepository/Format#A.22Packages.22_Indices
type Package struct {
	Name         string
	Maintainer   string
	Architecture string
	Version      string
	Filename     string
	Size         int64
	Hashes       []*hash
	Description  string
	Homepage     string
	Vendor       string
}
