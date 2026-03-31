# Copyright 2020-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit systemd

CONFIG_CHECK="~BRIDGE_NETFILTER ~CFS_BANDWIDTH ~CGROUP_DEVICE ~CGROUP_PERF ~CGROUP_PIDS ~IP_VS ~MEMCG ~NETFILTER_XT_MATCH_COMMENT ~OVERLAY_FS ~VLAN_8021Q ~VXLAN"

DESCRIPTION="Lightweight Kubernetes"
HOMEPAGE="https://k3s.io/"

# We can't version with "k3s" because it's not a valid prefix as per the
# Gentoo version format: https://projects.gentoo.org/pms/8/pms.html#x1-250003.2
REMOTE_PV="${PV/_p/+k3s}"

SRC_URI="
amd64? ( https://github.com/k3s-io/k3s/releases/download/v${REMOTE_PV}/k3s )
arm64? ( https://github.com/k3s-io/k3s/releases/download/v${REMOTE_PV}/k3s-arm64 )
arm?   ( https://github.com/k3s-io/k3s/releases/download/v${REMOTE_PV}/k3s-armhf )
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm64 ~arm"

S="${WORKDIR}"

IUSE="+kubectl-symlink btrfs systemd"
DEPEND="
  app-containers/slirp4netns
  app-misc/yq
  net-firewall/conntrack-tools
  btrfs? ( sys-fs/btrfs-progs )
  kubectl-symlink? ( !sys-cluster/kubectl )
"

RESTRICT="bindist test mirror strip"

QA_PREBUILT="*"

src_unpack() {
  local BIN_SUFFIX="-${ARCH}"
  if [[ "${ARCH}" == "amd64" ]]; then
    BIN_SUFFIX=""
  elif [[ "${ARCH}" == "arm" ]]; then
    BIN_SUFFIX="-armhf"
  fi

  cp "${DISTDIR}/k3s${BIN_SUFFIX}" "${WORKDIR}/k3s"
}

src_install() {
  dobin k3s 
  dobin "${FILESDIR}/k3s-killall.sh"

  use systemd && systemd_dounit "${FILESDIR}/k3s.service"
  use kubectl-symlink && dosym k3s /usr/bin/kubectl
}