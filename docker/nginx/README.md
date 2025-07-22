# How to use NGINX with [certbot](https://github.com/certbot/certbot) certificate

You will need the following files within this directory, in order to run the docker containers:

### For the [**nginx**](https://github.com/nginx/nginx) container and [**certbot**](https://github.com/certbot/certbot) container using [cloudflare](https://www.cloudflare.com/) auth token

-   `.env` file:

    ```
    DOMAIN=your-domain.net
    EMAIL=your-mail@provider.com
    CF_API_TOKEN=API_TOKEN
    ```

    In order to get the `API_TOKEN`:

    Go to the [CloudFlare dashboard](https://dash.cloudflare.com/) of you account > Navigate to `Manage Account` > Click `Account API Tokens` > Click `Create Token` > Click `Create Custom Token` and create a token with the following content:

    -   Token name: `ddns-your-domain.net` (doesn't really matter)
    -   Permissions:
        -   `Zone - Zone - Read`
        -   `Zone - DNS - Edit`
    -   Zone Resources:
        -   `Include - Specific Zone - your-domain.net`

    Then copy and store the `API_TOKEN` prompted.
