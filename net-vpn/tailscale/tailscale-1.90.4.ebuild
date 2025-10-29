# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module systemd tmpfiles

# These settings are obtained by running ./build_dist.sh shellvars in
# the upstream repo.
VERSION_MINOR="90"
VERSION_SHORT="1.90.4"
VERSION_LONG="1.90.4-t68cba300e"
VERSION_GIT_HASH="68cba300e4903d87f3f315e451fc70e67c58c8e6"

DESCRIPTION="Tailscale vpn client"
HOMEPAGE="https://tailscale.com"
SRC_URI="https://github.com/tailscale/tailscale/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${PV}/deps.tar.xz -> ${P}-deps.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~riscv ~x86"

RDEPEND="net-firewall/iptables"
BDEPEND=">=dev-lang/go-1.25"

RESTRICT="test"

# This translates the build command from upstream's build_dist.sh to an
# ebuild equivalent.
build_dist() {
  ego build \
    -ldflags "-X tailscale.com/version.longStamp=${VERSION_LONG} -X tailscale.com/version.shortStamp=${VERSION_SHORT}" \
    "$@"
}

src_compile() {
  build_dist ./cmd/tailscale
  build_dist ./cmd/tailscaled
}

src_install() {
  dosbin tailscaled
  dobin tailscale

  systemd_dounit cmd/tailscaled/tailscaled.service
  insinto /etc/default
  newins cmd/tailscaled/tailscaled.defaults tailscaled
  keepdir /var/lib/${PN}
  fperms 0750 /var/lib/${PN}

  newtmpfiles "${FILESDIR}/${PN}.tmpfiles" ${PN}.conf

  newinitd "${FILESDIR}/${PN}d.initd" ${PN}
  newconfd "${FILESDIR}/${PN}d.confd" ${PN}
}

pkg_postinst() {
  tmpfiles_process ${PN}.conf
}
