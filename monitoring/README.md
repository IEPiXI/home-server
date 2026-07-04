# 📊 Monitoring & Dashboard

This stack provides a comprehensive monitoring solution and a beautiful starting dashboard for the home server.

## 🛠️ Services Included

* **[Homepage](https://gethomepage.dev/)**: A modern, highly customizable application dashboard with integrations for Docker.
* **[Uptime Kuma](https://github.com/louislam/uptime-kuma)**: A self-hosted monitoring tool that checks if services are up.


## ⚙️ Setup

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

The `.env` file requires the following configuration:

- `DOMAIN` — your base domain (e.g., `yourdomain.com`). This is used to automatically generate the links in the dashboard.
- `IMMICH_API_KEY` — an API key generated in your Immich instance to allow Homepage to fetch photo and video statistics.

## 🚀 Architecture

1. **Uptime Kuma** acts as the backend worker: it actively pings the services.
2. **Homepage** serves as the main entry point to the server. By connecting Homepage to Uptime Kuma's API, Homepage displays real-time service health directly on the dashboard.

## 🔄 Uptime Kuma Configuration

You must configure your monitors and status page manually in the Web UI:

### 1. Create Monitors
For each service you want to monitor, click **Add New Monitor**:
* **Monitor Type**: HTTP(s)
* **Friendly Name**: The name of your service (e.g., Nextcloud, Caddy)
* **URL**: The public URL of your service (e.g., `https://nextcloud.yourdomain.com`) or internal Docker URL (e.g., `http://caddy-proxy:80`)
* Save the monitor.

### 2. Create the Status Page (for Homepage Integration)
To integrate the statistics into the Homepage dashboard widget:
1. Click **Status Pages** at the top right of Uptime Kuma.
2. Click **New Status Page**.
3. **Name**: Whatever you like (e.g., `Home Server Status`).
4. **Slug**: `uptime` (this must exactly match the `homepage.widget.slug` label in `docker-compose.yml`).
5. Scroll down to the **Monitors** section and add all the monitors you just created.
6. Click **Save**.

Your Homepage dashboard will now automatically pull the live statistics from Uptime Kuma!
