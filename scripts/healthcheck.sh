#!/usr/bin/env bash
# Quick healthcheck on the Orange Pi: local Canopy + cloudflared service.
# Usage: ./healthcheck.sh [http://127.0.0.1:PORT]
set -euo pipefail

LOCAL_URL="${1:-http://127.0.0.1:CANOPY_PORT}"
echo "== cloudflared =="
if command -v cloudflared >/dev/null; then
  cloudflared --version || true
else
  echo "cloudflared not installed"
fi
systemctl is-active cloudflared 2>/dev/null || echo "cloudflared service: inactive/missing"
systemctl is-enabled cloudflared 2>/dev/null || true

echo
echo "== local Canopy =="
if [[ "$LOCAL_URL" == *CANOPY_PORT* ]]; then
  echo "Pass the real local URL, e.g.: $0 http://127.0.0.1:8080"
  exit 2
fi
code="$(curl -sS -o /dev/null -w '%{http_code}' --connect-timeout 3 "$LOCAL_URL" || true)"
echo "GET $LOCAL_URL → HTTP $code"
[[ "$code" =~ ^2|3 ]] && echo "OK: local UI responds" || echo "WARN: local UI did not return 2xx/3xx"

echo
echo "== tip =="
echo "Public hostname should require Cloudflare Access login before anyone sees Canopy."
