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

imageName="gentoo-ebuild-manifest-rebuild"

# Build the image if it doesn't already exist in the cache.
if ! docker images -a | grep -qE "^$imageName"; then
  docker buildx build --load -t "$imageName" .
fi

exec docker run --rm -it -v "$(pwd):/host_mnt" "$imageName" bash -ce 'cd "/host_mnt/$1" && ebuild *.ebuild manifest' -- "$ebuild_path"
