#!/bin/sh
set -e

START_TIME=$(date +%s)

echo "=== Shutting down web container. ==============================================="
docker-compose stop web

echo "=== Shutting down sync container. =============================================="
docker-compose stop sync

echo "=== Starting backup container. ================================================="
docker-compose up -d backup

echo "=== Backing up application stack. =============================================="
docker-compose exec backup app-backup

echo "=== Removing currnet application stack. ========================================"
docker-compose down

echo "=== Pulling changes from repo. ================================================="
git pull

echo "=== Updating environment file. ================================================="
OLD_REPOSADO_VERSION=$(grep ^REPOSADO_VERSION= .env | cut -d = -f 2)
NEW_REPOSADO_VERSION=$(grep ^REPOSADO_VERSION= .env.template | cut -d = -f 2)
echo "[I] Upgrading Reposado from '$OLD_REPOSADO_VERSION' to '$NEW_REPOSADO_VERSION'."
sed -i.bak "s/^REPOSADO_VERSION=.*/REPOSADO_VERSION=$NEW_REPOSADO_VERSION/g" .env
OLD_MARGARITA_VERSION=$(grep ^MARGARITA_VERSION= .env | cut -d = -f 2)
NEW_MARGARITA_VERSION=$(grep ^MARGARITA_VERSION= .env.template | cut -d = -f 2)
echo "[I] Upgrading Margarita from '$OLD_MARGARITA_VERSION' to '$NEW_MARGARITA_VERSION'."
sed -i.bak "s/^MARGARITA_VERSION=.*/MARGARITA_VERSION=$NEW_MARGARITA_VERSION/g" .env

echo "=== Deleting old images. ======================================================="
IMAGE_BACKUP=$(docker images ianharrier/applesus-backup -q)
IMAGE_SYNC=$(docker images ianharrier/reposado -q)
IMAGE_WEB=$(docker images ianharrier/margarita -q)
docker rmi $IMAGE_BACKUP $IMAGE_SYNC $IMAGE_WEB

echo "=== Building new images. ======================================================="
docker-compose build --pull

echo "=== Starting backup container. ================================================="
docker-compose up -d backup

echo "=== Restoring application stack to most recent backup. ========================="
cd backups
LATEST_BACKUP=$(ls -1tr *.tar.gz 2> /dev/null | tail -n 1)
cd ..
docker-compose exec backup app-restore $LATEST_BACKUP

END_TIME=$(date +%s)

echo "=== Upgrade complete. =========================================================="
echo "[I] Time elapsed: $((END_TIME-START_TIME)) seconds."
