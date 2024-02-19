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
	"github.com/jaredallard/overlay/.tools/internal/config"
	"github.com/jaredallard/overlay/.tools/internal/resolver/apt"
)

// getAPTVersion returns the latest version of an APT package based on
// the config provided.
func getAPTVersion(ce *config.Ebuild) (string, error) {
	return apt.GetPackageVersion(apt.Lookup{
		SourcesEntry: ce.APTOptions.Repository,
		Package:      ce.APTOptions.Package,
	})
}
