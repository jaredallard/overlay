# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit cmake desktop systemd unpacker

VERSION_GIT_HASH="257beed1d23d17dc66a2730cf63f0d666178d3a8"

DESCRIPTION="A focused launcher for your desktop — native, fast, extensible"
HOMEPAGE="https://github.com/vicinaehq/vicinae"
SRC_URI="https://github.com/vicinaehq/vicinae/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 ~x86"

BDEPEND="
app-text/cmark-gfm
dev-build/cmake
dev-build/ninja
>=dev-cpp/glaze-6
dev-libs/qtkeychain
dev-qt/qtbase[X]
dev-qt/qtdeclarative
dev-qt/qtshadertools
dev-qt/qtsvg
dev-cpp/rapidfuzz-cpp
kde-frameworks/syntax-highlighting
kde-plasma/layer-shell-qt
>=sys-devel/gcc-15
sci-libs/libqalculate
sys-libs/minizip-ng
sys-libs/zlib[minizip]
"
DEPEND="
net-libs/nodejs[npm]
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
    pushd "src/typescript/$module" >/dev/null || exit 1
    elog "Installing node_modules for typescript module $module"
    npm ci
    popd >/dev/null || exit 1
  done

  cmake -G Ninja -B build \
    "-DPREFER_STATIC_LIBS=$(usex "static" "ON" "OFF")" \
    "-DLTO=$(usex "lto" "ON" "OFF")" \
    "-DINSTALL_NODE_MODULES=OFF" \
    "-DVICINAE_GIT_TAG=v$PV" \
    "-DVICINAE_GIT_COMMIT_HASH=$VERSION_GIT_HASH" \
    "-DVICINAE_PROVENANCE=ebuild" \
    "-DUSE_SYSTEM_GLAZE=ON" \
    "-DCMAKE_BUILD_TYPE=Release" \
    "-DTYPESCRIPT_EXTENSIONS=$(usex "typescript-extensions" "ON" "OFF")" \
    "-DCMAKE_INSTALL_PREFIX=${D}/usr" \
    "-DINSTALL_BROWSER_NATIVE_HOST=OFF" \
    || die "couldn't configure source"
}

src_compile() {
  cmake --build build || die "cmake build failed"
}

src_install() {
  domenu extra/vicinae.desktop
  systemd_dounit extra/vicinae.service
  cmake --install build || die "cmake install failed"
}
