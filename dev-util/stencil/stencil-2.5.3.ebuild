# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module shell-completion

VERSION_GIT_HASH="f54d7b72adf0adc6e0a9613354d150297c427654"

DESCRIPTION="Modern living-template engine for evolving repositories"
HOMEPAGE="https://stencil.rgst.io/"
SRC_URI="https://github.com/rgst-io/stencil/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${PV}/deps.tar.xz -> ${P}-deps.tar.xz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~riscv ~x86"

BDEPEND=">=dev-lang/go-1.24"

RESTRICT="test"

src_compile() {
  ego build \
    -ldflags \
    "-s -w -X go.rgst.io/stencil/v2/internal/version.version=${PV} -X go.rgst.io/stencil/v2/internal/version.commit=${VERSION_GIT_HASH} -X go.rgst.io/stencil/v2/internal/version.date=$(date "+%Y-%m-%dT%H:%M:%SZ") -X go.rgst.io/stencil/v2/internal/version.builtBy=ebuild" \
    ./cmd/stencil
}

src_install() {
  dobin stencil
}
