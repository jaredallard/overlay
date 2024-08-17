# Copyright 2020-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module

VERSION_GIT_HASH="7f44957f0bbcdea196c2a6b0547f50d7aac6d7eb"

DESCRIPTION="Manage your dotfiles across multiple diverse machines, securely"
HOMEPAGE="https://www.chezmoi.io/"
SRC_URI="https://github.com/twpayne/chezmoi/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${PV}/deps.tar.xz -> ${P}-deps.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm arm64 ~riscv ~x86"

BDEPEND=">=dev-lang/go-1.22"

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
