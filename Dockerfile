# Used as the base image for elint and updater.
FROM gentoo/stage3
LABEL org.opencontainers.image.source="https://github.com/jaredallard/overlay"
WORKDIR "/src/updater"

# Install base packages
RUN <<EOF
  export MAKEOPTS="-j$(nproc)"
  export GENTOO_MIRRORS="https://gentoo.rgst.io/gentoo"

  emerge-webrsync
  emerge -v app-eselect/eselect-repository app-portage/eix dev-vcs/git

  eselect repository add jaredallard-overlay git https://git.rgst.io/jaredallard/overlay.git
  eix-sync

  # pycargoebuild for rust packages
  ACCEPT_KEYWORDS="~amd64 ~arm64" emerge -v app-portage/pycargoebuild
  emerge -v app-portage/gentoolkit
  # Speeds up pycargoebuild downloads
  emerge -v net-misc/aria2

  # Install mise for things that might need it.
  emerge -v dev-util/mise

  # Cleanup leftover stuff
  emerge --depclean
  eclean --deep packages && eclean --deep distfiles
EOF

ENV PATH="/root/.local/bin:/root/.local/share/mise/shims:${PATH}"

# Ensure mise works
RUN set -e; whoami; echo "$HOME"; mise --version