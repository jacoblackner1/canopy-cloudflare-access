# Canopy + Cloudflare Tunnel + Access

Secure remote access to the existing **Canopy** plant dashboard (Orange Pi LAN web UI: live cam, moisture/light, Water / Lamp controls) using **Cloudflare Tunnel** (outbound-only) and **Cloudflare Access** (login gate).

**This repo does not rebuild Canopy.** It ships config templates, an install helper, systemd notes, Access policy guidance, and a security checklist.

![Canopy dashboard (LAN UI)](docs/canopy-dashboard.png)

## Architecture

```
You (browser) → Cloudflare Access (email OTP allowlist)
              → Cloudflare Tunnel (named)
              → cloudflared on Orange Pi (outbound)
              → existing Canopy HTTP UI on localhost/LAN
```

- No open router ports for Canopy.
- Anonymous users never see the camera or actuators.

Official docs:
- [Create a tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-remote-tunnel/)
- [Local config file](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/local-management/configuration-file/)
- [Linux service](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/local-management/as-a-service/linux/)
- [Access OTP](https://developers.cloudflare.com/cloudflare-one/integrations/identity-providers/one-time-pin/)

## Repo layout

| Path | Purpose |
|------|---------|
| `config/config.example.yml` | Placeholder `cloudflared` ingress |
| `systemd/cloudflared.service` | Optional unit (prefer `cloudflared service install`) |
| `scripts/install-cloudflared.sh` | Install binary + service user on Pi |
| `scripts/validate-config.sh` | Reject leftover PLACEHOLDERS; `ingress validate` |
| `scripts/healthcheck.sh` | Local UI + service check |
| `docs/ACCESS-POLICY.md` | Email allowlist + OTP |
| `docs/SECURITY-CHECKLIST.md` | Camera/control threat model |
| `docs/ORANGE-PI-NOTES.md` | Host notes |

## End-to-end setup

### A. Cloudflare account prep

1. Domain on Cloudflare (or add one).
2. Zero Trust / Cloudflare One enabled for the account.
3. Decide public hostname, e.g. `canopy.yourdomain.com`.

### B. On the Orange Pi — install cloudflared

```bash
sudo ./scripts/install-cloudflared.sh
```

### C. Create a named tunnel (on a machine where you can complete browser login)

```bash
cloudflared tunnel login          # downloads cert.pem — protect it; do not commit
cloudflared tunnel create canopy  # prints UUID; writes credentials JSON
```

Copy the credentials JSON to the Pi as `/etc/cloudflared/<UUID>.json` (`chmod 600`, owner `cloudflared`).

### D. Config on the Pi

```bash
sudo cp config/config.example.yml /etc/cloudflared/config.yml
sudo nano /etc/cloudflared/config.yml   # fill PLACEHOLDERS
```

Replace:

| Placeholder | Meaning |
|-------------|---------|
| `TUNNEL_UUID_HERE` | UUID from `tunnel create` |
| `canopy.EXAMPLE.com` | Your public hostname |
| `CANOPY_PORT` | Port of the **existing** Canopy UI |

Validate:

```bash
sudo ./scripts/validate-config.sh /etc/cloudflared/config.yml
```

### E. DNS route

```bash
cloudflared tunnel route dns canopy canopy.yourdomain.com
```

### F. Run as a service

```bash
sudo cloudflared --config /etc/cloudflared/config.yml service install
sudo systemctl enable --now cloudflared
sudo systemctl status cloudflared
```

### G. Cloudflare Access (required)

Follow [`docs/ACCESS-POLICY.md`](docs/ACCESS-POLICY.md):

- Self-hosted app on `canopy.yourdomain.com`
- Allow **only** your email(s)
- Prefer Require → One-time PIN with that allowlist
- Incognito test: Access wall before Canopy

### H. Checklist

Work through [`docs/SECURITY-CHECKLIST.md`](docs/SECURITY-CHECKLIST.md).

### I. Healthcheck

```bash
./scripts/healthcheck.sh http://127.0.0.1:YOUR_PORT
```

## Alternative: remotely managed tunnel token

Zero Trust → Networks → Tunnels → Create → install with:

```bash
sudo cloudflared service install <TUNNEL_TOKEN>
```

Still put **Access** on the public hostname. Treat the token like a password; do not commit it.

## Secrets policy

This repository must contain **placeholders only**. Never commit:

- tunnel credentials JSON
- `cert.pem`
- install tokens
- API tokens

## Success criteria

Incognito visit to `https://canopy.yourdomain.com` → Access login → after OTP/email allow → **existing** Canopy UI (LIVE cam + controls), with no home-router port forwards.
