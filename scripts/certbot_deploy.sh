#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/certbot_deploy.sh obtain example.com you@example.com
#   ./scripts/certbot_deploy.sh deploy example.com    # copy existing live cert to project and reload nginx
#   ./scripts/certbot_deploy.sh renew                 # run certbot renew and deploy on success

PROJECT_DIR=$(cd "$(dirname "$0")/.." && pwd)
PUBLIC_DIR="$PROJECT_DIR/public"
CERTS_DIR="$PROJECT_DIR/docker/nginx/certs"

# Portable behavior:
# - If `certbot` exists on the host, it will be used for `obtain` and `renew`.
# - If `certbot` is missing but `docker` is available, the official Certbot docker image will be used.
# - `deploy` can copy from any source directory (useful for Certify The Web exports).

ensure_dirs() {
  mkdir -p "$PUBLIC_DIR/.well-known/acme-challenge"
  mkdir -p "$CERTS_DIR"
}

copy_and_reload() {
  local domain=$1
  local live_dir="/etc/letsencrypt/live/$domain"
  if [ ! -r "$live_dir/fullchain.pem" ] || [ ! -r "$live_dir/privkey.pem" ]; then
    echo "Error: expected certs in $live_dir (fullchain.pem/privkey.pem)" >&2
    return 1
  fi
  cp "$live_dir/fullchain.pem" "$CERTS_DIR/fullchain.pem"
  cp "$live_dir/privkey.pem" "$CERTS_DIR/privkey.pem"
  chmod 600 "$CERTS_DIR/fullchain.pem" "$CERTS_DIR/privkey.pem"
  echo "Copied certs to $CERTS_DIR"

  # Try to reload nginx inside docker-compose; fallback to restart
  if docker-compose exec -T nginx nginx -s reload 2>/dev/null; then
    echo "nginx reloaded"
  else
    echo "Reload failed, restarting nginx container"
    docker-compose restart nginx
  fi
}

cmd_obtain() {
  local domain=$1
  local email=$2
  ensure_dirs
  # Prefer host certbot
  if command -v certbot >/dev/null 2>&1; then
    echo "Using host certbot to request certificate for $domain (webroot: $PUBLIC_DIR)"
    certbot certonly --webroot -w "$PUBLIC_DIR" -d "$domain" --email "$email" --agree-tos --non-interactive
    copy_and_reload "$domain"
    return
  fi

  # Fallback: use dockerized certbot if docker available
  if command -v docker >/dev/null 2>&1; then
    echo "Host certbot not found — using dockerized certbot image to request certificate for $domain"
    docker run --rm \
      -v "$PUBLIC_DIR":/data/letsencrypt \
      -v "/etc/letsencrypt":/etc/letsencrypt \
      -v "/var/lib/letsencrypt":/var/lib/letsencrypt \
      certbot/certbot certonly --webroot -w /data/letsencrypt -d "$domain" --email "$email" --agree-tos --non-interactive
    copy_and_reload "$domain"
    return
  fi

  echo "Error: neither host certbot nor docker is available. Install certbot or docker." >&2
  exit 1
}

cmd_deploy() {
  local domain=$1
  ensure_dirs
  # Allow copying from an arbitrary source dir using optional env var SOURCE_DIR.
  if [ -n "${SOURCE_DIR:-}" ]; then
    if [ -r "$SOURCE_DIR/fullchain.pem" ] && [ -r "$SOURCE_DIR/privkey.pem" ]; then
      echo "Copying from SOURCE_DIR=$SOURCE_DIR"
      cp "$SOURCE_DIR/fullchain.pem" "$CERTS_DIR/fullchain.pem"
      cp "$SOURCE_DIR/privkey.pem" "$CERTS_DIR/privkey.pem"
      chmod 600 "$CERTS_DIR/fullchain.pem" "$CERTS_DIR/privkey.pem"
      echo "Copied certs to $CERTS_DIR"
      if docker-compose exec -T nginx nginx -s reload 2>/dev/null; then
        echo "nginx reloaded"
      else
        echo "Reload failed, restarting nginx container"
        docker-compose restart nginx
      fi
      return
    else
      echo "SOURCE_DIR specified but does not contain fullchain.pem/privkey.pem" >&2
      exit 1
    fi
  fi

  copy_and_reload "$domain"
}

cmd_renew() {
  ensure_dirs
  if ! command -v certbot >/dev/null 2>&1; then
    echo "certbot not found. Please install certbot on the host before running this script." >&2
    exit 1
  fi

  # Run renew and if any certs were renewed, the deploy hook below will copy and reload.
  certbot renew --deploy-hook "/bin/bash '$PROJECT_DIR/scripts/certbot_deploy.sh' deploy \$(/bin/grep -Po \"Primary host: \\K.*\" /etc/letsencrypt/renewal/* 2>/dev/null || true)" || true
  echo "Renew attempted. If certs were renewed, they were deployed."
}

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 {obtain <domain> <email>|deploy <domain>|renew}" >&2
  exit 1
fi

cmd=$1; shift
case "$cmd" in
  obtain)
    [ "$#" -eq 2 ] || { echo "Usage: $0 obtain <domain> <email>" >&2; exit 1; }
    cmd_obtain "$1" "$2"
    ;;
  deploy)
    [ "$#" -eq 1 ] || { echo "Usage: $0 deploy <domain>" >&2; exit 1; }
    cmd_deploy "$1"
    ;;
  renew)
    cmd_renew
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1
    ;;
esac
