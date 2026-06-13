#!/bin/bash
set -e

echo "Updating Caddy..."
cd "$(dirname "$0")" || exit

docker compose pull
docker compose up -d
docker image prune -f

echo "Caddy update complete."
