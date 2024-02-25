# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

INSTALLER_SHA="7a3928fe1342fb07d96f61c2b094e3287588958b"
LACROS_VERSION="122.0.6261.69"

DESCRIPTION="A file archiver with a high compression ratio"
HOMEPAGE="https://7-zip.org"
SRC_URI="
  https://github.com/AsahiLinux/widevine-installer/archive/${INSTALLER_SHA}.zip -> installer.zip
  https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/chromeos-lacros-arm64-squash-zstd-${LACROS_VERSION} -> lacros.squashfs
"
RESTRICT="bindist mirror"
S="${WORKDIR}"

LICENSE="MIT Widevine"
SLOT="0"
KEYWORDS="arm64"
IUSE=""

RDEPEND="
www-client/chromium[widevine]
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-fs/squashfs-tools[zstd]
"

src_unpack() {
  unpack installer.zip
  cp "${DISTDIR}/lacros.squashfs" "${S}/widevine-installer"-*/ || die "Failed to copy lacros.squashfs"
}

src_install() {
  export DESTDIR="${D}"

  pushd "${S}/widevine-installer"-* >/dev/null || return 1
  export SCRIPT_BASE="$(pwd)"
  "${FILESDIR}/widevine-installer" || die "Installation failed"
  popd >/dev/null || return 1
}
