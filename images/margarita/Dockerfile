FROM ubuntu:16.04

MAINTAINER Ian Harrier <github@harrier.us>

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
#  Margarita (https://github.com/jessepeterson/margarita)
#-------------------------------------------------------------------------------

WORKDIR /usr/local/margarita

RUN set -ex \
        && apt-get update && apt-get -y install \
               git \
               python-pip \
        && git clone https://github.com/jessepeterson/margarita.git . \
        && pip install flask \
        && git clone https://github.com/wdas/reposado.git /usr/local/reposado \
        && cp -R /usr/local/reposado/code/reposadolib reposadolib \
        && rm -rf /usr/local/reposado \
        && a2enmod rewrite ldap authnz_ldap \
        && apt-get -y purge --auto-remove \
               git \
               python-pip \
        && rm -rf /var/lib/apt/lists/*

COPY preferences.plist ./preferences.plist
COPY margarita.wsgi ./margarita.wsgi
COPY margarita.conf /etc/apache2/sites-available/000-default.conf

RUN set -ex \
        && chmod +r ./margarita.wsgi

EXPOSE 80

CMD ["/usr/sbin/apachectl","-f","/etc/apache2/apache2.conf","-D","FOREGROUND"]

#-------------------------------------------------------------------------------
#  Scripts
#-------------------------------------------------------------------------------

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN set -ex \
        && chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
