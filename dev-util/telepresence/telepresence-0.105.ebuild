# Copyright (c) 2020 Jared Allard
EAPI=6

inherit unpacker eutils

PYTHON_COMPAT=(python{3_5,3_6,3_7})
DESCRIPTION="Fast, local development for Kubernetes and OpenShift microservices"
HOMEPAGE="https://www.telepresence.io/"
LICENSE="Apache-2.0"
SLOT="0"

SRC_URI="https://github.com/telepresenceio/telepresence/archive/0.105.tar.gz"

KEYWORDS="~amd64 ~x86"

RDEPEND="net-proxy/torsocks
  net-firewall/conntrack-tools
  net-fs/sshfs
  sys-cluster/kubectl
  app-admin/sudo
"
DEPEND="dev-python/virtualenv"

S="${WORKDIR}"

src_install() {
  env PREFIX="${D}"./install.sh
}

