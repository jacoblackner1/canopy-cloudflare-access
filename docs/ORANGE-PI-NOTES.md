# Orange Pi notes (Canopy host)

Verified in [canopy-station](https://github.com/jacoblackner1/canopy-station) `plant_dashboard.py`:

| Setting | Value |
|---------|--------|
| `flaskHost` | `0.0.0.0` (LAN + loopback) |
| `flaskPort` | `5000` |
| LAN UI | `http://<pi-lan-ip>:5000/` — Water / Lamp / calibrate |
| HDMI | stats-only kiosk (`canopy-kiosk.service`) |
| systemd dashboard | `canopy-station.service` from `scripts/install_hdmi.sh` |

Tunnel origin **must** be `http://127.0.0.1:5000`. Do not change Flask to loopback-only — that would break phones on home Wi-Fi. Do not port-forward 5000.

- Architecture is **aarch64** — `scripts/install-cloudflared.sh` picks the arm64 `.deb`.
- Install from the station repo so the unit starts after the dashboard:

  `cd ~/canopy-station && sudo ./scripts/install_tunnel.sh`

- HDMI kiosk is unchanged. Remote users get the **full** control UI (same as LAN `:5000`) after Access login.
