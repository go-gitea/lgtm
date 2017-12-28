FROM hypriot/rpi-alpine-scratch:edge
LABEL maintainer="The Gitea Authors"

EXPOSE 8000

RUN apk update && \
  apk add \
    ca-certificates \
    sqlite && \
  rm -rf \
    /var/cache/apk/*

ENV DATABASE_DRIVER=sqlite3
ENV DATABASE_DATASOURCE=/var/lib/lgtm/lgtm.sqlite
ENV GODEBUG=netdns=go

ENTRYPOINT ["/usr/bin/lgtm"]
CMD ["server"]

ADD bin/lgtm /usr/bin/
