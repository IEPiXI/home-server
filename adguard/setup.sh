#!/bin/bash
set -e

cd "$(dirname "$0")" || exit

echo "========================================="
echo "   AdGuard Home Automated Setup Script   "
echo "========================================="

# check if .env exists
if [ ! -f ".env" ]; then
    echo "Error: .env file not found!"
    echo "Please copy .env.example to .env and fill in your details:"
    echo "  cp .env.example .env"
    exit 1
fi

# Source the .env file
source .env

# fix systemd-resolved (requires sudo)
echo "[1/4] Checking and freeing port 53 (systemd-resolved)..."
if systemctl is-active --quiet systemd-resolved; then
    if grep -q "#DNSStubListener=yes" /etc/systemd/resolved.conf || grep -q "DNSStubListener=yes" /etc/systemd/resolved.conf; then
        echo "  -> Updating /etc/systemd/resolved.conf to disable DNS stub..."
        sudo sed -i 's/#*DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
        sudo systemctl restart systemd-resolved
        echo "  -> systemd-resolved updated and restarted."
    else
        echo "  -> DNS stub already disabled."
    fi
else
    echo "  -> systemd-resolved is not active, skipping."
fi

# generate password hash
echo "[2/4] Generating secure password hash..."
if [ -z "$ADMIN_PASSWORD" ]; then
    echo "Error: ADMIN_PASSWORD is empty in .env!"
    exit 1
fi

# strip trailing carriage returns in .env
CLEAN_PW=$(echo -n "$ADMIN_PASSWORD" | tr -d '\r' | tr -d '\n')
HASH=$(docker run --rm httpd:alpine htpasswd -B -b -n -C 10 admin "$CLEAN_PW" | cut -d: -f2)

# escape the hash for sed
ESCAPED_HASH=$(printf '%s\n' "$HASH" | sed -e 's/[\/&]/\\&/g')

# generate AdGuardHome.yaml from template
echo "[3/4] Generating configuration file..."
sudo mkdir -p conf
sudo chown -R "$USER":"$USER" conf
sed -e "s/\${ADMIN_PASSWORD_HASH}/$ESCAPED_HASH/g" \
    -e "s/\${DOMAIN}/$DOMAIN/g" \
    -e "s/\${LAN_IP}/$LAN_IP/g" \
    conf/AdGuardHome.yaml.example > conf/AdGuardHome.yaml

echo "  -> conf/AdGuardHome.yaml generated successfully."

# start container
echo "[4/4] Starting AdGuard Home container..."
docker compose up -d

echo "========================================="
echo " Setup Complete! "
echo " Dashboard: http://$LAN_IP:3000"
echo " Username: admin"
echo " Don't forget to configure your router's DHCP to use $LAN_IP as the DNS server."
echo "========================================="
