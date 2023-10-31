# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# shellcheck shell=bash

EAPI=8

inherit desktop xdg

DESCRIPTION="Password Manager"
HOMEPAGE="https://1password.com"
SRC_URI="
	amd64? ( https://downloads.1password.com/linux/tar/stable/x86_64/${PN}-latest.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://downloads.1password.com/linux/tar/stable/aarch64/${PN}-latest.tar.gz -> ${P}-arm64.tar.gz )"

# This is a live package because there appears to be no version archives
# other than "latest".
PROPERTIES="live"
LICENSE="all-rights-reserved"
KEYWORDS="~amd64 ~arm64"
IUSE="policykit cli"
DEPEND="
x11-misc/xdg-utils
acct-group/1password
policykit? ( sys-auth/polkit )
cli? ( app-admin/op-cli-bin )
"
RDEPEND="${DEPEND}"
SLOT="0"

RESTRICT="bindist mirror strip"

QA_PREBUILT="usr/bin/${MY_PN}"

S="${WORKDIR}"

src_prepare() {
  default
  xdg_environment_reset
}

src_install() {
  mkdir -p "${D}/opt/1Password/"
  cp -ar "${S}/${PN}-"**"/"* "${D}/opt/1Password/" || die "Install failed!"

  chgrp onepassword "${D}/opt/1Password/1Password-BrowserSupport"
  dosym /opt/1Password/1password /usr/bin/1password
  dosym /opt/1Password/op-ssh-sign /usr/bin/op-ssh-sign

  domenu "${FILESDIR}/1password.desktop"
  newicon "${D}/opt/1Password/resources/icons/hicolor/512x512/apps/1password.png" "${PN}.png"
}

pkg_postinst() {
  chmod 4755 /opt/1Password/chrome-sandbox
  chmod 6755 /opt/1Password/1Password-KeyringHelper
  chmod 2755 /opt/1Password/1Password-BrowserSupport

  xdg_pkg_postinst
}

pkg_postrm() {
  xdg_icon_cache_update
  xdg_desktop_database_update
  xdg_mimeinfo_database_update
}
