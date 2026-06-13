# 🔔 Ring Intercom Unlock Server

A server to control Ring Intercom devices and expose an unlock endpoint.

## ⚙️ Setup

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

The `.env` file requires the following variables:

- `UNLOCK_PASSWORD` — a secure password of your choice to protect the /unlock endpoint
- `LOCATION_NAME` — the name of your Location in the Ring app (e.g., "Home")
- `INTERCOM_NAME` — the name of your Intercom device in the Ring app (e.g., "Front Door")
- `RING_REFRESH_TOKEN` — the refresh token from Ring (leave blank initially)

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
