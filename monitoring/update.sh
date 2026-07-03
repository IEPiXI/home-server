#!/bin/bash

# update monitoring stack
echo "🔄 Updating Monitoring Stack (Homepage & Uptime Kuma)..."
docker compose pull
docker compose up -d --remove-orphans
echo "✅ Monitoring Stack updated!"
