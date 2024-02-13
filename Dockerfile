FROM golang:1.21 AS builder
WORKDIR "/src/app"

COPY .updater /src/app
RUN go build -trimpath -o /src/app/bin/updater /src/app/cmd/updater

FROM gentoo/stage3
ENTRYPOINT [ "/usr/local/bin/updater" ]
RUN emerge-webrsync

COPY --from=builder /src/app/bin/updater /usr/local/bin/updater