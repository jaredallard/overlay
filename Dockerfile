# Used as the base image for elint and updater.
FROM gentoo/stage3
LABEL org.opencontainers.image.source="https://github.com/jaredallard/overlay"
WORKDIR "/src/updater"

RUN export MAKEOPTS="-j$(nproc)" && \
  export GENTOO_MIRRORS="https://gentoo.rgst.io/gentoo" && \
  emerge-webrsync && \
  emerge -v app-eselect/eselect-repository app-portage/eix && \
  eselect repository enable gentoo && \
  rm -rf /var/db/repos/gentoo && \
  eix-sync && \
  emerge -v dev-vcs/git net-misc/aria2 && \
  ACCEPT_KEYWORDS="~amd64 ~arm64" emerge -v app-portage/pycargoebuild && \
  emerge -v app-portage/gentoolkit && \
  eclean --deep packages && eclean --deep distfiles

# Install mise for things that might need it.
RUN curl https://mise.run | sh
ENV PATH="/root/.local/bin:/root/.local/share/mise/shims:${PATH}"
RUN set -e; whoami; echo "$HOME"; mise --version