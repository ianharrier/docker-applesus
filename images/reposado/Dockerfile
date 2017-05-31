FROM alpine:3.6

MAINTAINER Ian Harrier <github@harrier.us>

#-------------------------------------------------------------------------------
#  Python
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               python2

#-------------------------------------------------------------------------------
#  Reposado (https://github.com/wdas/reposado)
#-------------------------------------------------------------------------------

WORKDIR /usr/local/reposado

RUN set -ex \
        && apk --no-cache add \
               curl \
               git \
        && git clone https://github.com/wdas/reposado.git . \
        && apk --no-cache del \
               git

COPY preferences.plist ./code/preferences.plist

#-------------------------------------------------------------------------------
#  Scripts
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               tzdata

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN set -ex \
        && chmod +x /usr/local/bin/docker-entrypoint

CMD ["crond","-f","-L","/dev/stdout"]

ENTRYPOINT ["docker-entrypoint"]
