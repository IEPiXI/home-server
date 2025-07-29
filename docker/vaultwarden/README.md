# How to use Vaultwarden with Rclone Back-Up

You will need the following files within this directory, in order to run the **vaultwarden** container (see [Github-Repo](https://github.com/dani-garcia/vaultwarden)) and the **vaultwarden-backup** container (see [Github-Repo](https://github.com/ttionya/vaultwarden-backup/tree/master)):

-   `.env` file:

    ```
    # mainly for the vaultwarden container
    DOMAIN=https://vaultwarden.your-domain.net
    ADMIN_TOKEN='$argon2id$v=19$m=65540,t=3,p=4$+......'

    # mainly for the vaultwarden-backup container using rclone
    RCLONE_REMOTE_NAME=NAME_OF_RCLONE_BACKUP
    RCLONE_REMOTE_DIR=/backup/vaultwarden
    ZIP_PASSWORD=YourSecretPassword
    ```

    In order to get a strong `ADMIN_TOKEN`, run the following and follow its instruction:

    ```
    docker run --rm -it vaultwarden/server:latest vaultwarden hash
    ```

-   `rclone.conf` file:

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

### Manual Backup

After creating the **vaultwarden-backup** container, you can test/trigger the backup with:

```
docker exec vaultwarden-backup bash /app/backup.sh
```

For further instructions, also refer to the [vaultwarden-backup docs](https://github.com/ttionya/vaultwarden-backup/tree/master/docs), (e.g. for triggering [manual backups](https://github.com/ttionya/vaultwarden-backup/blob/master/docs/manually-trigger-a-backup.md))
