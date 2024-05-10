#!/usr/bin/env bash
# Rebuilds the base image used by the tools in this repository and
# pushes it upstream.
set -euo pipefail

# PUSH determines if we should push the image to the remote or not.
PUSH=false
if [[ "${1:-}" == "--push" ]]; then
  PUSH=true
fi

args=(
  "--tag" "ghcr.io/jaredallard/overlay:updater"
  "$(pwd)"
)

if [[ "$PUSH" == "true" ]]; then
  args+=("--platform" "linux/amd64,linux/arm64" "--push")
else
  args+=("--load")
fi

exec docker buildx build "${args[@]}"
