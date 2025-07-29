# How to use Nextcloud and Collabora with Rclone Back-Up

You will need the following files within this directory, in order to run the **Nextcloud-AIO** master container (see [Github-Repo](https://github.com/nextcloud/all-in-one)), the **Collabora** container (see [Github-Repo](https://github.com/CollaboraOnline/online/tree/master/docker)), and the **nextcloud-backup** container:

-   `.env` file:

    ```
    # mainly for the nextcloud-aio master container
    DOMAIN=your-domain.net
    DATA_DIR=/home/data
    BACKUP_DIR=/home/backup

    # mainly for the nextcloud-backup container
    RCLONE_REMOTE_NAME=NAME_OF_RCLONE_BACKUP
    RCLONE_REMOTE_DIR=/backup/nextcloud
    ```

-   `rclone.conf` file:

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