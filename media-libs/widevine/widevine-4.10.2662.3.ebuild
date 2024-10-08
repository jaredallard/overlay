# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

INSTALLER_SHA="7a3928fe1342fb07d96f61c2b094e3287588958b"
LACROS_VERSION="130.0.6723.0"

DESCRIPTION="Widevine CDM installer for arm64"
HOMEPAGE="https://github.com/AsahiLinux/widevine-installer"
SRC_URI="
  https://github.com/AsahiLinux/widevine-installer/archive/${INSTALLER_SHA}.zip
  https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/chromeos-lacros-arm64-squash-zstd-${LACROS_VERSION}
"
RESTRICT="bindist mirror strip"
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

# Nothing is built from source here.
QA_PREBUILT="*"

src_unpack() {
  unpack "${INSTALLER_SHA}.zip"
  mv "widevine-installer-${INSTALLER_SHA}" "widevine-${PV}" || die "Failed to rename widevine-installer"
  cp "${DISTDIR}/chromeos-lacros-arm64-squash-zstd-${LACROS_VERSION}" "widevine-${PV}/lacros.squashfs" || die "Failed to copy lacros.squashfs"
}

src_install() {
  export DESTDIR="${D}"
  export SCRIPT_BASE="$(pwd)"
  patch -p1 <"${FILESDIR}/widevine-installer.patch" || die "Failed to apply patch"
  "./widevine-installer" || die "Installation failed"
}
