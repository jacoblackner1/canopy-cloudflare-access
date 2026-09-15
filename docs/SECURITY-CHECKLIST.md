# Canopy remote access — security checklist

Canopy exposes a **live camera** and **physical controls** (Water 1s, Lamp). Treat remote access as sensitive.

## Network

- [ ] **No router port forwards** for Canopy / SSH / the camera. Tunnel is **outbound-only** from the Orange Pi to Cloudflare.
- [ ] Confirm from outside the LAN that `http://<home-ip>:5000` is **not** reachable.
- [ ] Pi firewall can still allow LAN `:5000` while blocking WAN; tunnel does not need inbound ports.

## Tunnel

- [ ] Named tunnel (or remotely managed token install) running as a systemd service; survives reboot.
- [ ] Credentials JSON / install token mode `600`, owned by the service user — **not** in git.
- [ ] Ingress ends with `http_status:404` catch-all.
- [ ] Public hostname DNS is an orange/CNAME cloudflare tunnel route — not a raw home IP A record.

## Access (login)

- [ ] Cloudflare Access application covers the Canopy hostname.
- [ ] Allowlist is **specific emails only** (e.g. your Gmail).
- [ ] OTP enabled and paired with that allowlist (or a strong IdP).
- [ ] Incognito test: no Access cookie → login wall, not LIVE video.
- [ ] Signed-out / different account → denied.

## Device & app

- [ ] Canopy still binds `0.0.0.0:5000` for LAN; tunnel points at `http://127.0.0.1:5000`.
- [ ] You understand Water/Lamp buttons are live actuators — Access failure ≈ stranger can press them.
- [ ] Camera sensitivity: don’t share the Access-protected URL casually; revoke emails that leave the allowlist.
- [ ] Keep Orange Pi OS patched; unique passwords for any local SSH (prefer keys; no password auth from WAN — and no WAN SSH).

## Ops

- [ ] `scripts/healthcheck.sh` passes locally after install.
- [ ] You know how to `systemctl stop cloudflared` to cut remote access quickly.
- [ ] Cloudflare account 2FA on.
