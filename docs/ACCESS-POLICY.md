# Cloudflare Access policy notes (Canopy)

Put **Cloudflare Access** in front of the tunnel hostname so anonymous visitors never reach the live camera or Water/Lamp controls. Those buttons are live 120V actuators — treat the allowlist as the lock on the pump and lamp.


Official refs:
- [One-time PIN](https://developers.cloudflare.com/cloudflare-one/integrations/identity-providers/one-time-pin/)
- [Common Access policies](https://developers.cloudflare.com/cloudflare-one/access-controls/policies/common-policies/)

## Recommended setup (email allowlist + OTP)

1. Cloudflare Zero Trust dashboard → your team.
2. **Integrations → Identity providers → Add → One-time PIN** (enable OTP).
3. **Access → Applications → Add an application → Self-hosted**
   - Application domain: `canopy.EXAMPLE.com` (same hostname as the tunnel DNS route)
   - Session duration: short is fine (e.g. 24h) for a home plant dashboard
4. Create a policy:
   - **Action:** Allow
   - **Include:** Emails → `you@example.com` (and any other trusted addresses only)
   - **Require (optional but good):** Login methods → One-time PIN  
     Pair OTP with an email allowlist. Do **not** use “OTP” alone with open email domains — that lets anyone with any inbox request a code.
5. Default deny: do not add a broad Allow for “Everyone” / entire public email domains.

## Block anonymous

- Access sits in front of the origin. Unauthenticated requests get the Cloudflare login page, not Canopy.
- Confirm in an incognito window: opening `https://canopy.EXAMPLE.com` must show Access, not the LIVE cam.

## Tokens / secrets (do not invent or commit)

| Secret | Where it comes from | Where it lives |
|--------|---------------------|----------------|
| Tunnel credentials JSON | `cloudflared tunnel create …` | Pi: `/etc/cloudflared/<UUID>.json` (mode 600) |
| `cert.pem` (account cert) | `cloudflared tunnel login` | Admin machine / Pi home `.cloudflared/` — protect it |
| Access policies | Zero Trust UI | Cloudflare account (no local secret file) |
| Optional tunnel **token** (remotely managed) | Zero Trust → Networks → Tunnels → Install connector | Used once with `cloudflared service install <TOKEN>` — treat like a password |

Never paste these into git, chat, or this repo.

## Optional hardening

- Separate hostname only for Canopy (don’t share with unrelated apps).
- Add a second policy Deny for countries you never use (optional).
- Keep the allowlist tiny — this dashboard can water hardware and stream video.
