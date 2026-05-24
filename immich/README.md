# Immich

Self-hosted photo and video backup with automatic sync from iOS and macOS.

## Setup

You will need the following files in this directory:

- `.env` file:

    ```
    DATA_DIR=/home/data

    DB_HOSTNAME=immich-postgres
    DB_USERNAME=immich
    DB_PASSWORD=your_strong_password
    DB_DATABASE_NAME=immich

    REDIS_HOSTNAME=immich-redis
    ```

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
- **macOS**: Edit `immich-upload.sh` and set your domain and API key (Immich web UI → Account Settings → API Keys), then run:

    ```bash
    ./immich-upload.sh
    ```

    Uses [immich-go](https://github.com/simulot/immich-go) under the hood.

## Update

```bash
./update.sh
```
