# 🏠 Home Server

This repository contains the configuration and docker-compose files for my home server infrastructure. It is composed of several independent services managed via Docker.

## 🛠️ Services

- **[☁️ Nextcloud AIO](./nextcloud-aio/README.md)**: Nextcloud All-in-One with Collabora and Rclone backups.
- **[🌐 Caddy](./caddy/README.md)**: Reverse proxy with automated SSL certificates via Caddy's built-in CertMagic and Cloudflare DNS.
- **[🔔 Ring Intercom Unlock Server](./ring/README.md)**: A server to control Ring Intercom devices.
- **[🔐 Vaultwarden](./vaultwarden/README.md)**: Bitwarden-compatible password manager server with Rclone backups.
- **[📷 Immich](./immich/README.md)**: Self-hosted photo and video backup with iOS and macOS sync.
- **[📊 Monitoring](./monitoring/README.md)**: Homepage visual dashboard and Uptime Kuma for service monitoring.
- **[🛡️ AdGuard](./adguard/README.md)**: Local DNS server for domain resolution and network-wide ad blocking.

## ⚙️ Management

### 🔄 Updating Services

You can update all services at once by running the provided script in the root directory:

```bash
./update-all.sh
```

Alternatively, each service directory has its own `update.sh` script to update them individually.

## 🚀 Getting Started

Please refer to the `README.md` within each service directory for specific setup instructions, environmental variables (`.env`), and backup configuration details:

- [☁️ Nextcloud AIO Instructions](./nextcloud-aio/README.md)
- [🌐 Caddy Instructions](./caddy/README.md)
- [🔔 Ring Server Instructions](./ring/README.md)
- [🔐 Vaultwarden Instructions](./vaultwarden/README.md)
- [📷 Immich Instructions](./immich/README.md)
- [📊 Monitoring Instructions](./monitoring/README.md)
- [🛡️ AdGuard Instructions](./adguard/README.md)
