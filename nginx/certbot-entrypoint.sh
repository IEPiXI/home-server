#!/bin/sh

DOMAIN_NAME="$DOMAIN"
CERT_FILE="/etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem"
CLOUDFLARE_CREDS_FILE="/root/cloudflare.ini"

if [ ! -f "$CLOUDFLARE_CREDS_FILE" ]; then
  echo "🔎 Cloudflare credentials file not found. Creating it..."
  echo "dns_cloudflare_api_token = $CF_API_TOKEN" > "$CLOUDFLARE_CREDS_FILE"
  chmod 600 "$CLOUDFLARE_CREDS_FILE"
  echo "✅ Credentials file created and secured."
else
  echo "👍 Cloudflare credentials file already exists."
fi

if [ -f "$CERT_FILE" ]; then
  echo "✅ Certificate found for $DOMAIN_NAME, starting renewal checks."
else
  echo "🔎 Certificate not found for $DOMAIN_NAME, attempting to obtain one."
  # use --staging for testing purposes (dont use for production)
  certbot certonly \
    -n \
    --agree-tos \
    --no-eff-email \
    --dns-cloudflare \
    --dns-cloudflare-credentials "$CLOUDFLARE_CREDS_FILE" \
    --email "$EMAIL" \
    --domains "$DOMAIN_NAME,*.$DOMAIN_NAME,*.local.$DOMAIN_NAME"
fi

echo "🔄 Starting Certbot renewal script..."
while :; do
  echo "Checking for certificate renewal..."
  certbot renew --quiet
  echo "Check complete. Sleeping for 12 hours."
  sleep 12h
done
