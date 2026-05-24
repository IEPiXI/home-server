#!/usr/bin/env bash
set -euo pipefail

# Local one-shot sync script, e.g. from macOS using immich-go

# Change these after Immich is running and you have an API key
# (Immich web UI → Account Settings → API Keys)
IMMICH_DOMAIN="https://immich.your-domain.net"
IMMICH_API_KEY="your_api_key_here"
UPLOAD_PATH=~/Pictures/immich-export

immich-go upload from-folder \
  --server "$IMMICH_DOMAIN" \
  --api-key "$IMMICH_API_KEY" \
  --concurrent-tasks=20 \
  --client-timeout=60m \
  --pause-immich-jobs=true \
  --session-tag \
  --recursive \
  --manage-burst Stack \
  --on-errors=continue \
  --manage-heic-jpeg StackCoverHeic \
  "$UPLOAD_PATH"
