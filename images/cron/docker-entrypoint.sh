#!/bin/sh
set -e

if [ "$TIMEZONE" ]; then
    echo "[I] Setting the time zone."
    cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    echo "$TIMEZONE" > /etc/timezone
fi

echo "[I] Creating cron job."
echo "$BACKUP_CRON_EXP /usr/local/bin/app-backup" > /etc/crontabs/root

echo "[I] Entrypoint tasks complete. Starting crond."
exec "$@"
