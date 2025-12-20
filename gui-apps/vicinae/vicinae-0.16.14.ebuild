# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake desktop systemd

VERSION_GIT_HASH="04608039dda3da97ccb2e89f22f4943eb1df9a03"

DESCRIPTION="A focused launcher for your desktop — native, fast, extensible"
HOMEPAGE="https://github.com/vicinaehq/vicinae"
SRC_URI="https://github.com/vicinaehq/vicinae/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 ~x86"

BDEPEND="
>=app-text/cmark-gfm-0.29.0.13
>=dev-build/cmake-3.31.7
>=dev-libs/qtkeychain-0.15.0-r1
>=sci-libs/libqalculate-5.5.2
>=net-libs/nodejs-22.13.1[npm]
>=dev-qt/qtbase-6.9.1
>=dev-libs/qtkeychain-0.15.0
>=dev-cpp/rapidfuzz-cpp-3.3.2
>=sys-libs/minizip-ng-4.0.10
>=kde-plasma/layer-shell-qt-6.3.6
>=dev-qt/qtsvg-6.9.1
>=dev-build/ninja-1.12.1
sys-libs/zlib[minizip]
"
DEPEND="
>=dev-libs/protobuf-30.2
"
RDEPEND="${DEPEND}"

USE="+typescript-extensions lto static"

# TODO(jaredallard): Generate tarballs for the npm packages so we don't
# need to restrict the network sandbox.
RESTRICT="network-sandbox"

src_configure() {
  cmake -G Ninja -B build \
    "-DPREFER_STATIC_LIBS=$(usex "static" "ON" "OFF")" \
    "-DLTO=$(usex "lto" "ON" "OFF")" \
    "-DVICINAE_GIT_TAG=v$PV" \
    "-DVICINAE_GIT_COMMIT_HASH=$VERSION_GIT_HASH" \
    "-DVICINAE_PROVENANCE=ebuild" \
    "-DCMAKE_BUILD_TYPE=Release" \
    "-DTYPESCRIPT_EXTENSIONS=$(usex "typescript-extensions" "ON" "OFF")" \
    "-DCMAKE_INSTALL_PREFIX=${D}/usr" || die "couldn't configure source"
}

src_compile() {
  cmake --build build || die "cmake build failed"
}

src_install() {
  domenu extra/vicinae.desktop
  systemd_dounit extra/vicinae.service
  cmake --install build || die "cmake install failed"
}
