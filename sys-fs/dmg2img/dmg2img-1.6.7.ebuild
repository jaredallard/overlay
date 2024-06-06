# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit toolchain-funcs

DESCRIPTION="Converts Apple DMG files to standard HFS+ images"
HOMEPAGE="http://vu1tur.eu.org/tools"
# Straight copy of the original source tarball that DOESN'T have invalid
# tar data.
SRC_URI="https://gentoo.rgst.io/updater_artifacts/sys-fs/dmg2img/1.6.7/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc ~x86"
IUSE=""

RDEPEND="dev-libs/openssl
	app-arch/bzip2
	sys-libs/zlib"
DEPEND="${RDEPEND}
	sys-apps/sed"

src_prepare() {
	sed -i -e 's:-s:$(LDFLAGS):g' Makefile || die "sed failed"
}

src_compile() {
	tc-export CC
	emake CFLAGS="${CFLAGS}" || die "emake failed"
}

src_install() {
	dosbin dmg2img vfdecrypt || die "dosbin failed"
	dodoc README
}
