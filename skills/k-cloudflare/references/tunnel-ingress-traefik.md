# Cloudflare Tunnel `<github-user>` & Traefik Ingress

> **Account ID:** `5d0ff5e40bbc37baed99d3c7aacd0741` · **Zone ID:** `255f60d9f77924ac016c194300dbeb3c`  
> **Tunnel Name:** `<github-user>` · **Tunnel UUID:** `db6721cb-6bfe-4750-b55a-124e6dc74388`

## Connector Status

- **Status:** **`HEALTHY`**
- **Host Location:** `docker-host` (IP `129.104.234.138`, Polytechnique X network)
- **Client Version:** `cloudflared v2026.8.3`
- **Active Connections (4 datacenters Paris):** `cdg07` (×2), `cdg10`, `cdg13`
- **Config Source:** `remote_config: true` (managed via cloud / API)

---

## Published Ingress Table (v17)

All public subdomains route to internal Docker proxy `https://traefik:443` with `noTLSVerify: true`:

| Hostname Public | Internal Target | TLS Settings | Zero Trust Protected? |
|-----------------|-----------------|--------------|-----------------------|
| `sentinel.<github-user>.com` | `https://traefik:443` | `noTLSVerify: true` | 🔒 Yes (`Sentinel` App) |
| `whoami.<github-user>.com` | `https://traefik:443` | `noTLSVerify: true` | 🌐 Public Traefik |
| `<github-user>.com` (apex) | `https://traefik:443` | `noTLSVerify: true`, `httpHostHeader: <github-user>.com` | 🌐 Public Traefik |
| `www.<github-user>.com` | `https://traefik:443` | `noTLSVerify: true`, `httpHostHeader: www.<github-user>.com` | 🌐 Public Traefik |
| `assets.<github-user>.com` | `https://traefik:443` | `noTLSVerify: true` | 🌐 Public Traefik |
| `tick.<github-user>.com` | `https://traefik:443` | `noTLSVerify: true` | 🔒 Yes (`Ticktick` App) |
| `whats.<github-user>.com` | `https://traefik:443` | `noTLSVerify: true` | 🔒 Yes (`Whatsapp` App) |
| `mail.<github-user>.com` | `https://traefik:443` | `noTLSVerify: true` | 🔒 Yes (`Mail` App) |
| `live.<github-user>.com` | `https://traefik:443` | `noTLSVerify: true` | 🔒 Yes (`Live` App) |
| `ai.<github-user>.com` | `https://traefik:443` | `noTLSVerify: true` | 🔒 Yes (`AI` App) |
| `*` (Catch-all) | `http_status:404` | — | — |

---

## API Ingress Management (`curls`)

```bash
# Read current Tunnel Ingress Configuration
with-env curls -p cloudflare 'https://api.cloudflare.com/client/v4/accounts/5d0ff5e40bbc37baed99d3c7aacd0741/cfd_tunnel/db6721cb-6bfe-4750-b55a-124e6dc74388/configurations'

# Update Tunnel Ingress (PUT = full replace; always include catch-all http_status:404 at end)
cp $HOME/.agents/skills/k-cloudflare/assets/templates/template-tunnel-ingress.json /tmp/ingress-update.json
# Edit /tmp/ingress-update.json
with-env curls -p cloudflare -X PUT 'https://api.cloudflare.com/client/v4/accounts/5d0ff5e40bbc37baed99d3c7aacd0741/cfd_tunnel/db6721cb-6bfe-4750-b55a-124e6dc74388/configurations' -H 'Content-Type: application/json' -d @/tmp/ingress-update.json
```
