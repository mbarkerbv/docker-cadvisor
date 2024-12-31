FROM golang:1.21-alpine AS builder

WORKDIR /usr/src/

RUN apk update --no-cache; \
    apk add --no-cache make git gcc musl-dev bash; \
    git clone https://github.com/google/cadvisor.git; \
    cd cadvisor; \
    make build;

FROM alpine:3.16

RUN apk update --no-cache; \
    apk add --no-cache wget musl

# Grab cadvisor from the staging directory.
COPY --from=builder /usr/src/cadvisor/_output/cadvisor /usr/bin/cadvisor

HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1

ENTRYPOINT ["/usr/bin/cadvisor", "-logtostderr"]
