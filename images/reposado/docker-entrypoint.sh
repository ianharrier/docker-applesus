#!/bin/sh
set -e

if [ "$TIMEZONE" ]; then
    echo "[I] Setting the time zone."
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    echo "$TIMEZONE" > /etc/timezone
fi

if [ "$(cat ./code/preferences.plist | grep URL_BASE_CHANGE_ME)" ]; then
    if [ "$URL_BASE" ]; then
        echo "[I] Setting the URL base."
        sed -i "s/URL_BASE_CHANGE_ME/$URL_BASE/g" ./code/preferences.plist
    else
        echo "[I] Setting an empty URL base."
        sed -i "s/URL_BASE_CHANGE_ME//g" ./code/preferences.plist
    fi
fi

echo "[I] Creating sync cron job."
echo "$SYNC_CRON_EXP /usr/local/bin/reposado-sync" > /var/spool/cron/crontabs/root

if [ "$PURGE_OPERATION" = "purge" ]; then
    echo "[I] Creating purge cron job."
    echo "$PURGE_CRON_EXP /usr/local/bin/reposado-purge" >> /var/spool/cron/crontabs/root
fi

echo "[I] Entrypoint tasks complete. Starting crond."
exec "$@"
