FROM golang:1.22 AS builder
WORKDIR "/src/app"

COPY .updater /src/app
RUN go build -trimpath -o /src/app/bin/updater /src/app/cmd/updater

FROM gentoo/stage3
WORKDIR "/src/updater"
ENTRYPOINT [ "/usr/local/bin/updater" ]

RUN emerge-webrsync
RUN emerge -v dev-vcs/git && ACCEPT_KEYWORDS="~amd64 ~arm64" emerge -v app-portage/pycargoebuild

COPY --from=builder /src/app/bin/updater /usr/local/bin/updater