# importing xx for cross-compilation
FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx
# use a builder image for building cloudflare
FROM --platform=$BUILDPLATFORM golang:1.24.4 AS builder
COPY --from=xx / /
ENV GO111MODULE=on \
  CGO_ENABLED=0 \
  # the CONTAINER_BUILD envvar is used set github.com/cloudflare/cloudflared/metrics.Runtime=virtual
  # which changes how cloudflared binds the metrics server
  CONTAINER_BUILD=1

WORKDIR /go/src/github.com/cloudflare/cloudflared/

# copy our sources into the builder image
COPY . .

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set the x86-64 microarchitecture level (if present)
RUN if [[ "${TARGETARCH}${TARGETVARIANT}" == amd64v* ]]; then \
      export GOAMD64="${TARGETVARIANT}"; \
    fi && \
    # compile cloudflared
    GOOS="${TARGETOS}" GOARCH="${TARGETARCH}" make cloudflared

# use scratch as base
FROM scratch

LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

# copy SSL certs
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# copy our compiled binary
COPY --from=builder --chown=65532:65532 /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

# run as nonroot user
# We need to use numeric user id's because Kubernetes doesn't support strings:
# https://github.com/kubernetes/kubernetes/blob/v1.33.2/pkg/kubelet/kuberuntime/security_context_others.go#L49
# The `nonroot` user maps to `65532`, from: https://github.com/GoogleContainerTools/distroless/blob/main/common/variables.bzl#L18
USER 65532:65532

# command / entrypoint of container
ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
