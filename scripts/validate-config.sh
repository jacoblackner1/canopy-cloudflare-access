#!/usr/bin/env bash
# Validate a filled cloudflared config (no secrets printed).
set -euo pipefail
CFG="${1:-/etc/cloudflared/config.yml}"
if [[ ! -f "$CFG" ]]; then
  echo "Missing config: $CFG" >&2
  exit 1
fi
if grep -E 'TUNNEL_UUID_HERE|EXAMPLE\.com|CANOPY_PORT' "$CFG" >/dev/null; then
  echo "Config still contains PLACEHOLDERS — fill them before running." >&2
  exit 2
fi
cloudflared tunnel --config "$CFG" ingress validate
echo "Ingress OK"
cloudflared tunnel --config "$CFG" ingress rule https://canopy.local/ || true
