# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module linux-info go-env unpacker

CONFIG_CHECK="~BRIDGE_NETFILTER ~CFS_BANDWIDTH ~CGROUP_DEVICE ~CGROUP_PERF ~CGROUP_PIDS ~IP_VS ~MEMCG ~NETFILTER_XT_MATCH_COMMENT ~OVERLAY_FS ~VLAN_8021Q ~VXLAN"

# These settings are obtained by running scripts/version.sh in the
# upstream repo.

### GIT_START ###
GIT_TAG="1.35.0+k3s3"
TREE_STATE="clean"
COMMIT="323b95245012f0d56a863d8c23964399814191c2"
### GIT_END ####

### VERSIONS_START ###
VERSION_CNIPLUGINS="v1.9.0-k3s1"
VERSION_CONTAINERD="v2.1.5-k3s1"
VERSION_FLANNEL_PLUGIN="v1.9.0-flannel1"
VERSION_GOLANG="go1.25.5"
VERSION_ROOT="v0.15.0"
VERSION_RUNC="v1.4.0"
### VERSIONS_END ###

DESCRIPTION="Lightweight Kubernetes"
HOMEPAGE="https://k3s.io/"

# We can't version with "k3s" because it's not a valid prefix as per the
# Gentoo version format: https://projects.gentoo.org/pms/8/pms.html#x1-250003.2
REMOTE_PV="${PV/_p/+k3s}"

SRC_URI="https://github.com/k3s-io/k3s/archive/v${REMOTE_PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${REMOTE_PV}/deps.tar.xz -> ${P}-deps.tar.xz"
SRC_URI+=" https://gentoo.rgst.io/updater_artifacts/${CATEGORY}/${PN}/${REMOTE_PV}/cni-plugins-deps.tar.xz -> ${P}-cni-plugins-deps.tar.xz"
SRC_URI+=" https://github.com/opencontainers/runc/archive/${VERSION_RUNC}.tar.gz -> ${P}-runc-${VERSION_RUNC}.tar.gz"
SRC_URI+=" https://github.com/k3s-io/containerd/archive/${VERSION_CONTAINERD}.tar.gz -> ${P}-containerd-${VERSION_CONTAINERD}.tar.gz"
SRC_URI+=" https://github.com/rancher/plugins/archive/${VERSION_CNIPLUGINS}.tar.gz -> ${P}-cniplugins.tar.gz"
SRC_URI+=" https://github.com/flannel-io/cni-plugin/archive/${VERSION_FLANNEL_PLUGIN}.tar.gz -> ${P}-flannel-plugin.tar.gz"

# Helm charts
SRC_URI+=" https://k3s.io/k3s-charts/assets/traefik-crd/traefik-crd-37.1.1+up37.1.0.tgz -> ${P}-traefik-crd-37.1.1+up37.1.0.tgz"
SRC_URI+=" https://k3s.io/k3s-charts/assets/traefik/traefik-37.1.1+up37.1.0.tgz -> ${P}-traefik-37.1.1+up37.1.0.tgz"

# k3s-root contains userspace binaries required for building, see:
# https://github.com/k3s-io/k3s-root
#
# TODO(jaredallard): Eventually build this from source as well.
SRC_URI+=" amd64? ( https://github.com/k3s-io/k3s-root/releases/download/${VERSION_ROOT}/k3s-root-amd64.tar )"
SRC_URI+=" arm64? ( https://github.com/k3s-io/k3s-root/releases/download/${VERSION_ROOT}/k3s-root-arm64.tar )"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 arm64"

IUSE="+kubectl-symlink"
DEPEND="
  app-misc/yq
  net-firewall/conntrack-tools
  sys-fs/btrfs-progs
"
BDEPEND=">=dev-lang/go-1.25"

RESTRICT="test"

PATCHES=(
  "${FILESDIR}/scripts-version.sh.patch"
)

