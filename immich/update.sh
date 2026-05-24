#!/bin/bash
set -e

echo "Updating Immich..."
cd "$(dirname "$0")" || exit

docker compose pull
docker compose up -d
docker image prune -f

echo "Immich update complete."
