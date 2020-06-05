# Copyright 2018-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

if [[ ${PV} == *9999 ]]; then
	SCM="git-r3"
	EGIT_REPO_URI="https://github.com/lucy/tewi-font.git"
fi

inherit font python-any-r1 ${SCM}

DESCRIPTION="A small bitmap font"
HOMEPAGE="https://github.com/lucy/tewi-font"

if [[ ${PV} == *9999 ]]; then
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="https://github.com/lucy/tewi-font/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="+pcf"

DEPEND="x11-libs/libX11
	pcf? ( x11-apps/bdftopcf )
"
RDEPEND="x11-libs/libX11"
BDEPEND=""

src_compile() {
	if use pcf; then
		emake
	else
		emake var
	fi
}

src_install() {
	insinto "/usr/share/fonts/${PN}"

	if use pcf; then
		doins out/*
	else
		doins *.bdf
	fi

	font_src_install
}
