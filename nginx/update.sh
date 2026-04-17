#!/bin/bash
set -e

echo "Updating NGINX..."
cd "$(dirname "$0")" || exit

docker compose pull
docker compose up -d
docker image prune -f

echo "NGINX update complete."
