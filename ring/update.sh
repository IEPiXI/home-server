#!/bin/bash
set -e

echo "Updating Ring Intercom Unlock Server..."
cd "$(dirname "$0")" || exit

docker compose pull
docker compose up -d --build
docker image prune -f

echo "Ring Intercom update complete."
