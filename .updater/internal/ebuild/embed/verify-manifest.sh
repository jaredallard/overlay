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

# Validates that a manifest is up-to-date and valid. Outcome of this
# script is communicated through exit codes.
#
# Valid exit codes are:
# 0 - Manifest is up-to-date and valid
# 1 - General error ocurring during validation
# 2 - Manifest is invalid or out-of-sync
#
# Usage: verify-manifest.sh [package-dir]
#
# Examples:
#
#   # Validate the ebuild sys-kernel/asahi-kernel
#   verify-manifest.sh sys-kernel/asahi-kernel
set -euo pipefail

# EBUILD_DIR is the directory used for ebuild validations. Contains a
# /src directory with the ebuilds to validate, and a /work directory
# used for the actual validation.
EBUILD_DIR="/ebuild"

# EBUILD_SRC_DIR and EBUILD_WORK_DIR are the /src and /work
# directories within the EBUILD_DIR. Used for convenience.
EBUILD_SRC_DIR="$EBUILD_DIR/src"
EBUILD_WORK_DIR="$EBUILD_DIR/work"

# Ensure that /src was mounted.
if [[ ! -e "$EBUILD_DIR/src" ]]; then
  echo "No src directory found in $EBUILD_DIR" >&2
  exit 1
fi

info() {
  echo -e "\033[1m[verify-manifest]: $*\033[0m" >&2
}

# validate_ebuild validates an ebuild's manifest by running the
# manifest command on the ebuild. It then compares the manifest file
# in the source directory with the manifest file in the work
# directory. If they are different, then the manifest is out-of-sync
# or otherwise invalid and exit code 2 is returned.
validate_ebuild_manifest() {
  local category="$1"
  local name="$2"

  local packagePath="$category/$name"
  local workPath="$EBUILD_WORK_DIR/$packagePath"
  local srcPath="$EBUILD_SRC_DIR/$packagePath"

  # Validate the work and src path exist.
  if [[ ! -e "$workPath" ]]; then
    error "No ebuild found at work path $workPath (this is a bug)" >&2
    return 1
  fi

  if [[ ! -e "$srcPath" ]]; then
    error "No ebuild found at source path $srcPath (this is a bug)" >&2
    return 1
  fi

  info "Validating Manifest"
  pushd "$workPath" >/dev/null || return 1
  ebuild --color y "$(ls -1 ./*.ebuild)" manifest

  if [[ ! -e "Manifest" ]] && [[ ! -e "$srcPath/Manifest" ]]; then
    info "No Manifest in source directory or generated by ebuild command." \
      "Assuming package does not require a Manifest."
    return 0
  fi
  popd >/dev/null || return 1

  # Check if the source and work direct manifest files are the same or
  # not. If they aren't, then the Manifest is out-of-sync or otherwise
  # invalid.
  if ! diff -u --suppress-common-lines "$srcPath/Manifest" "$workPath/Manifest"; then
    return 2
  fi
}

# Ensure that the porage tree has been updated. Otherwise, refuse to run.
if [[ ! -e /var/db/repos/gentoo ]]; then
  echo "Portage tree not found at /var/db/repos/gentoo" >&2
  echo "Please run emerge-webrsync or equivalent before running this script" >&2
  echo "Note: Please do not run emerge-webrsync on every run as this is taxing on the mirrors" >&2
  exit 1
fi

package="$1"
if [[ ! -d "$EBUILD_SRC_DIR/$package" ]]; then
  error "No ebuild directory found at $EBUILD_SRC_DIR/$package" >&2
  exit 1
fi

# Ensures metadata is configured correctly.
mkdir -p "$EBUILD_WORK_DIR"
cp -r "$EBUILD_SRC_DIR/metadata" "$EBUILD_WORK_DIR/metadata"

# mkdir up to the category directory in the work directory, then copy
# the ebuild directory into the work directory.
mkdir -p "$EBUILD_WORK_DIR/${package%/*}"
cp -r "$EBUILD_SRC_DIR/$package" "$EBUILD_WORK_DIR/$package"
validate_ebuild_manifest "${package%/*}" "${package#*/}"
