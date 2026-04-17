#!/bin/bash
set -e

echo "Updating Vaultwarden..."
cd "$(dirname "$0")" || exit

docker compose pull
docker compose up -d
docker image prune -f

echo "Vaultwarden update complete."
