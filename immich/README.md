# 📷 Immich

Self-hosted photo and video backup with automatic sync from iOS, macOS, and DJI cameras.

## ⚙️ Setup

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

The `.env` file requires the following for the Docker stack:

- `DATA_DIR` — directory on the host where Immich will store all data and databases
- `DB_PASSWORD` — change before first run (secure password for Postgres)
- `DB_HOSTNAME`, `DB_USERNAME`, `DB_DATABASE_NAME` — Postgres connection details (defaults are fine)
- `REDIS_HOSTNAME` — Redis connection hostname (default is fine)

Optionally, if you plan to use the upload scripts, you must also provide:

- `IMMICH_DOMAIN` — your Immich URL
- `IMMICH_API_KEY` — Immich web UI → Account Settings → API Keys

Create the host directories before first start:

```bash
mkdir -p $DATA_DIR/immich/{library,postgres,model-cache}
```

Then start the stack:

```bash
docker compose up -d
```

Open `https://immich.your-domain.net` and create your admin account.

## iOS / macOS sync

- **iOS**: Install the [Immich app](https://apps.apple.com/app/immich/id1660895792) → Settings → Backup
- **macOS**: Export photos via osxphotos to `~/Pictures/immich-export`, then upload:

    ```bash
    ./immich-upload.sh --apple
    ```

## DJI cameras (Osmo Action, drone)

1. Connect the camera via USB
2. Export files to `~/Pictures/dji-immich-export/` organized by `YYYY/MM/` (skips already-copied files):

    ```bash
    ./dji-export.sh
    ```

3. Upload to Immich:

    ```bash
    ./immich-upload.sh --dji
    ```

DJI assets are tagged `camera/DJI` and grouped into the **DJI Osmo Action** album. Only DNG + MP4 are uploaded (JPG duplicates and LRF proxy videos are skipped).

## Script reference

### dji-export.sh

Exports from connected DJI devices to a local folder. Paths can be overridden via flags or env vars:

```bash
./dji-export.sh [--dest /path] [--osmo-src /path] [--drone-src /path]

# or via env vars
DJI_EXPORT_DEST=~/Pictures/dji DJI_OSMO_SRC=/Volumes/OsmoAction/DCIM/DJI_001 ./dji-export.sh
```

### immich-upload.sh

Uploads a local folder to Immich. Uses [immich-go](https://github.com/simulot/immich-go).

```bash
./immich-upload.sh --apple [--upload-path /path]   # default: ~/Pictures/immich-export
./immich-upload.sh --dji   [--upload-path /path]   # default: ~/Pictures/dji-immich-export
```

## Update

```bash
./update.sh
```
