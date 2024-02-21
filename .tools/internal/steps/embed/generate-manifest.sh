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
set -euo pipefail

# EBUILD_NAME is the name of the ebuild. Should be 'category/name'.
EBUILD_NAME="$1"

# EBUILD_PATH is the path to the ebuild file that should be used.
EBUILD_PATH="$2"

# EBUILD_LATEST_VERSION is the latest version of the ebuild.
EBUILD_LATEST_VERSION="$3"

# MANIFEST_WRITE_PATH is the path to the manifest file that will be
# written to and read out of by the updater.
MANIFEST_WRITE_PATH="/.well-known/Manifest"

portdir="/src/fake_portdir/$EBUILD_NAME"
mkdir -p "$portdir"

mkdir -p "$portdir/metadata"
# TODO(jaredallard): This should match the repo.
cat >"$portdir/metadata/layout.conf" <<EOF
masters = gentoo
thin-manifests = true
sign-manifests = false
EOF

pushd "$portdir" >/dev/null || exit 1
ebuild_path="$(basename "$EBUILD_NAME")-$EBUILD_LATEST_VERSION.ebuild"
cp "$EBUILD_PATH" "$ebuild_path"
chown -R portage:portage .
ebuild "$ebuild_path" manifest
mkdir -p "$(dirname "$MANIFEST_WRITE_PATH")"
cp Manifest "$MANIFEST_WRITE_PATH"
popd >/dev/null || exit 1
