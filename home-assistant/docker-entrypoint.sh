#!/bin/bash
set -e

CONFIG_FILE="/config/configuration.yaml"

mkdir -p /config

# Create default configuration.yaml if missing
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[home-assistant-entrypoint] Creating initial /config/configuration.yaml with reverse proxy settings..."
    cat << 'EOF' > "$CONFIG_FILE"
# Home Assistant Configuration

default_config:

# Reverse Proxy Configuration (Caddy)
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.16.0.0/12
    - 10.0.0.0/8
    - 192.168.0.0/16
    - 127.0.0.1
    - ::1
EOF
elif ! grep -q "use_x_forwarded_for" "$CONFIG_FILE" 2>/dev/null; then
    echo "[home-assistant-entrypoint] Injecting reverse proxy settings into /config/configuration.yaml..."
    cat << 'EOF' >> "$CONFIG_FILE"

# Reverse Proxy Configuration (Caddy)
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.16.0.0/12
    - 10.0.0.0/8
    - 192.168.0.0/16
    - 127.0.0.1
    - ::1
EOF
fi

# Execute Home Assistant original init process
exec /init "$@"
