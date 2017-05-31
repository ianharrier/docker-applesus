FROM alpine:3.6

MAINTAINER Ian Harrier <github@harrier.us>

#-------------------------------------------------------------------------------
#  Python
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               python2

#-------------------------------------------------------------------------------
#  Margarita (https://github.com/jessepeterson/margarita)
#-------------------------------------------------------------------------------

WORKDIR /usr/local/margarita

RUN set -ex \
        && apk --no-cache add \
               git \
               py2-pip \
        && git clone https://github.com/jessepeterson/margarita.git . \
        && pip install flask \
        && git clone https://github.com/wdas/reposado.git /usr/local/reposado \
        && cp -R /usr/local/reposado/code/reposadolib reposadolib \
        && rm -rf /usr/local/reposado \
        && apk --no-cache del \
               git \
               py2-pip

COPY preferences.plist ./preferences.plist

EXPOSE 8089

CMD ["python","margarita.py"]

#-------------------------------------------------------------------------------
#  Scripts
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               tzdata

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN set -ex \
        && chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
