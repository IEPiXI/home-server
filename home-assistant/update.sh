#!/bin/bash
set -e

# update home-assistant stack
echo "🔄 Updating Home Assistant..."
cd "$(dirname "$0")" || exit

docker compose pull
docker compose up -d --build --remove-orphans
docker image prune -f
echo "✅ Home Assistant updated!"
