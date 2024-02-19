#!/usr/bin/env bash
# Copyright (C) 2024 Jared Allard
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Contains function stubs for validating ebuilds.

# inherit is not required for linting of ebuilds currently, so it does
# nothing. Eventually, if we do more static linting validation, we may
# want to implement this further.
inherit() { return 0; }

# version related functions that don't need to work for linting.
ver_cut() { return 0; }
ver_rs() { return 0; }

# cargo_crate_uris is not required for linting of ebuilds currently, noop.
cargo_crate_uris() { return 0; }
