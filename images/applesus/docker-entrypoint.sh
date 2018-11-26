#!/bin/sh
set -e

if [ "$TIMEZONE" ]; then
    echo "[I] Setting the time zone."
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    echo "$TIMEZONE" > /etc/timezone
fi

PREFERENCES_FILE=/usr/local/reposado/code/preferences.plist
if [ "$(cat $PREFERENCES_FILE | grep URL_BASE_CHANGE_ME)" ]; then
    if [ "$URL_BASE" ]; then
        echo "[I] Setting the URL base."
        sed -i "s/URL_BASE_CHANGE_ME/$URL_BASE/g" $PREFERENCES_FILE
    else
        echo "[I] Setting an empty URL base."
        sed -i "s/URL_BASE_CHANGE_ME//g" $PREFERENCES_FILE
    fi
fi

if [ "$@" = "cron" ]; then
    cd /usr/local/reposado

    echo "[I] Creating backup cron job."
    echo "$BACKUP_CRON_EXP root /usr/local/bin/app-backup >/proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/app-backup

    echo "[I] Creating sync cron job."
    echo "$SYNC_CRON_EXP root /usr/local/bin/reposado-sync >/proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/reposado-sync

    if [ "$PURGE_OPERATION" = "purge" ]; then
        echo "[I] Creating purge cron job."
        echo "$PURGE_CRON_EXP root /usr/local/bin/reposado-purge >/proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/reposado-purge
    fi

    echo "[I] Entrypoint tasks complete. Starting cron."
    exec /usr/sbin/cron -f
elif [ "$@" = "web" ]; then
    cd /usr/local/margarita

    CONFIG_FILE='/etc/apache2/sites-available/000-default.conf'
    if [ "$(cat $CONFIG_FILE | grep AUTH_INCOMPLETE)" ]; then
        if [ "$AUTH_TYPE" = 'ad' ]; then
            echo "[I] Enabling Active Directory authentication."
            sed -i '/BEGIN_NO_AUTH/,/END_NO_AUTH/d' $CONFIG_FILE
            sed -i '/BEGIN_AD_AUTH/d' $CONFIG_FILE
            sed -i '/END_AD_AUTH/d' $CONFIG_FILE
            sed -i "s|AUTH_AD_URL_CHANGE_ME|$AUTH_AD_URL|g" $CONFIG_FILE
            sed -i "s|AUTH_AD_BIND_USER_DN_CHANGE_ME|$AUTH_AD_BIND_USER_DN|g" $CONFIG_FILE
            sed -i "s|AUTH_AD_BIND_PASSWORD_CHANGE_ME|$AUTH_AD_BIND_PASSWORD|g" $CONFIG_FILE
            sed -i "s|AUTH_AD_ALLOWED_GROUP_DN_CHANGE_ME|$AUTH_AD_ALLOWED_GROUP_DN|g" $CONFIG_FILE
        else
            echo "[I] Disabling authentication."
            sed -i '/BEGIN_AD_AUTH/,/END_AD_AUTH/d' $CONFIG_FILE
            sed -i '/BEGIN_NO_AUTH/d' $CONFIG_FILE
            sed -i '/END_NO_AUTH/d' $CONFIG_FILE
        fi
        sed -i '/AUTH_INCOMPLETE/d' $CONFIG_FILE
    fi

    echo "[I] Entrypoint tasks complete. Starting Margarita."
    exec /usr/sbin/apachectl -f /etc/apache2/apache2.conf -D FOREGROUND
else
    echo "[E] Argument '$@' is not valid."
    exit 1
fi
