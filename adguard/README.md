# 🛡️ AdGuard Home

AdGuard Home serves as the local DNS server for the homenet, resolving subdomains locally and forwarding internet DNS queries.
This setup allows local services (like Vaultwarden, Nextcloud) to be reached directly via their domain name (`*.yourdomain.com`) over the local network instead of needing Tailscale while at home.

**🚫 Network-wide Ad Blocking:** By acting as your primary DNS server, AdGuard Home will also automatically block ads and tracking domains for all devices on your home network without needing browser extensions or individual apps. You can manage which blocklists are active in the **Filters -> DNS blocklists** section of the dashboard.

## ⚙️ Automated Setup

To make the installation as seamless as possible, an automated setup script is provided. It handles port 53 conflicts, password hashing, config generation, and starting the container.

1. **📝 Configure Environment:**
   Copy the example environment file:

    ```bash
    cp .env.example .env
    ```

    Edit `.env` and fill in your details:
    - `DOMAIN`: Your actual domain (e.g. `yourdomain.com`).
    - `LAN_IP`: The local IP of this server (e.g. `192.168.178.50`).
    - `ADMIN_PASSWORD`: Your desired admin dashboard password.

2. **🚀 Run Setup Script:**

    ```bash
    ./setup.sh
    ```

    _Note: The script uses `sudo` briefly to fix `systemd-resolved` (port 53 conflicts), so it might ask for your password._

3. **🎉 Success!**
   You can now log into your AdGuard Home dashboard at `http://<SERVER_IP>:3000`.

## 🌐 Router Setup

Update your router's DHCP settings to hand out this server's LAN IP address as the Primary DNS server. (e.g. In Fritzbox: Home Network -> Network -> Network Settings -> IPv4 Settings -> Local DNS Server).
