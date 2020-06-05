# Copyright 2018-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 font

DESCRIPTION="An iconic bitmap font based on Stlarch with additional glyphs"
HOMEPAGE="https://github.com/stark/siji"
EGIT_REPO_URI="https://github.com/stark/siji.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="+pcf"

DEPEND="x11-apps/bdftopcf"
RDEPEND="${DEPEND}"
BDEPEND=""

src_compile() {
	if use pcf; then
		bdftopcf bdf/${PN}.bdf -o pcf/${PN}.pcf
	fi
}

src_install() {
	insinto "/usr/share/fonts/${PN}"

	if use pcf; then
		doins pcf/*
	else
		doins bdf/*
	fi
}
