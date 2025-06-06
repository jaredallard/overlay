# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module tmpfiles

DESCRIPTION="A GitLab CLI tool bringing GitLab to your command line"
HOMEPAGE="https://gitlab.com/gitlab-org/cli"
SRC_URI="https://gitlab.com/gitlab-org/cli/-/archive/v${PV}/cli-v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${PV}/deps.tar.xz -> ${P}-deps.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm arm64 ~riscv ~x86"

BDEPEND=">=dev-lang/go-1.24"

RESTRICT="test"

src_unpack() {
  default
  mv "cli-v${PV}" "${P}"
}

src_compile() {
  emake GLAB_VERSION=${PV} build

  mkdir -p ${S}/man
  go run ./cmd/gen-docs/docs.go --manpage --path ${S}/man
}

src_install() {
  dobin ${S}/bin/${PN}
  einstalldocs

  for page in "${S}/man/"*; do
    doman "${page}"
  done
}
