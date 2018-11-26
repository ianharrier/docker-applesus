#!/bin/sh
set -e

START_TIME=$(date +%s)

echo "[I] Running repo_sync."
/usr/local/reposado/code/repo_sync

echo "[I] Setting file permissions."
chgrp -R www-data /srv/reposado/html /srv/reposado/metadata
chmod -R 775 /srv/reposado/html /srv/reposado/metadata

END_TIME=$(date +%s)

echo "[I] Script complete. Time elapsed: $((END_TIME-START_TIME)) seconds."
