# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module

VERSION_GIT_HASH="b4b55659c69fb13a502903c16dcdd566b988eece"

DESCRIPTION="Manage your dotfiles across multiple diverse machines, securely"
HOMEPAGE="https://www.chezmoi.io/"
SRC_URI="https://github.com/twpayne/chezmoi/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${PV}/deps.tar.xz -> ${P}-deps.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm arm64 ~riscv ~x86"

BDEPEND=">=dev-lang/go-1.21"

RESTRICT="test"

# This was added based on the .goreleaser.yml file in the upstream
# repository.
build_dist() {
  ego build \
    -ldflags \
    "-s -w -X main.version=v${PV} -X main.commit=${VERSION_GIT_HASH} -X main.date=$(date "+%Y-%m-%dT%H:%M:%SZ") -X main.builtBy=ebuild" "$@"
}

src_prepare() {
  # Replaces generate-commit.go step.
  echo -n "$VERSION_GIT_HASH" >COMMIT
  default
}

src_compile() {
  build_dist ./
}

src_install() {
  dobin chezmoi
}
