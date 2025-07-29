#!/bin/sh

SOURCE_DIRECTORY="/backups/source"
LOCKFILE="/tmp/aio-lockfile"

RCLONE_CONFIG="${RCLONE_REMOTE_NAME}"
TARGET_DIRECTORY="${RCLONE_REMOTE_DIR}"

echo "------------------------------------"
echo "Starting rclone sync job at $(date)"

# Check if the source directory exists inside the container
if ! [ -d "$SOURCE_DIRECTORY" ]; then
    echo "Error: The source directory ($SOURCE_DIRECTORY) does not exist inside the container."
    exit 1
fi

# Check if the source directory is empty (prevents accidental deletion on remote)
if [ -z "$(ls -A "$SOURCE_DIRECTORY/")" ]; then
    echo "Error: The source directory is empty. Halting sync to prevent data loss."
    exit 1
fi

# Check for other backup lockfiles to avoid syncing during a backup
if [ -f "$SOURCE_DIRECTORY/lock.roster" ]; then
    echo "Info: Another backup is in progress (lock.roster exists). Skipping sync."
    exit 0
fi

# Check if a lockfile from a previous failed sync exists
if [ -f "$LOCKFILE" ]; then
    echo "Error: Stale lockfile found at $LOCKFILE. A previous sync may have failed."
    exit 1
fi

# Create lockfile to prevent multiple syncs at once
touch "$LOCKFILE"

echo "Syncing $SOURCE_DIRECTORY/ to $RCLONE_CONFIG:$TARGET_DIRECTORY"
if ! rclone sync --config /config/rclone/rclone.conf "$SOURCE_DIRECTORY/" "$RCLONE_CONFIG:$TARGET_DIRECTORY"; then
    echo "Error: Rclone sync failed."
    rm "$LOCKFILE"
    exit 1
fi

# Remove lockfile on success
rm "$LOCKFILE"

echo "Rclone sync successful!"
echo "Sync job finished at $(date)"
