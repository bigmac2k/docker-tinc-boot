FROM ubuntu:21.10 as base
FROM base as build

RUN apt update && apt install -y tinc golang ca-certificates && go get -v github.com/reddec/tinc-boot/cmd/...

FROM base
COPY files/s6-overlay-v2.2.0.1-amd64-installer /s6-overlay-amd64-installer
COPY files/socklog-overlay-v3.1.2-0-amd64.tar.gz /socklog-overlay-amd64.tar.gz
RUN set -x \
  && chmod a+x /s6-overlay-amd64-installer \
  && /s6-overlay-amd64-installer / \
  && rm /s6-overlay-amd64-installer \
  && tar xzf /socklog-overlay-amd64.tar.gz -C / \
  && rm /socklog-overlay-amd64.tar.gz \
  && apt-get update \
  && apt-get install -y tinc iproute2 \
  && rm -rf /var/lib/apt/lists/*
COPY files/forward-stdout /etc/socklog.rules/forward-stdout

COPY --from=build /root/go/bin/tinc-boot /usr/local/bin/

COPY files/init.run /etc/cont-init.d/01-init.run
COPY files/tincdnet.run /etc/services.d/tincdnet/run
COPY files/tincboot.run /etc/services.d/tincboot/run

ENTRYPOINT ["/init"]
