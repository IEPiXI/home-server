# ☁️ Nextcloud AIO

Nextcloud All-in-One master container ([GitHub](https://github.com/nextcloud/all-in-one)) with Collabora ([GitHub](https://github.com/CollaboraOnline/online/tree/master/docker)) and Rclone backup.

## ⚙️ Setup

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

The `.env` file requires the following configuration:

**Nextcloud Settings:**
- `DOMAIN` — your root domain (e.g., yourdomain.com)
- `DATA_DIR` — directory on the host to securely store all Nextcloud data and databases

**Backup Settings:**
- `BACKUP_DIR` — directory on the host for local Nextcloud AIO backups
- `RCLONE_REMOTE_NAME` — name of the Rclone remote defined in your `rclone.conf`
- `RCLONE_REMOTE_DIR` — directory on the cloud remote to store backups

You will also need an `rclone.conf` file:

    ```
    [NAME_OF_RCLONE_BACKUP]
    type = <type>
    ...
    scope = <type>
    token = {...}
    ```

    In order to get the `rclone.conf` file, run the follow the instructions on the [rclone docs](https://rclone.org/) for your desired cloud provider.

### Manual Backup

After creating the **nextcloud-backup** container, you can test/trigger the backup with:

```
docker exec nextcloud-backup sh /usr/local/bin/backup.sh
```

## How to Start, Stop, and Update your NextCloud AIO instance via CLI

```
# Update mastercontainer
docker exec -it nextcloud-aio-mastercontainer sudo -u www-data php /var/www/docker-aio/php/src/Cron/UpdateMastercontainer.php

# Update then Start containers
docker exec -it nextcloud-aio-mastercontainer sudo -u www-data php /var/www/docker-aio/php/src/Cron/StartAndUpdateContainers.php

# Just start the containers
docker exec -it nextcloud-aio-mastercontainer sudo -u www-data php /var/www/docker-aio/php/src/Cron/StartContainers.php

# Stop containers
docker exec -it nextcloud-aio-mastercontainer sudo -u www-data php /var/www/docker-aio/php/src/Cron/StopContainers.php
```

## Useful OCC Commands

```bash
# Empty trash for all users
docker exec nextcloud-aio-nextcloud php occ trashbin:cleanup --all-users

# Rescan all files (after manual changes on disk)
docker exec nextcloud-aio-nextcloud php occ files:scan --all

# Set trashbin max retention to 30 days (prevents disk filling up from trash)
docker exec nextcloud-aio-nextcloud php occ config:app:set files_trashbin trashbin_retention_obligation --value="auto, 30"
```

## Update Expired Rclone Token

First stop the container:

```
docker compose down
sudo systemctl restart docker

```

Then run the reconnect rclone command to update the token, by following the instructions after running:

```
docker run --rm -it \
  -v "$(pwd):/config" \
  rclone/rclone:latest \
  config reconnect --config /config/rclone.conf OneDrive:
```

The restart the container:

```
docker compose up -d --force-recreate
```
