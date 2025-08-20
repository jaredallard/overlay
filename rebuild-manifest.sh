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

imageName="ghcr.io/jaredallard/overlay:updater"

# Build the image if it doesn't already exist in the cache.
if ! docker image inspect "$imageName" >/dev/null; then
  docker buildx build --load -t "$imageName" .
fi

exec docker run \
  --privileged --rm -it -v "$(pwd):/host_mnt" --entrypoint bash \
  "$imageName" -ce 'cd "/host_mnt/$1" && for ebuild in *.ebuild; do ebuild "$ebuild" manifest; done' -- "$ebuild_path"
