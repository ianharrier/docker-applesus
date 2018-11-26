#!/bin/sh
set -e

START_TIME=$(date +%s)

echo "[I] Purging deprecated products."
/usr/local/reposado/code/repoutil --purge-product all-deprecated

echo "[I] Setting file permissions."
chgrp -R www-data /srv/reposado/html /srv/reposado/metadata
chmod -R 775 /srv/reposado/html /srv/reposado/metadata

END_TIME=$(date +%s)

echo "[I] Script complete. Time elapsed: $((END_TIME-START_TIME)) seconds."
