#!/usr/bin/env bash
# Install cloudflared on Orange Pi / Debian / Ubuntu (arm64 or amd64).
# Does NOT create tunnels or write secrets — run after reading ../README.md
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
echo "Next:"
echo "  1) As your admin user: cloudflared tunnel login"
echo "  2) cloudflared tunnel create canopy"
echo "  3) Copy config/config.example.yml → /etc/cloudflared/config.yml and fill PLACEHOLDERS"
echo "  4) Move credentials JSON into /etc/cloudflared/ and chmod 600"
echo "  5) cloudflared tunnel route dns canopy canopy.EXAMPLE.com"
echo "  6) sudo cloudflared --config /etc/cloudflared/config.yml service install"
echo "  7) sudo systemctl enable --now cloudflared"
echo "  8) Put Cloudflare Access in front of the hostname (see docs/ACCESS-POLICY.md)"
