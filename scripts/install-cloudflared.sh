#!/usr/bin/env bash
# Install cloudflared on Orange Pi / Debian / Ubuntu (arm64 or amd64).
# Does NOT create tunnels or write secrets — see docs/INSTALL.md
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

ARCH="$(uname -m)"
case "$ARCH" in
  aarch64|arm64) DEB_ARCH=arm64 ;;
  x86_64|amd64)  DEB_ARCH=amd64 ;;
  armv7l)        DEB_ARCH=arm ;;
  *)
    echo "Unsupported arch: $ARCH" >&2
    exit 1
    ;;
esac

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Installing cloudflared for $DEB_ARCH..."
curl -fsSL -o "$TMP/cloudflared.deb" \
  "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${DEB_ARCH}.deb"
dpkg -i "$TMP/cloudflared.deb" || apt-get install -f -y
cloudflared --version

id cloudflared &>/dev/null || useradd --system --home /etc/cloudflared --shell /usr/sbin/nologin cloudflared
mkdir -p /etc/cloudflared
chown -R cloudflared:cloudflared /etc/cloudflared
chmod 0750 /etc/cloudflared

echo
echo "Prefer:  cd ~/canopy-station && sudo ./scripts/install_tunnel.sh"
echo "Then fill /etc/cloudflared/config.yml (UUID + hostname)."
echo "Origin is already http://127.0.0.1:5000 — do not port-forward."
echo "Access policy: docs/ACCESS-POLICY.md"
