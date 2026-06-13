# 🌐 Caddy Reverse Proxy

Central reverse proxy for the home server, automatically handling SSL certificates (including wildcards) using the Cloudflare DNS challenge.

## ⚙️ Setup

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

The `.env` file covers the Caddy configuration and Let's Encrypt registration:

- `DOMAIN` — your root domain (e.g., yourdomain.com)
- `ACME_EMAIL` — email address for Let's Encrypt registration
- `CLOUDFLARE_API_TOKEN` — an API token from Cloudflare with `Zone:DNS:Edit` permissions
- `DATA_DIR` — directory on the host where Caddy will store certificates and configs

## Usage

Start the reverse proxy:

```bash
docker compose up -d
```
