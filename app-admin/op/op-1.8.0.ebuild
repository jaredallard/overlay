# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="1Password Command Line Interface"
HOMEPAGE="https://1password.com/"
SRC_URI="https://cache.agilebits.com/dist/1P/op/pkg/v${PV}/op_linux_amd64_v${PV}.zip"

LICENSE="all-rights-reserved"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_install() {
	default
	dobin op
}