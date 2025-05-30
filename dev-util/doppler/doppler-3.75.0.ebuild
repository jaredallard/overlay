# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module tmpfiles

DESCRIPTION="The official CLI for interacting with your Doppler secrets and configuration"
HOMEPAGE="https://gitlab.com/gitlab-org/cli"
SRC_URI="https://github.com/DopplerHQ/cli/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${PV}/deps.tar.xz -> ${P}-deps.tar.xz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm arm64 ~riscv ~x86"

BDEPEND=">=dev-lang/go-1.24"

RESTRICT="test"

src_unpack() {
  default
  mv "cli-${PV}" "${P}"
}

src_compile() {
  ego build -o bin/doppler -ldflags "-s -w -X github.com/DopplerHQ/cli/pkg/version.ProgramVersion=v${PV}" .
}

src_install() {
  dobin "${S}/bin/${PN}"
}
