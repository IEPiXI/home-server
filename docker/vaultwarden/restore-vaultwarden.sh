#!/bin/bash

set -e

CONTAINER_NAME="vaultwarden"
DATA_UID=1000
DATA_GID=1000

if [ -z "$1" ]; then
    echo "❌ Error: No backup file specified."
    echo "Usage: sudo ./restore_vaultwarden.sh /path/to/your/backup.zip"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: Backup file not found at '$BACKUP_FILE'"
    exit 1
fi

if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found in the current directory."
    exit 1
fi

if ! command -v unzip >/dev/null 2>&1 || ! command -v docker >/dev/null 2>&1; then
    echo "❌ Error: 'unzip' and 'docker' commands must be installed."
    exit 1
fi

export $(grep -v '^#' .env | xargs)

if [ -z "$DATA_DIR" ] || [ -z "$ZIP_PASSWORD" ]; then
    echo "❌ Error: DATA_DIR or ZIP_PASSWORD is not set in your .env file."
    exit 1
fi

VAULT_DATA_PATH="${DATA_DIR}/vaultwarden"

echo "⚠️  This script will restore Vaultwarden from the backup: $BACKUP_FILE"
echo "This involves stopping the container, replacing data, and restarting."
echo ""
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo ""
case "$REPLY" in
  [yY]) ;;
  *) echo "Restore aborted by user."; exit 0 ;;
esac

echo "▶️ Starting restore process..."

TMP_DIR=$(mktemp -d)
echo "  [1/8] Created temporary directory at $TMP_DIR"

echo "  [2/8] Stopping Vaultwarden container..."
docker stop "$CONTAINER_NAME"

mkdir -p "$VAULT_DATA_PATH"

echo "  [3/8] Backing up current data..."
if [ -n "$(ls -A "$VAULT_DATA_PATH")" ]; then
    OLD_DATA_BACKUP_PATH="${VAULT_DATA_PATH}/bak.$(date +%F_%H-%M-%S)"
    echo "      -> Moving current data to '$OLD_DATA_BACKUP_PATH'"
    mkdir -p "$OLD_DATA_BACKUP_PATH"
    find "$VAULT_DATA_PATH" -maxdepth 1 -mindepth 1 -not -path "$OLD_DATA_BACKUP_PATH" -exec mv -t "$OLD_DATA_BACKUP_PATH" {} +
else
    echo "      (Info: No existing data to back up.)"
fi

echo "  [4/8] Extracting backup zip to temporary directory..."
unzip -o -P "$ZIP_PASSWORD" "$BACKUP_FILE" -d "$TMP_DIR"

echo "  [5/8] Renaming and moving restored files into place..."

DB_BACKUP=$(find "$TMP_DIR" -maxdepth 1 -name 'db.*.sqlite3' -print -quit)
ATTACH_BACKUP=$(find "$TMP_DIR" -maxdepth 1 -name 'attachments.*.tar' -print -quit)
SENDS_BACKUP=$(find "$TMP_DIR" -maxdepth 1 -name 'sends.*.tar' -print -quit)
RSA_BACKUP=$(find "$TMP_DIR" -maxdepth 1 -name 'rsakey.*.tar' -print -quit)

if [ -n "$DB_BACKUP" ]; then
    echo "    -> Restoring database..."
    mv "$DB_BACKUP" "$VAULT_DATA_PATH/db.sqlite3"
fi

if [ -n "$ATTACH_BACKUP" ]; then
    echo "    -> Restoring attachments..."
    tar -xf "$ATTACH_BACKUP" -C "$VAULT_DATA_PATH"
fi

if [ -n "$SENDS_BACKUP" ]; then
    echo "    -> Restoring sends..."
    tar -xf "$SENDS_BACKUP" -C "$VAULT_DATA_PATH"
fi

if [ -n "$RSA_BACKUP" ]; then
    echo "    -> Restoring RSA key..."
    tar -xf "$RSA_BACKUP" -C "$VAULT_DATA_PATH"
fi

echo "  [6/8] Setting correct file permissions..."
chown -R "$DATA_UID":"$DATA_GID" "$VAULT_DATA_PATH"

echo "  [7/8] Starting Vaultwarden container..."
docker start "$CONTAINER_NAME"

echo "  [8/8] Cleaning up temporary files..."
rm -rf "$TMP_DIR"

echo ""
echo "✅ Restore complete!"
echo "Your Vaultwarden instance has been fully restored."
if [ -d "$OLD_DATA_BACKUP_PATH" ]; then
    echo "A backup of your previous data is saved inside your vaultwarden folder at: $OLD_DATA_BACKUP_PATH"
fi
