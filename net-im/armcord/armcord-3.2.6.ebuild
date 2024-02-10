# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="ArmCord is a custom client designed to enhance your Discord experience while keeping everything lightweight"
HOMEPAGE="https://github.com/ArmCord/ArmCord"
SRC_URI="https://github.com/ArmCord/ArmCord/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="OSL-3.0"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

# network-sandbox because node :(
RESTRICT="network-sandbox bindist mirror strip"

BDEPEND="net-libs/nodejs[npm]"

QA_PREBUILT="usr/bin/${PN}"
S="${WORKDIR}"

src_compile() {
  cd "${S}/ArmCord-${PV}" || die

  export npm_config_build_from_source=true
  export HOME="${S}/.electron-gyp"
  export PATH="${S}/.npm/bin:${PATH}"

  # Install and configure pnpm.
  npm --prefix "${S}/.npm" install -g pnpm
  pnpm config set store-dir "${S}/.pnpm_store"
  pnpm config set cache-dir "${S}/.pnpm_cache"
  pnpm config set link-workspace-packages true

  pnpm install
  pnpm run build
  npx electron-builder --config.linux.target=dir
}

src_install() {
  SRC_DIR="${S}/ArmCord-${PV}"

  mkdir -p "${D}/usr/lib"
  cp -ar "${SRC_DIR}/dist/linux-"*/ "${D}/usr/lib/${PN}/"
  fperms 4711 "/usr/lib/${PN}/chrome-sandbox"

  dosym "/usr/lib/${PN}/${PN}" "/usr/bin/${PN}"

  newicon "${SRC_DIR}/build/icon.png" "${PN}.png"
  make_desktop_entry "${PN}" "ArmCord" "${PN}" "Network;InstantMessaging;"
}
