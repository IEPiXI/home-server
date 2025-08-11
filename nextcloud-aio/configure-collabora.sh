#!/bin/sh
set -e

NEXTCLOUD_CONTAINER="nextcloud-aio-nextcloud"

echo "Waiting for the Nextcloud container ($NEXTCLOUD_CONTAINER) to be ready..."

while [ "$(docker inspect -f '{{.State.Health.Status}}' $NEXTCLOUD_CONTAINER 2>/dev/null)" != "healthy" ]; do
    echo "Still waiting..."
    sleep 10
done

echo "✅ Nextcloud is ready."
echo "Configuring Collabora settings..."

docker exec --user www-data $NEXTCLOUD_CONTAINER php occ config:app:set richdocuments wopi_url --value="http://collabora-code:9980"

docker exec --user www-data $NEXTCLOUD_CONTAINER php occ config:app:set richdocuments public_wopi_url --value="https://office.${DOMAIN}"

docker exec --user www-data $NEXTCLOUD_CONTAINER php occ app:enable richdocuments

echo "🎉 Collabora configuration successfully applied."