src_unpack() {
  # https://github.com/k3s-io/k3s/blob/main/scripts/download#L9C1-L14
  local CHARTS_DIR="${S}/build/static/charts"
  local RUNC_DIR="${S}/build/src/github.com/opencontainers/runc"
  local CONTAINERD_DIR="${S}/build/src/github.com/containerd/containerd"
  local CNIPLUGINS_DIR="${T}/src/github.com/containernetworking/plugins"
  local FLANNEL_PLUGIN_DIR="${CNIPLUGINS_DIR}/plugins/meta/flannel"
  local DATA_DIR="${S}/build/data"

  # Unpack the k3s source then rename it to match what ${S} wants by
  # default.
  unpacker "${DISTDIR}"/*".tar.gz"
  mv "k3s-${REMOTE_PV/+/-}" "k3s-${PV}"

  mkdir -p "${CHARTS_DIR}" "${DATA_DIR}" "${CONTAINERD_DIR%/*}" "${RUNC_DIR%/*}" "${CNIPLUGINS_DIR%/*}"

  mv "${WORKDIR}/runc-${VERSION_RUNC/v/}" "${RUNC_DIR}" || die
  mv "${WORKDIR}/containerd-${VERSION_CONTAINERD/v/}" "${CONTAINERD_DIR}" || die
  mv "${WORKDIR}/plugins-${VERSION_CNIPLUGINS/v/}" "$CNIPLUGINS_DIR" || die

  # Copy over helm charts, which get embedded later.
  cp "${DISTDIR}/"*".tgz" "$CHARTS_DIR/" || die

  # Patch flannel-cni for cni-plugin, which gets built later as part of
  # the build process.
  rm -rf "${FLANNEL_PLUGIN_DIR}"
  mv "${WORKDIR}/cni-plugin-${VERSION_FLANNEL_PLUGIN/v/}" "${FLANNEL_PLUGIN_DIR}" || die
  sed -i 's/package main/package flannel/; s/func main/func Main/' "${FLANNEL_PLUGIN_DIR}/"*.go

  (
    set -eo pipefail
    # Emulates go-module_src_unpack, which we can't use because it calls
    # unpacker, which we're handling ourselves.
    GOFLAGS="${GOFLAGS} -p=$(makeopts_jobs)"

    cd "$CNIPLUGINS_DIR" || die
    unpack "${P}-cni-plugins-deps.tar.xz"
    GOMODCACHE="$CNIPLUGINS_DIR/go-mod" ego mod verify

    cd "$S" || die
    unpack "k3s-root-$ARCH.tar"
    unpack "${P}-deps.tar.xz"
    GOMODCACHE="${S}/go-mod" ego mod verify
  ) || die

  export GOMODCACHE="${S}/go-mod"
  go-env_set_compile_environment

  # Patch git_version.sh to return hardcoded variables instead of trying
  # to detect them from a git repository.
  cat >"$S/scripts/git_version.sh" <<EOF
GIT_TAG='$GIT_TAG'
TREE_STATE='$TREE_STATE'
COMMIT='$COMMIT'
EOF
}

src_compile() {
  # Build cni-plugin, this also makes ./scripts/build not attempt to
  # clone this repo during build time.
  (
    set -eo pipefail
    local CNIPLUGINS_DIR="${T}/src/github.com/containernetworking/plugins"
    local FLANNEL_PLUGIN_DIR="${CNIPLUGINS_DIR}/plugins/meta/flannel"
    export GOMODCACHE="$CNIPLUGINS_DIR/go-mod"
    
    source ./scripts/version.sh
    local BINDIR="${S}/bin"
    cd "$CNIPLUGINS_DIR" || die
    # https://github.com/k3s-io/k3s/blob/main/scripts/build#L173C5-L173C164
    GO111MODULE=off GOPATH="${T}" CGO_ENABLED=0 ego build -tags "$TAGS" -gcflags="all=${GCFLAGS}" -ldflags "$VERSIONFLAGS $STATIC" -o "${BINDIR}/cni"
  ) || die

  export GOMODCACHE="${S}/go-mod"

  export VERSION_GOLANG
  ./scripts/build || die
  ./scripts/package-cli || die
}

src_install() {
  # https://github.com/k3s-io/k3s/blob/main/scripts/package-cli#L63-L70
  local BIN_SUFFIX="-${ARCH}"
  if [[ "${ARCH}" == "amd64" ]]; then
    BIN_SUFFIX=""
  elif [[ "${ARCH}" == "arm" ]]; then
    BIN_SUFFIX="-armhf"
  elif [[ "${ARCH}" == "s390x" ]]; then
    BIN_SUFFIX="-s390x"
  fi

  newbin "dist/artifacts/k3s${BIN_SUFFIX}" k3s
  use kubectl-symlink && dosym k3s /usr/bin/kubectl
}