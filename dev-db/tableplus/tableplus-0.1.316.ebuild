# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Modern, native, and friendly GUI tool for relational databases"
HOMEPAGE="https://tableplus.com"
SITE="https://deb.tableplus.com/debian"
SRC_URI="
	amd64? ( ${SITE}/26/pool/main/t/${PN}/${PN}_${PV}_amd64.deb -> ${P}-amd64.deb )
	arm64? ( ${SITE}/26-arm/pool/main/t/${PN}/${PN}_${PV}_arm64.deb -> ${P}-arm64.deb )
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="bindist mirror strip"

RDEPEND="
	>=sys-libs/glibc-2.43
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/glib:2
	dev-libs/json-glib
	dev-libs/libgee:0.8
	virtual/krb5
	virtual/zlib
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/gtksourceview:3.0
	x11-libs/pango
"

QA_PREBUILT="opt/tableplus/*"

src_prepare() {
	default

	# Remove hardcoded paths and set StartupWMClass so the window gets
	# matched to the desktop file (and thus, the icon).
	sed -i -e '/^Icon=/s|=.*|=tableplus|' \
		-e '/^Exec=/s|/usr/local/bin/|/usr/bin/|' \
		-e '$a StartupWMClass=TablePlus' opt/tableplus/tableplus.desktop \
		|| die "sed failed for tableplus.desktop"
}

src_install() {
	insinto /opt
	doins -r opt/tableplus
	fperms +x /opt/tableplus/tableplus /opt/tableplus/crashpad_handler
	dosym ../../opt/tableplus/tableplus /usr/bin/tableplus

	newicon opt/tableplus/resource/image/logo.png tableplus.png
	newicon -s 256 opt/tableplus/resource/image/logo.png tableplus.png
	domenu opt/tableplus/tableplus.desktop
}
