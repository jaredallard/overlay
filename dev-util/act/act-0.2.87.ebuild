# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module

DESCRIPTION="Run your GitHub Actions locally"
HOMEPAGE="https://nektosact.com"
SRC_URI="https://github.com/nektos/act/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${PV}/deps.tar.xz -> ${P}-deps.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64"

src_compile() {
  emake VERSION="${PV}" build
}

src_install() {
  dobin dist/local/act
  dosym dist/local/act /usr/bin/gh-act
}