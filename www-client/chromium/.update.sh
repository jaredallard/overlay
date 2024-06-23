#!/usr/bin/env bash
# Updates the chromium package to use the versions inside from the
# gentoo repository while persisting the patches we need.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pushd "${DIR}" >/dev/null || exit 1
# Remove everything but dotfiles (us)
rm -rf ./*
popd >/dev/null || exit 1

# Fetch the ebuilds from the gentoo repository
tempDir=$(mktemp -d)

git clone --filter=tree:0 --no-checkout --depth 1 --sparse https://github.com/gentoo/gentoo "${tempDir}"
pushd "${tempDir}" >/dev/null || exit 1
git sparse-checkout add www-client/chromium
git checkout
popd >/dev/null || exit 1

# Copy the ebuilds to the current directory
cp -r "${tempDir}"/www-client/chromium/* "${DIR}"/

# Patch all the ebuilds.
for ebuild in *.ebuild; do
  for patch in .patches/ebuilds/*.patch; do
    # Copy the patch to a temporary file and rescope it to use this
    # file.
    cp "${patch}" "${patch}.tmp"
    sed -i.bak "s|@@EBUILD@@|${ebuild}|g" "${patch}.tmp"
    patch -p1 <"${patch}.tmp"
  done

  # Mutate KEYWORDS to only be scoped to arm64. Determine if stable or
  # not based on the amd64 keyword.
  if grep -q 'KEYWORDS=".*~amd64' "${ebuild}"; then
    sed -i.bak 's|KEYWORDS=".*|KEYWORDS="~arm64"|' "${ebuild}"
  else
    sed -i.bak 's|KEYWORDS=".*|KEYWORDS="arm64"|' "${ebuild}"
  fi
done

# Copy over patches to the source files
cp -r .patches/files/* files/

# Remove .orig, .bak and .tmp files
find . -name '*.orig' -delete
find . -name '*.bak' -delete
find . -name '*.tmp' -delete
