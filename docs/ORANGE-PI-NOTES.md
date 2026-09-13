# Orange Pi notes (Canopy host)

- Architecture is usually **aarch64** — `scripts/install-cloudflared.sh` picks the arm64 `.deb`.
- Find the existing Canopy bind address/port on the Pi (whatever already serves the LAN dashboard). Put that in `config.yml` as `service: http://127.0.0.1:PORT` if Canopy listens locally, or `http://LAN_IP:PORT` only if required.
- Do **not** rebuild the Canopy UI for this project — tunnel + Access only.
- HDMI “stats only” / on-page controls stay as they are; remote users hitting the hostname get the same UI after Access login.
