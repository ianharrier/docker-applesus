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
        && mkdir -p /srv/reposado/html /srv/reposado/metadata \
        && chgrp -R 33 /srv/reposado/html /srv/reposado/metadata \
        && chmod -R 775 /srv/reposado/html /srv/reposado/metadata \
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
COPY reposado-sync.sh /usr/local/bin/reposado-sync

RUN set -ex \
        && chmod +x /usr/local/bin/docker-entrypoint \
        && chmod +x /usr/local/bin/reposado-sync

CMD ["crond","-f","-L","/dev/stdout"]

ENTRYPOINT ["docker-entrypoint"]
