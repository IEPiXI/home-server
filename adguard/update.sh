#!/bin/bash
set -e

echo "Updating AdGuard Home..."
cd "$(dirname "$0")" || exit

docker compose pull
docker compose up -d
docker image prune -f

echo "AdGuard Home update complete."
