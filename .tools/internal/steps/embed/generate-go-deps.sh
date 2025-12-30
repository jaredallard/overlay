#!/usr/bin/env bash
# Copyright (C) 2025 Jared Allard
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

MODE="${1:-"slim"}"
DIRECTORY="${2:-""}"
NAME="${3:-""}"

GO_VERSION=$(grep "^go" go.mod | awk '{ print $2 }' | awk -F '.' '{ print $1"."$2}')

# Only use mise to set the Go version if we don't already have mise/asdf
# support.
if [[ ! -e ".tool-versions" ]] && [[ ! -e ".mise.toml" ]]; then
  mise use -g golang@"${GO_VERSION}"
else
  mise trust || false
  mise install golang
fi

if [[ -n "$DIRECTORY" ]] && [[ -z "$NAME" ]]; then
  echo "Error: When directory is supplied, name must be set" >&2
  exit 1
fi

if [[ -n "$DIRECTORY" ]]; then
  origDir="$(pwd)"
  pushd "$DIRECTORY" >/dev/null
fi

prefix=""
if [[ -n "$NAME" ]]; then
  prefix="$NAME-"
fi
tarFileName="${prefix}deps.tar.xz"

# Create the dependency tar.
echo "Creating dependency tarball"
if [[ "$MODE" == "full" ]]; then
  tarDir="go-mod"
  GOMODCACHE="$(pwd)/go-mod" go mod download -modcacherw -x
else
  go mod vendor
  tarDir="vendor"
fi

echo "Creating tarball (compressing with xz, this may take a while...)"
XZ_OPT=-e9T0 tar cJf "$tarFileName" "$tarDir"
ls -alh "$tarFileName"

if [[ -n "$DIRECTORY" ]]; then
  mv -v "$tarFileName" "$origDir/$tarFileName"
fi

if [[ -e "new.ebuild" ]]; then
  echo "Changing Go version to ${GO_VERSION}"
  sed -i 's|dev-lang\/go-.*|dev-lang\/go-'"${GO_VERSION}"'"|' new.ebuild
fi