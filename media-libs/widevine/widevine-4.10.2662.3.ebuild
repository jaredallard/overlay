# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

INSTALLER_SHA="7a3928fe1342fb07d96f61c2b094e3287588958b"
# Newer versions cause chromium to core dump on startup. Match
# widevine-installer.
#
# See: https://github.com/AsahiLinux/widevine-installer/blob/main/widevine-installer#L18
LACROS_VERSION="120.0.6098.0"

DESCRIPTION="Widevine CDM installer for arm64"
HOMEPAGE="https://github.com/AsahiLinux/widevine-installer"
SRC_URI="
  https://github.com/AsahiLinux/widevine-installer/archive/${INSTALLER_SHA}.zip
  https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/chromeos-lacros-arm64-squash-zstd-${LACROS_VERSION}
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
  unpack "${INSTALLER_SHA}.zip"
  cp "${DISTDIR}/chromeos-lacros-arm64-squash-zstd-${LACROS_VERSION}" "${S}/widevine-installer"-*/lacros.squashfs || die "Failed to copy lacros.squashfs"
}

src_install() {
  export DESTDIR="${D}"

  pushd "${S}/widevine-installer"-* >/dev/null || return 1
  export SCRIPT_BASE="$(pwd)"
  patch -p1 <"${FILESDIR}/widevine-installer.patch" || die "Failed to apply patch"
  "./widevine-installer" || die "Installation failed"
  popd >/dev/null || return 1
}
