#!/usr/bin/env bash
set -uo pipefail

# Exports media from connected DJI devices to a local folder, organized by YYYY/MM.
# Skips files that already exist. Safe to re-run.
#
# Usage:
#   ./dji-export.sh [--dest /path] [--osmo-src /path] [--drone-src /path]
#
# Defaults can also be set via env vars:
#   DJI_EXPORT_DEST, DJI_OSMO_SRC, DJI_DRONE_SRC

DEST="${DJI_EXPORT_DEST:-$HOME/Pictures/dji-immich-export}"
OSMO_SRC="${DJI_OSMO_SRC:-/Volumes/OsmoAction/DCIM/DJI_001}"
DRONE_SRC="${DJI_DRONE_SRC:-/Volumes/DJI/DCIM/100MEDIA}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest)      DEST="$2";      shift 2 ;;
    --osmo-src)  OSMO_SRC="$2";  shift 2 ;;
    --drone-src) DRONE_SRC="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

copied=0
skipped=0
errors=0

copy_file() {
  local src="$1" dest_dir="$2" name
  name=$(basename "$src")
  mkdir -p "$dest_dir"
  if [ -f "$dest_dir/$name" ]; then
    skipped=$((skipped + 1))
  else
    if cp "$src" "$dest_dir/"; then
      copied=$((copied + 1))
    else
      echo "ERROR: $src" >&2
      errors=$((errors + 1))
    fi
  fi
}

echo "Dest:       $DEST"
echo "Osmo src:   $OSMO_SRC"
echo "Drone src:  $DRONE_SRC"
echo ""

# OsmoAction: DNG (RAW) + MP4 — date embedded in filename (DJI_YYYYMMDD...)
if [ -d "$OSMO_SRC" ]; then
  echo "Scanning OsmoAction..."
  for f in "$OSMO_SRC"/*.DNG "$OSMO_SRC"/*.MP4; do
    [ -f "$f" ] || continue
    date_part=$(basename "$f" | grep -oE '[0-9]{8}' | head -1)
    copy_file "$f" "$DEST/${date_part:0:4}/${date_part:4:2}"
  done
else
  echo "WARNING: OsmoAction not mounted at $OSMO_SRC"
fi

# DJI drone: JPG only — date from EXIF (no timestamp in filename)
if [ -d "$DRONE_SRC" ]; then
  echo "Scanning DJI drone..."
  for f in "$DRONE_SRC"/*.JPG; do
    [ -f "$f" ] || continue
    date_raw=$(sips -g all "$f" 2>/dev/null | awk '/creation:/{print $2}')
    year=$(echo "$date_raw" | cut -d: -f1)
    month=$(echo "$date_raw" | cut -d: -f2)
    if [ -z "$year" ] || [ -z "$month" ]; then
      echo "WARNING: could not read date from $(basename "$f"), skipping" >&2
      errors=$((errors + 1))
      continue
    fi
    copy_file "$f" "$DEST/$year/$month"
  done
else
  echo "WARNING: DJI drone not mounted at $DRONE_SRC"
fi

echo ""
echo "=== Results ==="
echo "  Copied:  $copied"
echo "  Skipped: $skipped (already existed)"
echo "  Errors:  $errors"
echo ""
echo "=== Files in $DEST ==="
find "$DEST" -type f ! -name ".*" | sed 's/.*\.//' | sort | uniq -c
echo ""
echo "=== Folder structure ==="
find "$DEST" -type d | sort
