#!/bin/sh

echo "--- Generating Nginx configuration from template... ---"
envsubst '\${DOMAIN}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

CERT_FILE="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
echo "--- Waiting for initial certificate at $CERT_FILE ---"
while [ ! -f "$CERT_FILE" ]; do
  echo "Certificate not found, sleeping 15s..."
  sleep 15
done
echo "--- Initial certificate found. ---"

(
  echo "--- Starting certificate monitoring loop. ---"
  while true; do
    OLD_MOD_TIME=$(stat -c %Y "$CERT_FILE")
    sleep 12h
    NEW_MOD_TIME=$(stat -c %Y "$CERT_FILE")

    if [ "$OLD_MOD_TIME" != "$NEW_MOD_TIME" ]; then
      echo "Certificate has been updated. Reloading Nginx."
      nginx -s reload
    else
      echo "Certificate unchanged. No action taken."
    fi
  done
) &

echo "--- Starting main Nginx process. ---"
exec nginx -g 'daemon off;'
