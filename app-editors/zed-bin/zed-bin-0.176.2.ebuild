# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# shellcheck shell=bash

EAPI=8

inherit desktop xdg unpacker

DESCRIPTION="The fast, collaborative code editor"
HOMEPAGE="https://zed.dev https://github.com/zed-industries/zed"
SRC_URI="
amd64? ( https://github.com/zed-industries/zed/releases/download/v${PV}/zed-linux-x86_64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://github.com/zed-industries/zed/releases/download/v${PV}/zed-linux-aarch64.tar.gz -> ${P}-arm64.tar.gz )
"

RESTRICT="bindist mirror strip test"
LICENSE="GPL-3+"
SLOT="0"
QA_PREBUILT="*"
DEPEND="
	app-arch/zstd:=
	app-misc/jq
	dev-db/sqlite:3
	>=dev-libs/libgit2-1.9.0:=
	dev-libs/mimalloc
	dev-libs/openssl:0/3
	dev-libs/protobuf
	dev-libs/wayland
	dev-libs/wayland-protocols
	dev-util/wayland-scanner
	dev-util/vulkan-tools
	|| (
		media-fonts/dejavu
		media-fonts/cantarell
		media-fonts/noto
		media-fonts/ubuntu-font-family
	)
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/vulkan-loader[X]
	net-analyzer/openbsd-netcat
	net-misc/curl
	sys-libs/zlib
	x11-libs/libxcb:=
	x11-libs/libxkbcommon[X]
"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_prepare() {
  default
  xdg_environment_reset
}

src_install() {
  S="${S}/zed.app"

  newbin "${S}/bin/zed" zed
  exeinto "/usr/libexec"
  newexe "${S}/libexec/zed-editor" zed-editor

  doicon -s 512 "${S}/share/icons/hicolor/512x512/apps/zed.png"
  doicon -s 1024 "${S}/share/icons/hicolor/1024x1024/apps/zed.png"
  domenu "${S}/share/applications/zed.desktop"
}

pkg_postrm() {
  xdg_icon_cache_update
  xdg_desktop_database_update
  xdg_mimeinfo_database_update
}
