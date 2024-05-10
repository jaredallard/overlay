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

// Package updater contains the main code for determining if an update
// is available for the given ebuild.
package updater

import (
	"fmt"

	"github.com/jaredallard/overlay/.tools/internal/config/packages"
)

// GetLatestVersion returns the latest version available for the given
// package.
func GetLatestVersion(ce *packages.Package) (string, error) {
	switch ce.Resolver {
	case packages.GitResolver:
		return getGitVersion(ce)
	case packages.APTResolver:
		return getAPTVersion(ce)
	case "":
		return "", fmt.Errorf("no resolver specified")
	default:
		return "", fmt.Errorf("unknown resolver: %s", ce.Resolver)
	}
}
