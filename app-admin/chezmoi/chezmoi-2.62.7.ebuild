# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module shell-completion

VERSION_GIT_HASH="6384ea3f6b8059bfc554181aa3f5f461c7610024"

DESCRIPTION="Manage your dotfiles across multiple diverse machines, securely"
HOMEPAGE="https://www.chezmoi.io/"
SRC_URI="https://github.com/twpayne/chezmoi/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${PV}/deps.tar.xz -> ${P}-deps.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~riscv ~x86"

BDEPEND=">=dev-lang/go-1.24"

RESTRICT="test"

# This was added based on the .goreleaser.yml file in the upstream
# repository.
build_dist() {
  ego build \
    -ldflags \
    "-s -w -X main.version=v${PV} -X main.commit=${VERSION_GIT_HASH} -X main.date=$(date "+%Y-%m-%dT%H:%M:%SZ") -X main.builtBy=ebuild" "$@"
}

src_prepare() {
  # Replaces go tool generate-commit step
  echo -n "$VERSION_GIT_HASH" >COMMIT
  default
}

src_compile() {
  build_dist ./
}

src_install() {
  dobin chezmoi

  einstalldocs

  newbashcomp completions/${PN}-completion.bash ${PN}
  dofishcomp completions/${PN}.fish
  newzshcomp completions/${PN}.zsh _${PN}
}
