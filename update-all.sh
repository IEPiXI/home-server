#!/bin/bash
set -e

echo "======================================"
echo "Starting home-server update process..."
echo "======================================"

cd "$(dirname "$0")" || exit

echo ""
./adguard/update.sh

echo ""
./caddy/update.sh

echo ""
./vaultwarden/update.sh

echo ""
./ring/update.sh


echo ""
./immich/update.sh

echo ""
./monitoring/update.sh

echo ""
./nextcloud-aio/update.sh

echo ""
echo "======================================"
echo "All services have been updated successfully!"
echo "======================================"
