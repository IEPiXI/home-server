#!/bin/bash

# update home-assistant stack
echo "🔄 Updating Home Assistant..."
docker compose pull
docker compose up -d --remove-orphans
echo "✅ Home Assistant updated!"
