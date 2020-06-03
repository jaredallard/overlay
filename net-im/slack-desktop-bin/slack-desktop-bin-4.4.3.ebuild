# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit unpacker eutils

DESCRIPTION="Official Slack Desktop Client"
HOMEPAGE="http://www.slack.com/"

SRC_URI_AMD64="https://slack-ssb-updates.global.ssl.fastly.net/linux_releases/slack-desktop-${PV}-amd64.deb"
SRC_URI_X86="https://slack-ssb-updates.global.ssl.fastly.net/linux_releases/slack-desktop-${PV}-i386.deb"
#SRC_URI="
#	amd64? ( ${SRC_URI_AMD64} )
#	x86? ( ${SRC_URI_X86} )
#"
SRC_URI="
	amd64? ( ${SRC_URI_AMD64} )
"

LICENSE=""
SLOT="0"
#KEYWORDS="~amd64 ~x86"
KEYWORDS="~amd64"

DEPEND="gnome-base/gconf
    x11-libs/gtk+:2
    virtual/udev
    dev-libs/libgcrypt
    x11-libs/libnotify
    x11-libs/libXtst
    dev-libs/nss
    dev-lang/python
    gnome-base/gvfs
    x11-misc/xdg-utils
"

S="${WORKDIR}"

RESTRICT="mirror"

src_unpack() {
    unpack_deb ${A}
}

src_install() {
    cp -R "${WORKDIR}/usr" "${D}" || die "install failed!"
}

