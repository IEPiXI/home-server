#!/bin/bash
# This is a mock script to simulate the behavior of ring-auth-cli for testing purposes

echo "This CLI will provide you with a refresh token which you can use to configure ring-client-api and homebridge-ring."
echo -n "Email: "
read
echo -n "Password: "
read -s
echo ""
echo "Please enter the code sent to +49xxxxxxxx25 via sms"
echo -n "2fa Code: "
read

# test error: echo "error: access_denied"
# test error: echo "406 Not Acceptable"
echo "Successfully logged in to Ring. Please add the following to your config:"
echo ""
echo '"refreshToken": "FAKE_TOKEN_FOR_TESTING_PURPOSES_1234567890"'
echo ""
