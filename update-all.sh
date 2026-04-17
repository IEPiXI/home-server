#!/bin/bash
set -e

echo "======================================"
echo "Starting home-server update process..."
echo "======================================"

cd "$(dirname "$0")" || exit

echo ""
./nginx/update.sh

echo ""
./vaultwarden/update.sh

echo ""
./ring/update.sh

echo ""
./nextcloud-aio/update.sh

echo ""
echo "======================================"
echo "All services have been updated successfully!"
echo "======================================"
