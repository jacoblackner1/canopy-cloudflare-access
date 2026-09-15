#!/usr/bin/env bash
# Validate a filled cloudflared config (no secrets printed).
set -euo pipefail
CFG="${1:-/etc/cloudflared/config.yml}"
if [[ ! -f "$CFG" ]]; then
  echo "Missing config: $CFG" >&2
  exit 1
fi
if grep -E 'TUNNEL_UUID_HERE|EXAMPLE\.com' "$CFG" >/dev/null; then
  echo "Config still contains PLACEHOLDERS (UUID or hostname) — fill them before running." >&2
  exit 2
fi
if ! grep -q '127.0.0.1:5000' "$CFG"; then
  echo "WARN: origin is not http://127.0.0.1:5000 — plant_dashboard.py binds 0.0.0.0:5000" >&2
fi
cloudflared tunnel --config "$CFG" ingress validate
echo "Ingress OK"
