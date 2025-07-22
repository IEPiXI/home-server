# How to use Vaultwarden with Back-Up

You will need the following files within this directory, in order to run the docker containers:

### For the **vaultwarden** container (see [Github-Repo](https://github.com/dani-garcia/vaultwarden))

-   `.env` file:

    ```
    DOMAIN=https://vaultwarden.your-domain.net
    ADMIN_TOKEN='$argon2id$v=19$m=65540,t=3,p=4$+......'
    ```

    In order to get a strong `ADMIN_TOKEN`, run the following and follow its instruction:

    ```
    docker run --rm -it vaultwarden/server:latest vaultwarden hash
    ```

### For the **vaultwarden-backup** container (see [Github-Repo](https://github.com/ttionya/vaultwarden-backup/tree/master))

-   `.env.backup` file :

    ```
    RCLONE_REMOTE_NAME=NAME_OF_RCLONE_BACKUP
    RCLONE_REMOTE_DIR=/vaultwarden_backup
    ZIP_PASSWORD=YourSecretPassword
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
docker exec vaultwarden_backup bash /app/backup.sh
```

For further instructions, also refer to the [vaultwarden-backup docs](https://github.com/ttionya/vaultwarden-backup/tree/master/docs), (e.g. for triggering [manual backups](https://github.com/ttionya/vaultwarden-backup/blob/master/docs/manually-trigger-a-backup.md))
