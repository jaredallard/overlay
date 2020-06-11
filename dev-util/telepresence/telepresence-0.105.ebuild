# Copyright 19992020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=7

PYTHON_COMPAT=(python3_{6,7,8})
inherit distutils-r1 readme.gentoo-r1

DESCRIPTION="Fast, local development for Kubernetes and OpenShift microservices"
HOMEPAGE="https://www.telepresence.io/"
LICENSE="Apache-2.0"
SLOT="0"
RESTRICT=network-sandbox

SRC_URI="https://github.com/telepresenceio/telepresence/archive/${PV}.tar.gz"

KEYWORDS="~amd64 ~x86"

RDEPEND="net-proxy/torsocks
  net-firewall/conntrack-tools
  net-fs/sshfs
  <sys-fs/fuse-3
  sys-cluster/kubernetes
  app-admin/sudo
"
DEPEND="dev-python/virtualenv"

S="${WORKDIR}/${PN}-${PV}"

src_compile() {
  python3 packaging/build-telepresence.py "tmp/telepresence"
  python3 packaging/build-sshuttle.py "tmp/sshuttle-telepresence"
}

src_install() {
  dodoc README.md

  insinto "/usr/bin"
  doins "tmp/telepresence"
  chmod +x "$D/usr/bin/telepresence"

  insinto "/usr/libexec"
  doins "tmp/sshuttle-telepresence"
  chmod +x "$D/usr/libexec/sshuttle-telepresence"

  #distutils-r1_python_install_all
}
