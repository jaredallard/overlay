# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module shell-completion

DESCRIPTION="A tool for glamorous shell scripts"
HOMEPAGE="https://github.com/charmbracelet/gum"
SRC_URI="https://github.com/charmbracelet/gum/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${PV}/deps.tar.xz -> ${P}-deps.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~riscv ~x86"

BDEPEND=">=dev-lang/go-1.23"

RESTRICT="test"

src_compile() {
  ego build \
    -ldflags \
	  "-s -w -X=main.Version=v${PV}" \
    ./
}

src_install() {
  dobin gum
}
