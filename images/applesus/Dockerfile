FROM debian:9

#-------------------------------------------------------------------------------
#  Apache
#-------------------------------------------------------------------------------

RUN set -ex \
        && apt-get update && apt-get -y install \
               apache2 \
        && sed -i 's/^ServerTokens .*/ServerTokens Prod/g' /etc/apache2/conf-available/security.conf \
        && sed -i 's/^ServerSignature .*/ServerSignature Off/g' /etc/apache2/conf-available/security.conf \
        && echo "ServerName localhost" >> /etc/apache2/apache2.conf \
        && ln -sf /dev/stdout /var/log/apache2/access.log \
        && ln -sf /dev/stderr /var/log/apache2/error.log \
        && rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------------------------------
#  Python
#-------------------------------------------------------------------------------

RUN set -ex \
        && apt-get update && apt-get -y install \
               libapache2-mod-wsgi \
               python \
        && rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------------------------------
#  Cron
#-------------------------------------------------------------------------------

RUN set -ex \
        && apt-get update && apt-get -y install \
               cron \
        && rm -f /etc/cron.*/* \
        && cat /dev/null > /etc/crontab \
        && rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------------------------------
#  Reposado (https://github.com/wdas/reposado)
#-------------------------------------------------------------------------------

ARG REPOSADO_VERSION

WORKDIR /usr/local/reposado

RUN set -ex \
        && apt-get update && apt-get -y install \
               curl \
               git \
        && git clone https://github.com/wdas/reposado.git . \
        && git checkout ${REPOSADO_VERSION} \
        && mkdir -p /srv/reposado/html /srv/reposado/metadata \
        && chgrp -R www-data /srv/reposado/html /srv/reposado/metadata \
        && chmod -R 775 /srv/reposado/html /srv/reposado/metadata \
        && apt-get -y purge --auto-remove \
               git \
        && rm -rf /var/lib/apt/lists/*

COPY preferences.plist ./code/preferences.plist

#-------------------------------------------------------------------------------
#  Margarita (https://github.com/jessepeterson/margarita)
#-------------------------------------------------------------------------------

ARG MARGARITA_VERSION

WORKDIR /usr/local/margarita

RUN set -ex \
        && apt-get update && apt-get -y install \
               git \
               python-pip \
        && git clone https://github.com/jessepeterson/margarita.git . \
        && git checkout ${MARGARITA_VERSION} \
        && pip install flask \
        && ln -s /usr/local/reposado/code/reposadolib ./reposadolib \
        && ln -s /usr/local/reposado/code/preferences.plist ./preferences.plist \
        && a2enmod rewrite ldap authnz_ldap \
        && apt-get -y purge --auto-remove \
               git \
               python-pip \
        && rm -rf /var/lib/apt/lists/*

COPY margarita.wsgi ./margarita.wsgi
COPY margarita.conf /etc/apache2/sites-available/000-default.conf

RUN set -ex \
        && chmod -R +r .

EXPOSE 80

#-------------------------------------------------------------------------------
#  Scripts
#-------------------------------------------------------------------------------

WORKDIR /

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
COPY app-backup.sh /usr/local/bin/app-backup
COPY reposado-purge.sh /usr/local/bin/reposado-purge
COPY reposado-sync.sh /usr/local/bin/reposado-sync

RUN set -ex \
        && chmod +x /usr/local/bin/app-backup \
        && chmod +x /usr/local/bin/docker-entrypoint \
        && chmod +x /usr/local/bin/reposado-purge \
        && chmod +x /usr/local/bin/reposado-sync

ENTRYPOINT ["docker-entrypoint"]
