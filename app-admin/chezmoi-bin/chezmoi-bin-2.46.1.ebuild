# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# shellcheck shell=bash

EAPI=8

inherit unpacker

MY_PN="${PN%-bin}"

DESCRIPTION="Manage your dotfiles across multiple machines, securely."
HOMEPAGE="https://github.com/twpayne/chezmoi"
SRC_URI="
	amd64? ( https://github.com/twpayne/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_amd64.deb )
	arm? ( https://github.com/twpayne/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_armel.deb )
	arm64? ( https://github.com/twpayne/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_arm64.deb )
	ppc64? ( https://github.com/twpayne/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_ppc64.deb )
	x86? ( https://github.com/twpayne/${MY_PN}/releases/download/v${PV}/${MY_PN}_${PV}_linux_i386.deb )"

LICENSE="MIT"
KEYWORDS="amd64 arm arm64 ppc64 x86"
RDEPEND="dev-vcs/git"
SLOT="0"

RESTRICT="mirror"

QA_PREBUILT="usr/bin/${MY_PN}"

S="${WORKDIR}"

src_unpack() {
	unpack_deb "${A}"
}

src_install() {
	insinto /
	doins -r ./*

	fperms +x "/usr/bin/${MY_PN}"
}
