# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Autogenerated by pycargoebuild 0.13.2

EAPI=8

CRATES="
"

inherit cargo

DESCRIPTION="The front-end to your dev env"
HOMEPAGE="https://mise.jdx.dev"
SRC_URI="
https://github.com/jdx/mise/archive/refs/tags/v${PV}.tar.gz
https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${PV}/crates.tar.xz -> crates-${PV}.tar.xz
${CARGO_CRATE_URIS}"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+=" Apache-2.0 BSD Boost-1.0 ISC MIT MPL-2.0 Unicode-3.0 ZLIB"
RUST_MIN_VER="1.85.0"
BDEPEND="
virtual/pkgconfig
dev-libs/openssl
app-arch/zstd
"
SLOT="0"
KEYWORDS="amd64 arm64 x86"

src_configure() {
	export OPENSSL_NO_VENDOR=1
	export ZSTD_SYS_USE_PKG_CONFIG=1

	cargo_src_configure
}
