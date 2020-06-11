# Copyright 19992020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=7

PYTHON_COMPAT=(python3_{6,7,8})
inherit distutils-r1 readme.gentoo-r1

DESCRIPTION="Fast, local development for Kubernetes and OpenShift microservices"
HOMEPAGE="https://www.telepresence.io/"
LICENSE="Apache-2.0"
SLOT="0"

SRC_URI="https://github.com/telepresenceio/telepresence/archive/${PV}.tar.gz"

KEYWORDS="~amd64 ~x86"

RDEPEND="net-proxy/torsocks
  net-firewall/conntrack-tools
  net-fs/sshfs
  sys-cluster/kubernetes
  app-admin/sudo
"
DEPEND="dev-python/virtualenv"

S="${WORKDIR}/${PN}-${PV}"

src_compile() {
  DIST="./tmp"
  mkdir -p "$DIST"

  python3 packaging/build-telepresence.py "${DIST}/telepresence"
  python3 packaging/build-sshuttle.py "${DIST}/sshuttle-telepresence"
}

src_install() {
  dodoc README.md

  insinto "/usr/bin"
  doins "$DIST/telepresence"

  insinto "/usr/libexec"
  doins "$DIST/sshuttle-telepresence"

  #distutils-r1_python_install_all
}
