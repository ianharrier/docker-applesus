#!/bin/sh
set -e

START_TIME=$(date +%s)

if [ ! -d .git ]; then
    echo "[E] This script needs to run from the top directory of the repo. Current working directory:"
    echo "      $(pwd)"
    exit 1
fi

echo "=== Shutting down web container. ==============================================="
docker-compose stop web

echo "=== Shutting down sync container. =============================================="
docker-compose stop sync

echo "=== Starting cron container. ==================================================="
docker-compose up -d cron

echo "=== Backing up application stack. =============================================="
docker-compose exec cron app-backup

echo "=== Removing currnet application stack. ========================================"
docker-compose down

echo "=== Pulling changes from repo. ================================================="
git pull

echo "=== Updating environment file. ================================================="
OLD_REPOSADO_VERSION=$(grep ^REPOSADO_VERSION= .env | cut -d = -f 2)
NEW_REPOSADO_VERSION=$(grep ^REPOSADO_VERSION= .env.template | cut -d = -f 2)
echo "[I] Upgrading Reposado from '$OLD_REPOSADO_VERSION' to '$NEW_REPOSADO_VERSION'."
OLD_MARGARITA_VERSION=$(grep ^MARGARITA_VERSION= .env | cut -d = -f 2)
NEW_MARGARITA_VERSION=$(grep ^MARGARITA_VERSION= .env.template | cut -d = -f 2)
echo "[I] Upgrading Margarita from '$OLD_MARGARITA_VERSION' to '$NEW_MARGARITA_VERSION'."
sed -i.bak -e "s/^REPOSADO_VERSION=.*/REPOSADO_VERSION=$NEW_REPOSADO_VERSION/g" -e "s/^MARGARITA_VERSION=.*/MARGARITA_VERSION=$NEW_MARGARITA_VERSION/g" .env

echo "=== Deleting old images. ======================================================="
IMAGE_WEB=$(docker images ianharrier/applesus -q)
docker rmi $IMAGE_WEB

echo "=== Building new images. ======================================================="
docker-compose build --pull --no-cache web

echo "=== Restoring application stack to most recent backup. ========================="
cd backups
LATEST_BACKUP=$(ls -1tr *.tar.gz 2> /dev/null | tail -n 1)
cd ..
./scripts/app-restore.sh $LATEST_BACKUP

END_TIME=$(date +%s)

echo "=== Upgrade complete. =========================================================="
echo "[I] Time elapsed: $((END_TIME-START_TIME)) seconds."
