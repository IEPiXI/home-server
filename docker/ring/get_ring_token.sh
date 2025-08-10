#!/bin/bash

handle_cancel() {
  echo ""
  echo ""
  echo "------------------------------------------------------------------"
  echo ""
  echo "🛑 Cancelling script execution..." >&2
  exit 130
}

trap handle_cancel INT

RING_API_VERSION="11.7.1"
ENV_FILE=".env"
TOKEN_VAR_NAME="RING_REFRESH_TOKEN"

echo "--- RUNNING Authentication ---"
echo ""
echo "Starting Ring authentication process..."
echo "The script will now launch the official ring-auth-cli."
echo "Please follow the prompted instructions and have your 2FA device ready."
echo ""
echo "------------------------------------------------------------------"
echo ""

# For testing purposes and avoiding temporary IP bans you can also mock the authentication process
# AUTH_OUTPUT=$(./mock_ring_auth_cli.sh 2>&1 | tee /dev/tty)

# Check if ring-auth-cli is installed
if command -v ring-auth-cli >/dev/null 2>&1; then
    echo "✅ Found pre-installed ring-auth-cli. Using it directly to run the script..."
    echo ""
    echo "------------------------------------------------------------------"
    echo ""
    AUTH_OUTPUT=$(ring-auth-cli 2>&1 | tee /dev/tty)
else
    echo "ring-auth-cli not found. Using npx to install it and run the script..."
    echo ""
    echo "------------------------------------------------------------------"
    echo ""
    AUTH_OUTPUT=$(npx --yes -p ring-client-api@"$RING_API_VERSION" ring-auth-cli 2>&1 | tee /dev/tty)
fi

echo ""
echo "------------------------------------------------------------------"
echo ""


# Check for Wrong Credentials
if echo "$AUTH_OUTPUT" | grep -q "error: access_denied"; then
    echo ""
    echo "------------------------------------------------------------------"
    echo ""
    echo "Error: Received 'Access denied' from Ring's servers." >&2
    echo "Verify that your email and password are correct, and try again." >&2
    echo ""
    exit 1
fi

# Check for blocked IP address
if echo "$AUTH_OUTPUT" | grep -q "406 Not Acceptable"; then
    echo ""
    echo "------------------------------------------------------------------"
    echo ""
    echo "Error: Received '406 Not Acceptable' from Ring's servers." >&2
    echo "This means your IP address has been temporarily blocked by Ring, due to too many login attempts." >&2
    echo "Please try again later, or try running this script from a different network." >&2
    echo ""
    exit 1
fi

# Check the exit code of the command to see if it failed for other reasons
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo ""
    echo "------------------------------------------------------------------"
    echo ""
    echo "Error: The command did not complete successfully." >&2
    echo "This could be due to incorrect credentials, a network issue, or cancellation." >&2
    echo ""
    exit 1
fi

echo ""
echo "------------------------------------------------------------------"
echo ""
echo "Authentication process finished. Extracting token..."
echo ""
echo "------------------------------------------------------------------"
echo ""


# Extract the refresh token from the captured output
REFRESH_TOKEN=$(echo "$AUTH_OUTPUT" | grep '"refreshToken":' | sed -e 's/.*"refreshToken": "//' -e 's/"//g' | tr -d '[:space:]')


# Check if the token was successfully extracted
if [ -z "$REFRESH_TOKEN" ]; then
    echo "Error: Could not find the refresh token in the output." >&2
    echo "Authentication may have failed silently. Please review the output above for errors." >&2
    exit 1
fi

echo "Token successfully extracted."

# Check if the .env file exists and update/add the token
if [ -f "$ENV_FILE" ]; then
    if grep -q "^$TOKEN_VAR_NAME=" "$ENV_FILE"; then
        sed "s|^$TOKEN_VAR_NAME=.*|$TOKEN_VAR_NAME=$REFRESH_TOKEN|" "$ENV_FILE" > "$ENV_FILE.tmp" && mv "$ENV_FILE.tmp" "$ENV_FILE"
        echo "Updated $TOKEN_VAR_NAME in $ENV_FILE."
    else
        echo "" >> "$ENV_FILE"
        echo "$TOKEN_VAR_NAME=$REFRESH_TOKEN" >> "$ENV_FILE"
        echo "Added $TOKEN_VAR_NAME to $ENV_FILE."
    fi
else
    echo "$TOKEN_VAR_NAME=$REFRESH_TOKEN" > "$ENV_FILE"
    echo "Created $ENV_FILE and saved the token."
fi

echo "✅ All done! Your Ring refresh token is saved in the $ENV_FILE file."
echo ""
