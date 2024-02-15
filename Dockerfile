FROM golang:1.22 AS builder
WORKDIR "/src/app"

COPY .updater /src/app
RUN go build -trimpath -o /src/app/bin/updater /src/app/cmd/updater

FROM gentoo/stage3
ENTRYPOINT [ "/usr/local/bin/updater" ]

RUN emerge-webrsync

# We use rust and cargo ebuild for some of the dependencies.
RUN emerge -v rust-bin && ACCEPT_KEYWORDS="~amd64" emerge -v cargo-ebuild
RUN emerge -v dev-vcs/git

COPY --from=builder /src/app/bin/updater /usr/local/bin/updater