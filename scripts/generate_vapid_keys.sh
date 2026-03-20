#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f ".env" ]]; then
  echo "ERROR: .env not found. Run this from the repo root." >&2
  exit 1
fi

compose_cmd="docker compose"
if ! docker compose version >/dev/null 2>&1; then
  compose_cmd="docker-compose"
fi

output="$($compose_cmd run --rm FluffFox ruby -ropenssl -rbase64 -e '
key = OpenSSL::PKey::EC.generate("prime256v1")
pub = key.public_key.to_bn.to_s(2)
priv = key.private_key.to_s(2)
b64u = ->(bin) { Base64.urlsafe_encode64(bin).delete("=") }
puts "VAPID_PUBLIC_KEY=#{b64u.call(pub)}"
puts "VAPID_PRIVATE_KEY=#{b64u.call(priv)}"
'
)"

vapid_public_key="$(echo "$output" | awk -F= '/^VAPID_PUBLIC_KEY=/{print $2}')"
vapid_private_key="$(echo "$output" | awk -F= '/^VAPID_PRIVATE_KEY=/{print $2}')"

if [[ -z "$vapid_public_key" || -z "$vapid_private_key" ]]; then
  echo "ERROR: Failed to generate VAPID keys." >&2
  echo "$output" >&2
  exit 1
fi

tmp_file="$(mktemp)"
awk -v pub="$vapid_public_key" -v priv="$vapid_private_key" '
  BEGIN { seen_pub = 0; seen_priv = 0 }
  /^VAPID_PUBLIC_KEY=/ { print "VAPID_PUBLIC_KEY=" pub; seen_pub = 1; next }
  /^VAPID_PRIVATE_KEY=/ { print "VAPID_PRIVATE_KEY=" priv; seen_priv = 1; next }
  { print }
  END {
    if (!seen_pub) print "VAPID_PUBLIC_KEY=" pub
    if (!seen_priv) print "VAPID_PRIVATE_KEY=" priv
  }
' .env > "$tmp_file"

mv "$tmp_file" .env

echo "Updated .env with new VAPID keys."
