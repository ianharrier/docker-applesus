#!/bin/sh
set -e

START_TIME=$(date +%s)

if [ ! -d .git ]; then
    echo "[E] This script needs to run from the top directory of the repo. Current working directory:"
    echo "      $(pwd)"
    exit 1
fi

if [ ! $1 ]; then
    echo "[E] Specify the name of a backup file to restore. Example:"
    echo "      $0 20170501T031500+0000.tar.gz"
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

echo "[I] Shutting down and removing application stack."
docker-compose down &>/dev/null

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

echo "[I] Creating and starting application stack."
docker-compose up -d &>/dev/null

echo "[I] Removing working directory."
rm -rf backups/tmp_restore

END_TIME=$(date +%s)

echo "[I] Script complete. Time elapsed: $((END_TIME-START_TIME)) seconds."
