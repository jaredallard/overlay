# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake desktop systemd unpacker

VERSION_GIT_HASH="f139777bb04e76844f2065148652172afdba9385"

DESCRIPTION="A focused launcher for your desktop — native, fast, extensible"
HOMEPAGE="https://github.com/vicinaehq/vicinae"
SRC_URI="https://github.com/vicinaehq/vicinae/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 ~x86"

BDEPEND="
app-text/cmark-gfm
dev-build/cmake
dev-libs/qtkeychain
sci-libs/libqalculate
net-libs/nodejs[npm]
dev-qt/qtbase
dev-libs/qtkeychain
dev-cpp/rapidfuzz-cpp
sys-libs/minizip-ng
kde-plasma/layer-shell-qt
dev-qt/qtsvg
dev-build/ninja
>=sys-devel/gcc-15
sys-libs/zlib[minizip]
"
DEPEND="
dev-libs/protobuf
"
RDEPEND="${DEPEND}"

# TODO(jaredallard): We distribute node_modules fine now, but sadly
# there is native code currently in the node_modules bundle, leading
# towards arch incompats, so we're temporarily disabling.
RESTRICT="network-sandbox"

IUSE="+typescript-extensions lto static"


src_configure() {
  # Attempt to use gcc version 15 if we're detected to be 14.
  if [[ "$("${CC:-gcc}" -dumpversion)" -lt "15" ]]; then
    elog "Forcing usage of GCC 15"
    export CC="/usr/bin/gcc-15"
    export CXX="/usr/bin/g++-15"
  fi

  ts_modules=("api" "extension-manager")
  for module in "${ts_modules[@]}"; do
    pushd "typescript/$module" >/dev/null || exit 1
    elog "Installing node_modules for typescript module $module"
    npm ci
    popd >/dev/null || exit 1
  done

  # NOTE(jaredallard): We cannot use system glaze right now because the
  # version is too old. https://packages.gentoo.org/packages/dev-cpp/glaze
  # # "-DUSE_SYSTEM_GLAZE=ON" \
  cmake -G Ninja -B build \
    "-DPREFER_STATIC_LIBS=$(usex "static" "ON" "OFF")" \
    "-DLTO=$(usex "lto" "ON" "OFF")" \
    "-DINSTALL_NODE_MODULES=OFF" \
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
