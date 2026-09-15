# Joint install — Canopy + Cloudflare Tunnel + Access

Station: [canopy-station](https://github.com/jacoblackner1/canopy-station)
Tunnel package: this repo.

Do not rebuild the dashboard. Do not open a router port. Cloudflare Access is the login.

```
Browser → Access (email OTP) → Tunnel → cloudflared on Pi → http://127.0.0.1:5000
```

Flask already binds `0.0.0.0:5000`. Local LAN keeps working without Cloudflare.

## On the Pi

```bash
cd ~/canopy-station
git pull
sudo ./scripts/install_tunnel.sh
```

That installs `cloudflared`, copies `config/config.example.yml` → `/etc/cloudflared/config.yml`, and enables `cloudflared.service` (`After=canopy-station.service`). HDMI / `canopy-kiosk` are not touched.

## Named tunnel

```bash
cloudflared tunnel login          # open the printed URL on your phone
cloudflared tunnel create canopy  # note the UUID
sudo cp ~/.cloudflared/<UUID>.json /etc/cloudflared/<UUID>.json
sudo chown cloudflared:cloudflared /etc/cloudflared/<UUID>.json
sudo chmod 600 /etc/cloudflared/<UUID>.json
sudo nano /etc/cloudflared/config.yml   # UUID + canopy.yourdomain.com
cloudflared tunnel route dns canopy canopy.yourdomain.com
sudo ./scripts/validate-config.sh
sudo systemctl restart cloudflared
```

Leave `service: http://127.0.0.1:5000`.

## Access allowlist

Zero Trust → Access → Self-hosted app on that hostname.

- Allow → Emails → **only your address**
- Require → One-time PIN
- No “Everyone”

See [ACCESS-POLICY.md](ACCESS-POLICY.md). Water / Lamp are live actuators.

## Validate

```bash
./scripts/healthcheck.sh http://127.0.0.1:5000
```

- Off home Wi-Fi: `https://canopy.yourdomain.com` → OTP → same Canopy UI
- On LAN: `http://<pi>:5000/` still works, no Access prompt
- Reboot-safe: `canopy-station` + `cloudflared` both `enabled`

Cut remote: `sudo systemctl stop cloudflared`

Never commit `cert.pem`, tunnel JSON, or tokens.
