# 🔐 Vaultwarden

Bitwarden-compatible password manager server ([GitHub](https://github.com/dani-garcia/vaultwarden)) with automated Rclone backups ([GitHub](https://github.com/ttionya/vaultwarden-backup/tree/master)).

## ⚙️ Setup

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

The `.env` file requires the following configuration:

**Vaultwarden Settings:**

- `DOMAIN` — your FULL Vaultwarden URL (e.g., https://vaultwarden.yourdomain.com)
- `DATA_DIR` — directory on the host to securely store the vault database
- `ADMIN_TOKEN` — secure token to access the `/admin` diagnostic panel

**Backup Settings:**

- `RCLONE_REMOTE_NAME` — name of the Rclone remote defined in your `rclone.conf`
- `RCLONE_REMOTE_DIR` — directory on the cloud remote to store backups
- `ZIP_PASSWORD` — secure password used to encrypt the backup archives

To generate a strong `ADMIN_TOKEN`, run the following command and follow the instructions:

    ```
    docker run --rm -it vaultwarden/server:latest vaultwarden hash
    ```

- `rclone.conf` file:

    ```
    [NAME_OF_RCLONE_BACKUP]
    type = <type>
    ...
    scope = <type>
    token = {...}
    ```

    In order to get the `rclone.conf` file, run the following and follow the instructions:

    ```
    docker run --rm -it \
    -v ./rclone:/config/ \
    ttionya/vaultwarden-backup:latest rclone config
    ```

    For further instructions, also refer to the [rclone docs](https://rclone.org/), (e.g. for [setting up GDrive](https://rclone.org/drive/#making-your-own-client-id))

## Backup

## Manual Backup

After creating the **vaultwarden-backup** container, you can test/trigger the backup with:

```
docker exec vaultwarden-backup bash /app/backup.sh
```

For further instructions, also refer to the [vaultwarden-backup docs](https://github.com/ttionya/vaultwarden-backup/tree/master/docs), (e.g. for triggering [manual backups](https://github.com/ttionya/vaultwarden-backup/blob/master/docs/manually-trigger-a-backup.md))

## Restore Backup

To restore your Vaultwarden instance from a backup, use the `restore-vaultwarden.sh` script:

1. **Download Backup**: First, retrieve the desired backup `.zip` file from your Rclone remote storage (Gdrive, etc.) and place it on the server
2. **Run Restore**: Execute the script `restore-vaultwarden.sh` with `sudo`, providing the full path to your downloaded backup file

    ```
    sudo ./restore-vaultwarden.sh /path/to/your/backup.zip
    ```

3. **Confirm**: The script will prompt for confirmation before stopping the container and replacing the data

## Update Expired Rclone Token

Check the REAMDME.md from nextloud-aio for further instructions, and copy the the updated rclone config.

Being in the vaultwarden directory, run:

```
cp ../nextcloud-aio/rclone.conf ./rclone.conf
```
