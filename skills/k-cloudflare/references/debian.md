# k-cloudflare — Debian

> **OS reference:** Debian Linux
> **Applies to:** `k-pve-debian` (Debian VM on kpihx-pve)

---

## cloudflared Tunnel Connector

The production Cloudflare Tunnel connector runs on the Debian VM (docker host). Installation:

```bash
# Download cloudflared (Debian amd64)
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared-linux-amd64.deb
```

## Tunnel Identity

| Item | Value |
|------|-------|
| Tunnel name | `<github-user>` |
| Type | Zero Trust remote-managed |
| Connector run | `cloudflared tunnel run <token>` |
| Management | Dashboard or API |

## Service Setup

Run as a systemd service:
```bash
sudo cloudflared service install <token>
sudo systemctl enable --now cloudflared
```

## Troubleshooting

- Connector logs: `journalctl -u cloudflared -f`
- Test tunnel: `cloudflared tunnel info <github-user>`
- DNS records via `flarectl` from workstation (not on this machine)
