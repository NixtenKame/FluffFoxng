#!/bin/sh
set -e

# Ensure uploads path is writable before app boot. Bind mounts can override image perms.
UPLOAD_DIR="${DANBOORU_UPLOAD_DIR:-/app/public/data}"
mkdir -p "$UPLOAD_DIR" 2>/dev/null || true

if [ ! -w "$UPLOAD_DIR" ] && [ "$(id -u)" = "0" ]; then
  TARGET_UID="${HOST_UID:-}"
  TARGET_GID="${HOST_GID:-}"

  # If no host uid/gid are provided, infer them from the mounted uploads directory.
  if [ -z "$TARGET_UID" ] || [ -z "$TARGET_GID" ]; then
    MOUNT_UID="$(stat -c '%u' "$UPLOAD_DIR" 2>/dev/null || echo 1000)"
    MOUNT_GID="$(stat -c '%g' "$UPLOAD_DIR" 2>/dev/null || echo 1000)"
    TARGET_UID="${TARGET_UID:-$MOUNT_UID}"
    TARGET_GID="${TARGET_GID:-$MOUNT_GID}"
  fi

  [ -n "$TARGET_UID" ] || TARGET_UID=1000
  [ -n "$TARGET_GID" ] || TARGET_GID=1000
  chown -R "${TARGET_UID}:${TARGET_GID}" "$UPLOAD_DIR" 2>/dev/null || true
  chmod -R ug+rwX "$UPLOAD_DIR" 2>/dev/null || true
fi

if [ ! -w "$UPLOAD_DIR" ]; then
  echo "ERROR: upload directory is not writable: $UPLOAD_DIR (uid=$(id -u), gid=$(id -g))" >&2
  echo "Fix host permissions, then restart:" >&2
  echo "  sudo chown -R ${HOST_UID:-1000}:${HOST_GID:-1000} uploads && chmod -R u+rwX,g+rwX uploads" >&2
  exit 1
fi

# Ensure Ruby has a writable temp directory.
mkdir -p /tmp
if [ "$(id -u)" = "0" ]; then
  chmod 1777 /tmp
fi

if [ -w /tmp ]; then
  export TMPDIR=/tmp
else
  mkdir -p /app/tmp
  export TMPDIR=/app/tmp
fi

yarn install --frozen-lockfile --non-interactive
rm -f .overmind.sock
rm -f /tmp/rails-server.pid

if [ -d "vendor/dtext" ] && [ "$LOCAL_DTEXT" = "true" ]; then
  echo "dtext: Recompiling..."
  cd vendor/dtext
  
  rm -f lib/dtext/dtext.so
  rm -rf tmp/
  
  bundle install --quiet
  bundle exec rake compile
  cd /app
  echo "dtext: Recompiled successfully"
fi

exec "$@"
