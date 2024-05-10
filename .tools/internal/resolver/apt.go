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

package updater

import (
	"github.com/blang/semver/v4"
	"github.com/jaredallard/overlay/.tools/internal/config/packages"
	"github.com/jaredallard/overlay/.tools/internal/resolver/apt"
)

// getAPTVersion returns the latest version of an APT package based on
// the config provided.
func getAPTVersion(ce *packages.Package) (string, error) {
	v, err := apt.GetPackageVersion(apt.Lookup{
		SourcesEntry: ce.APTOptions.Repository,
		Package:      ce.APTOptions.Package,
	})
	if err != nil {
		return "", err
	}

	// Remove build and pre-release versions if we're stripping them.
	if ce.APTOptions.StripRelease == nil || *ce.APTOptions.StripRelease {
		sv, err := semver.ParseTolerant(v)
		if err != nil {
			// Leave it as is.
			return v, nil
		}
		sv.Pre = nil
		sv.Build = nil
		return sv.String(), nil
	}

	return v, nil
}
