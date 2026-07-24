# 🏡 Home Assistant

Home Assistant is a powerful, open-source home automation platform that focuses on local control and privacy. This stack runs in `host` network mode, allowing it to seamlessly auto-discover smart devices on your local network (like Shelly plugs) without complex network routing.

## 🔌 Shelly Power Monitoring

This specific setup is tailored to track the power usage of the server itself using a Shelly smart plug (e.g., Shelly Plug M Gen3). It tracks live power, energy, voltage, and current.

These metrics are then securely passed to the central **Homepage Dashboard** via Docker labels using a Long-Lived Access Token, giving you a beautiful live widget displaying your exact server power usage.

## ⚙️ Setup

1. **📝 Configure Environment:**
   Copy the example environment file:

    ```bash
    cp .env.example .env
    ```

    Edit `.env` and fill in your details:
    - `HOME_ASSISTANT_SERVER_IP`: The local IP of this server (e.g., `192.168.178.152`).
    - `HOME_ASSISTANT_TOKEN`: A Long-Lived Access Token generated from your Home Assistant user profile.
    - `HOME_ASSISTANT_SHELLY_*`: The exact Entity IDs of your Shelly sensors found in Home Assistant (e.g., `sensor.shelly_homeserver_power`).

2. **🚀 Run Container:**

    ```bash
    docker compose up -d
    ```

3. **🎉 Success!**
   You can log into your Home Assistant dashboard at `http://<SERVER_IP>:8123` to complete the initial setup, create an admin account, and configure your discovered Shelly plug.
