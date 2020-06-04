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

S=${WORKDIR}/${PN}-${PV}

src_compile() {
  ls
  distutils-r1_src_compile
}

python_install_all() {
  cd "${PN}-${PV}"
  dodoc README.md

  #newbashcomp ${PN}.bash-completion ${PN}
  #insinto /usr/share/zsh/site-functions
  #newins ${PN}.zsh _${PN}
  #insinto /usr/share/fish/vendor_completions.d
  #doins ${PN}.fish

  distutils-r1_python_install_all
}
