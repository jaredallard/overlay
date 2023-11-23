#!/usr/bin/env bash
# Rebuilds a Manifest file for the provided ebuild.

ebuild_path="$1"

if [[ -z "$ebuild_path" ]]; then
  echo "Error: Missing ebuild path" >&1
  exit 1
fi

if [[ ! -d "$ebuild_path" ]]; then
  echo "Error: Invalid ebuild path (must be directory)" >&1
  exit 1
fi

docker buildx build --load -t gentoo-ebuild-manifest-rebuild .
exec docker run --rm -it -v "$(pwd):/host_mnt" gentoo-ebuild-manifest-rebuild bash -ce 'cd "/host_mnt/$1" && ebuild *.ebuild manifest' -- "$ebuild_path"
