FROM alpine:3.8

#-------------------------------------------------------------------------------
#  Python
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               python2

#-------------------------------------------------------------------------------
#  Reposado (https://github.com/wdas/reposado)
#-------------------------------------------------------------------------------

ARG REPOSADO_VERSION

WORKDIR /usr/local/reposado

RUN set -ex \
        && apk --no-cache add \
               curl \
               git \
        && git clone https://github.com/wdas/reposado.git . \
        && git checkout ${REPOSADO_VERSION} \
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
COPY reposado-purge.sh /usr/local/bin/reposado-purge
COPY reposado-sync.sh /usr/local/bin/reposado-sync

RUN set -ex \
        && chmod +x /usr/local/bin/docker-entrypoint \
        && chmod +x /usr/local/bin/reposado-purge \
        && chmod +x /usr/local/bin/reposado-sync

CMD ["crond","-f","-L","/dev/stdout"]

ENTRYPOINT ["docker-entrypoint"]
