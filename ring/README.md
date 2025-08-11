# Ring Intercom Unlock Server

You will need the following file within this directory to run the `ring-server` container:

-   `.env` file:

    ```
    # A secure password of your choice to protect the /unlock endpoint
    UNLOCK_PASSWORD=your-strong-password

    # The name of your Location in the Ring app (e.g., "Home")
    LOCATION_NAME=Home

    # The name of your Intercom device in the Ring app (e.g., "Front Door")
    INTERCOM_NAME=Intercom

    # The refresh token from Ring (will be created by the auth script, can also be set manually)
    # RING_REFRESH_TOKEN=
    ```

To get the `RING_REFRESH_TOKEN`, first fill in the other variables, then run the interactive authentication script which will update this file for you:

```
docker compose run --rm ring-server npm run auth
```

## How to Start, Stop, and Use the Server

```
# Start the server in the background
docker compose up -d --build

# Stop the server
docker compose down

# View server logs
docker compose logs -f ring-server

# Trigger the unlock endpoint (replace with your domain or password)
curl -X GET -H "Authorization: Bearer your-strong-password" http://localhost:3000/unlock
```

**Note**: If the token expires, re-run the `auth` command and restart the container (`docker compose restart ring-server`)
