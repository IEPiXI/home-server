# 🌐 Caddy Reverse Proxy

This service acts as the central reverse proxy for the home server, automatically handling SSL certificates (including wildcards) using the Cloudflare DNS challenge.

## ⚙️ Configuration

Ensure you have a `.env` file in this directory with the following variables:

```env
DOMAIN=yourdomain.com
ACME_EMAIL=your_email@example.com
CLOUDFLARE_API_TOKEN=your_cloudflare_token
DATA_DIR=/path/to/your/data
```

* `DOMAIN`: Your root domain.
* `ACME_EMAIL`: Email address for Let's Encrypt registration.
* `CLOUDFLARE_API_TOKEN`: An API token from Cloudflare with `Zone:DNS:Edit` permissions.
* `DATA_DIR`: Directory on the host where Caddy will store certificates and configurations securely.

## 🚀 Usage

Start the reverse proxy:

```bash
docker compose up -d
```
