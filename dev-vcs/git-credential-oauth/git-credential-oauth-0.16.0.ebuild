# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module shell-completion

DESCRIPTION="Git credential helper that securely authenticates to GitHub, GitLab and BitBucket using OAuth"
HOMEPAGE="https://github.com/hickford/git-credential-oauth"
SRC_URI="https://github.com/hickford/git-credential-oauth/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${PV}/deps.tar.xz -> ${P}-deps.tar.xz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~riscv ~x86"

BDEPEND=">=dev-lang/go-1.23"

RESTRICT="test"

src_compile() {
  ego build \
    -ldflags \
    "-s -w" \
    .
}

src_install() {
  dobin git-credential-oauth
  doman git-credential-oauth.1
}
