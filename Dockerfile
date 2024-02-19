# Used as the base image for elint and updater.
FROM gentoo/stage3
WORKDIR "/src/updater"
ENTRYPOINT [ "/usr/local/bin/updater" ]

RUN emerge-webrsync
RUN emerge -v dev-vcs/git && ACCEPT_KEYWORDS="~amd64 ~arm64" emerge -v app-portage/pycargoebuild