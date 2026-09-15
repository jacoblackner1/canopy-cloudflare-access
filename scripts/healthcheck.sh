#!/usr/bin/env bash
# Quick healthcheck on the Orange Pi: local Canopy + cloudflared service.
# Usage: ./healthcheck.sh [http://127.0.0.1:5000]
set -euo pipefail

LOCAL_URL="${1:-http://127.0.0.1:5000}"
echo "== cloudflared =="
if command -v cloudflared >/dev/null; then
  cloudflared --version || true
else
  echo "cloudflared not installed"
fi
systemctl is-active cloudflared 2>/dev/null || echo "cloudflared service: inactive/missing"
systemctl is-enabled cloudflared 2>/dev/null || true

echo
echo "== local Canopy (must work without Cloudflare) =="
code="$(curl -sS -o /dev/null -w '%{http_code}' --connect-timeout 3 "$LOCAL_URL" || true)"
echo "GET $LOCAL_URL → HTTP $code"
if [[ "$code" =~ ^[23] ]]; then
  echo "OK: local UI responds"
else
  echo "WARN: local UI did not return 2xx/3xx — start canopy-station first"
fi
status="$(curl -sS -o /dev/null -w '%{http_code}' --connect-timeout 3 "${LOCAL_URL%/}/status" || true)"
echo "GET ${LOCAL_URL%/}/status → HTTP $status"

echo
echo "== tip =="
echo "Public hostname should require Cloudflare Access login before anyone sees Canopy."
echo "LAN http://<pi>:5000/ stays open on home Wi-Fi with no Access prompt."
