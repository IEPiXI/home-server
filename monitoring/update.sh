#!/bin/bash
set -e

# update monitoring stack
echo "🔄 Updating Monitoring Stack (Homepage & Uptime Kuma)..."
cd "$(dirname "$0")" || exit

docker compose pull
docker compose up -d --remove-orphans
docker image prune -f
echo "✅ Monitoring Stack updated!"
