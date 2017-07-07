#!/bin/sh
set -e

echo "[I] Creating cron job."
echo "$CRON_EXP /usr/local/reposado/code/repo_sync" > /var/spool/cron/crontabs/root

if [ "$TIMEZONE" ]; then
    echo "[I] Setting the time zone."
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    echo "$TIMEZONE" > /etc/timezone
fi

if [ "$(cat ./code/preferences.plist | grep URL_BASE_CHANGE_ME)" ]; then
    if [ "$URL_BASE" ]; then
        echo "[I] Setting the URL base."
        sed -i "s/URL_BASE_CHANGE_ME/$URL_BASE/g"
    else
        sed -i "s/URL_BASE_CHANGE_ME//g" ./code/preferences.plist
    fi
fi

echo "[I] Entrypoint tasks complete. Starting crond."
exec "$@"
