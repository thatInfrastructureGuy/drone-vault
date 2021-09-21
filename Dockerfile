FROM golang as build

WORKDIR /app

COPY go.sum go.mod .

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -a -tags netgo -ldflags '-w -extldflags "-static"' \
    -o publish/bin *.go

FROM build as test-image

RUN go test ./... -v -cover

FROM scratch as runner

COPY --from=build /etc/ssl/certs /etc/ssl/certs
COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=build /app/publish/bin /drone-vault

ENTRYPOINT ["/drone-vault"]
