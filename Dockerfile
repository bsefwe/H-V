FROM alpine:edge

RUN apk update && \
    apk add --no-cache ca-certificates go git tor wget && \
    wget -qO- https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip | busybox unzip - && \
    chmod +x /v2ray /v2ctl && \
    go get -u github.com/caddyserver/xcaddy/cmd/xcaddy && \
    ~/go/bin/xcaddy build --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive && \
    mv caddy /usr/sbin/ && \
    rm -rf /var/cache/apk/*

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh