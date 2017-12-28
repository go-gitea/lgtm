FROM alpine:3.7
LABEL maintainer="The Gitea Authors"

EXPOSE 8000

RUN apk update && \
  apk add --no-cache \
  ca-certificates sqlite && \
  rm -rf /var/cache/apk/*

ENV DATABASE_DRIVER=sqlite3
ENV DATABASE_DATASOURCE=/var/lib/lgtm/lgtm.sqlite
ENV GODEBUG=netdns=go

ADD bin/lgtm /usr/bin/

ENTRYPOINT ["/usr/bin/lgtm"]
CMD ["server"]
