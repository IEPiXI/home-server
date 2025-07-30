#!/bin/sh

# --- Configuration ---
SOURCE_DIRECTORY="/backups/source"
LOCKFILE="/tmp/aio-lockfile"

# Load environment variables
set -a
. /app/.env
set +a

# Set rclone target from environment variables
RCLONE_CONFIG="${RCLONE_REMOTE_NAME}"
TARGET_DIRECTORY="${RCLONE_REMOTE_DIR}"

# --- Helper Function ---

# Function to send notification to Nextcloud AIO and log to stdout
send_notification() {
    TITLE="$1"
    MESSAGE="$2"
    echo "Notification: $TITLE - $MESSAGE" # Log the notification message

    if docker ps --format "{{.Names}}" | grep -q "^nextcloud-aio-nextcloud$"; then
        docker exec -en nextcloud-aio-nextcloud bash /notify.sh "$TITLE" "$MESSAGE"
    else
        echo "Notification not sent: nextcloud-aio-nextcloud container not found."
    fi
}

# --- Main Script ---

echo "------------------------------------"
echo "Starting rclone sync job at $(date)"

# Check if the source directory exists inside the container
if ! [ -d "$SOURCE_DIRECTORY" ]; then
    send_notification "Rclone Sync Failed" "The source directory ($SOURCE_DIRECTORY) does not exist inside the container"
    exit 1
fi

# Check if the source directory is empty (prevents accidental deletion on remote)
if [ -z "$(ls -A "$SOURCE_DIRECTORY/")" ]; then
    send_notification "Rclone Sync Halted" "The source directory is empty. Halting sync to prevent data loss"
    exit 1
fi

# Check for other backup lockfiles to avoid syncing during a backup
if [ -f "$SOURCE_DIRECTORY/lock.roster" ]; then
    echo "Info: Another backup is in progress (lock.roster exists). Skipping sync."
    exit 0
fi

# Check if a lockfile from a previous failed sync exists
if [ -f "$LOCKFILE" ]; then
    send_notification "Rclone Sync Failed" "Stale lockfile found at $LOCKFILE. A previous sync may have failed"
    exit 1
fi

# Create lockfile to prevent multiple syncs at once
touch "$LOCKFILE"

echo "Syncing $SOURCE_DIRECTORY/ to $RCLONE_CONFIG:$TARGET_DIRECTORY"

# Execute rclone sync and check for failure
if ! rclone sync --config /config/rclone/rclone.conf "$SOURCE_DIRECTORY/" "$RCLONE_CONFIG:$TARGET_DIRECTORY"; then
    send_notification "Rclone Sync Failed" "Failed to synchronise the backup repository"
    rm "$LOCKFILE"
    exit 1
fi

# Remove lockfile on success
rm "$LOCKFILE"
send_notification "Rclone Sync Successful" "Synchronised the backup repository successfully"

echo "Rclone sync successful!"
echo "Sync job finished at $(date)"
