# Used as the base image for elint and updater.
FROM gentoo/stage3
WORKDIR "/src/updater"

RUN export MAKEOPTS="-j$(nproc)" && \
  emerge-webrsync && \
  emerge -v dev-vcs/git && \
  ACCEPT_KEYWORDS="~amd64 ~arm64" emerge -v app-portage/pycargoebuild && \
  emerge -v app-portage/gentoolkit && \
  eclean --deep packages && eclean --deep distfiles

# Install mise for things that might need it.
RUN curl https://mise.run | sh
ENV PATH="/root/.local/bin:/root/.local/share/mise/shims:${PATH}"
RUN set -e; whoami; echo $HOME; mise --version