#!/bin/bash
set -e

echo "Updating Nextcloud AIO..."
cd "$(dirname "$0")" || exit

echo "Stopping containers..."
docker compose pull
docker compose up -d --remove-orphans
docker exec nextcloud-aio-mastercontainer sudo -u www-data php /var/www/docker-aio/php/src/Cron/StopContainers.php

echo "Updating master container..."
docker exec nextcloud-aio-mastercontainer sudo -u www-data php /var/www/docker-aio/php/src/Cron/UpdateMastercontainer.php || true

echo "Waiting for master container to restart (60s)..."
sleep 60

echo "Updating and starting containers..."
docker exec nextcloud-aio-mastercontainer sudo -u www-data php /var/www/docker-aio/php/src/Cron/StartAndUpdateContainers.php

echo "Nextcloud AIO update complete."
