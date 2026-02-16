Cert management for nginx (Let's Encrypt)
======================================

This repository contains a small helper script to obtain and deploy TLS certificates into the nginx container.

Overview
--------
- `scripts/certbot_deploy.sh` provides three commands:
  - `obtain <domain> <email>`: use Certbot (host or docker) with webroot against `public/` to request a certificate.
  - `deploy <domain>`: copy existing PEM files into `./docker/nginx/certs` and reload nginx. You may set `SOURCE_DIR` environment variable to copy from an arbitrary export directory.
  - `renew`: run `certbot renew` (host) and attempt to deploy renewed certs.

How to use
----------
1. Make the script executable:

```bash
chmod +x scripts/certbot_deploy.sh
```

2. Obtain a certificate (requires port 80 reachable to Let's Encrypt):

```bash
# replace domain and email
./scripts/certbot_deploy.sh obtain your.domain.example you@example.com
```

3. If you use a Windows GUI tool like Certify The Web, export `fullchain.pem` and `privkey.pem` to a folder on the host and then:

```bash
SOURCE_DIR="/path/to/exported/certs" ./scripts/certbot_deploy.sh deploy your.domain.example
```

4. Restart or reload nginx if needed. The script will try to reload nginx in the `nginx` container.

Portability notes
-----------------
- The script works on other servers: it detects `certbot` and falls back to the `certbot/certbot` Docker image if available.
- For open-source distribution, the script does not assume host-specific paths — you may specify `SOURCE_DIR` when deploying exported certificates.

Security
--------
- Keep `docker/nginx/certs` out of version control (a `.gitignore` is included).
- The script sets `600` permissions on deployed PEM files.

If you want, I can add an example systemd timer or cron job for automatic renewal and deployment.
