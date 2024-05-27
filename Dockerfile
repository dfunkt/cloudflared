# importing xx for cross-compilation
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx
# use a builder image for building cloudflare
FROM --platform=$BUILDPLATFORM golang:1.22.2 as builder
COPY --from=xx / /
ENV GO111MODULE=on \
    CGO_ENABLED=0

COPY .teamcity/install-cloudflare-go.sh .
RUN ./install-cloudflare-go.sh

WORKDIR /go/src/github.com/cloudflare/cloudflared/

# copy our sources into the builder image
COPY . .

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# installing make for cross-compilation
# compile cloudflared
RUN if [[ "${TARGETARCH}${TARGETVARIANT}" == amd64v* ]]; then \
      export GOAMD64="${TARGETVARIANT}"; \
    fi && \
    PATH="/tmp/go/bin:$PATH" GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" make cloudflared

# use scratch as base
FROM scratch

LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

# copy SSL certs
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# copy our compiled binary
COPY --from=builder --chown=65532 /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

# run as non-privileged user
USER 65532

# command / entrypoint of container
ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
