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

import (
	"testing"

	"gotest.tools/v3/assert"
)

func TestFetchPackage(t *testing.T) {
	r, err := parseRelease(&Repository{
		URL:          "https://downloads.1password.com/linux/debian/amd64",
		Distribution: "stable",
		Components:   []string{"main"},
	}, Lookup{})
	assert.NilError(t, err)

	// Find Packages.gz
	var i *index
	for _, index := range r.Indexes {
		if index.Path == "main/binary-amd64/Packages.gz" {
			i = &index
			break
		}
	}

	assert.Assert(t, i != nil, "failed to find Packages.gz index")

	// Get the packages
	packages, err := parsePackages(i)
	assert.NilError(t, err)

	// Find the "1password" package
	var pkg *Package
	for _, p := range packages {
		if p.Name == "1password" {
			pkg = &p
			break
		}
	}
	assert.Assert(t, pkg != nil, "failed to find 1password package")
}
