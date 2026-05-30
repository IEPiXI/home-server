#!/usr/bin/env bash
set -euo pipefail

# Uploads photos/videos to Immich via immich-go
# Credentials live in .env (gitignored) — see .env.example for setup
#
# Usage:
#   ./immich-upload.sh --apple [--upload-path /path]
#   ./immich-upload.sh --dji   [--upload-path /path]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.env"

MODE=""
UPLOAD_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apple) MODE="apple"; shift ;;
    --dji)   MODE="dji";   shift ;;
    --upload-path) UPLOAD_PATH="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$MODE" ]]; then
  echo "Usage: $0 --apple|--dji [--upload-path /path]"
  exit 1
fi

if [[ "$MODE" == "apple" ]]; then
  UPLOAD_PATH="${UPLOAD_PATH:-$HOME/Pictures/immich-export}"
  EXTRA_FLAGS=(
    --manage-heic-jpeg StackCoverHeic
    --tag "camera/Apple"
  )
elif [[ "$MODE" == "dji" ]]; then
  UPLOAD_PATH="${UPLOAD_PATH:-$HOME/Pictures/dji-immich-export}"
  EXTRA_FLAGS=(
    --into-album "DJI Osmo Action"
    --tag "camera/DJI"
    --manage-burst Stack
  )
fi

echo "Mode:        $MODE"
echo "Upload path: $UPLOAD_PATH"
echo ""

immich-go upload from-folder \
  --server "$IMMICH_DOMAIN" \
  --api-key "$IMMICH_API_KEY" \
  --no-ui \
  --concurrent-tasks=20 \
  --client-timeout=60m \
  --pause-immich-jobs=true \
  --session-tag \
  --recursive \
  --on-errors=continue \
  "${EXTRA_FLAGS[@]}" \
  "$UPLOAD_PATH"
