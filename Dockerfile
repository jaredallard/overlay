# Used as the base image for elint and updater.
FROM gentoo/stage3
WORKDIR "/src/updater"

RUN emerge-webrsync && \
  emerge -v dev-vcs/git && \
  ACCEPT_KEYWORDS="~amd64 ~arm64" emerge -v app-portage/pycargoebuild && \
  emerge -v app-portage/gentoolkit && \
  eclean --deep packages && eclean --deep distfiles
