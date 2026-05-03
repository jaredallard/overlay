# Copyright 1999-2026 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
EAPI=8

DESCRIPTION="Update Portage tree, all installed packages, and kernel"
BASE_SERVER_URI="https://git.rgst.io/jaredallard"
HOMEPAGE="${BASE_SERVER_URI}/gentoo-scripts"
SRC_URI="${BASE_SERVER_URI}/gentoo-scripts/archive/v${PV}.tar.gz"

LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~ppc"

RESTRICT="mirror"

DEPEND=""
RDEPEND="${DEPEND}
	app-portage/eix
  app-admin/perl-cleaner
	app-portage/gentoolkit
	>=app-shells/bash-5.3"

src_unpack() {
  default
  mv "gentoo-scripts" "${PN}-${PV}"
}

src_install() {
  chmod +x "scripts/${PN}"
	dosbin "scripts/${PN}"
}