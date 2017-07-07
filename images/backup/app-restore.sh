#!/bin/sh
set -e

START_TIME=$(date +%s)

cd "$HOST_PATH"

if [ ! $1 ]; then
    echo "[E] Specify the name of a backup file to restore. Example:"
    echo "      docker-compose exec backup app-restore 20170501T031500+0000.tar.gz"
    exit 1
fi

if [ ! -e "backups/$1" ]; then
    echo "[E] The file '$1' does not exist."
    exit 1
fi

if [ -d backups/tmp_restore ]; then
    echo "[W] Cleaning up from a previously-failed restore."
    rm -rf backups/tmp_restore
fi

BACKUP_FILE="$1"

echo "[I] Creating working directory."
mkdir -p backups/tmp_restore

echo "[I] Shutting down and removing web container."
docker-compose stop web &>/dev/null
docker-compose rm --force web &>/dev/null

echo "[I] Shutting down and removing sync container."
docker-compose stop sync &>/dev/null
docker-compose rm --force sync &>/dev/null

echo "[I] Removing Reposado persistent data."
rm -rf volumes/reposado/html volumes/reposado/metadata

echo "[I] Extracting backup."
tar -xf "backups/$BACKUP_FILE" -C backups/tmp_restore

if [ ! -d volumes/reposado ]; then
    mkdir -p volumes/reposado
fi

echo "[I] Restoring Reposado web directory."
mv backups/tmp_restore/html volumes/reposado/html/

echo "[I] Restoring Reposado metadata."
mv backups/tmp_restore/metadata volumes/reposado/metadata/

echo "[I] Creating and starting sync container."
docker-compose up -d sync &>/dev/null

echo "[I] Creating and starting web container."
docker-compose up -d web &>/dev/null

echo "[I] Removing working directory."
rm -rf backups/tmp_restore

END_TIME=$(date +%s)

echo "[I] Script complete. Time elapsed: $((END_TIME-START_TIME)) seconds."
