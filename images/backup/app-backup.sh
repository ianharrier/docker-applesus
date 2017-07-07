#!/bin/sh
set -e

TIMESTAMP=$(date +%Y%m%dT%H%M%S%z)
START_TIME=$(date +%s)

cd "$HOST_PATH"

if [ "$OPERATION" = "disable" ]; then
    echo "[W] Backups are disabled."
else
    if [ ! -d backups ]; then
        echo "[I] Creating backup directory."
        mkdir backups
    fi

    if [ -d backups/tmp_backup ]; then
        echo "[W] Cleaning up from a previously-failed execution."
        rm -rf backups/tmp_backup
    fi

    echo "[I] Creating working directory."
    mkdir -p backups/tmp_backup

    echo "[I] Backing up Reposado web directory."
    cp -a volumes/reposado/html backups/tmp_backup/html

    echo "[I] Backing up Reposado metadata."
    cp -a volumes/reposado/metadata backups/tmp_backup/metadata

    echo "[I] Compressing backup."
    tar -zcf backups/$TIMESTAMP.tar.gz -C backups/tmp_backup .

    echo "[I] Removing working directory."
    rm -rf backups/tmp_backup

    EXPIRED_BACKUPS=$(ls -1tr backups/*.tar.gz 2>/dev/null | head -n -$RETENTION)
    if [ "$EXPIRED_BACKUPS" ]; then
        echo "[I] Cleaning up expired backup(s):"
        for BACKUP in $EXPIRED_BACKUPS; do
            echo "      $BACKUP"
            rm "$BACKUP"
        done
    fi
fi

END_TIME=$(date +%s)

echo "[I] Script complete. Time elapsed: $((END_TIME-START_TIME)) seconds."
