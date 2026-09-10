# cloudflared — quarantined on  workstation

> **Prod connector:** homelab server only (tunnel `<github-user>`, Zero Trust remote-managed).  
> **Workstation (Ubuntu dev):** **`cloudflared` not installed** — by design.  
> **Active CLI here:** **`flarectl`** + `CF_API_TOKEN` (DNS / zones).

## Routing philosophy

| Need | Path |
|------|------|
| **Internal** homelab / LAN / admin | **Tailscale** (+ **`ts-proxy`** for API/HITL) — prefer over exposing services on the public internet |
| **Public** homelab services (`*.<github-user>.com`) | **Cloudflare Tunnel** connector on **server** — already operational |
| **DNS** edits from laptop | **`flarectl`** on workstation |

Do **not** install a second prod connector on a laptop (sleep, mobility, duplicate tunnel noise).

## When you might install `cloudflared` again (workstation)

Optional **dev-only** scenarios — reinstall only for the session, then remove if desired:

| Scenario | Command pattern | vs prod tunnel |
|----------|-----------------|----------------|
| **Expose local dev server** to the internet (webhook test, demo, share WIP) | `cloudflared tunnel --url http://127.0.0.1:<port>` | **Quick tunnel** — random `*.trycloudflare.com` URL, ephemeral |
| **Preview** app before homelab deploy | Same quick tunnel | Not `<github-user>` |
| **Second connector** to prod tunnel | `cloudflared tunnel run eyJ…` from dashboard **Add connector** | Only on an **always-on** host (server), not laptop |
| **Locally-managed** tunnel project | `cloudflared tunnel login` + `tunnel create` | Separate from Zero Trust `<github-user>` |

### Quick tunnel example (localhost → internet)

```bash
# Ephemeral — no <github-user>, no DNS change
cloudflared tunnel --url http://127.0.0.1:8787
```

Stop with Ctrl+C when done. URL changes each run.

### Prod connector (homelab server only)

```bash
# On docker-host / homelab — NOT on Ubuntu dev laptop by default
cloudflared tunnel run eyJhIjoi...
```

Token from Zero Trust → **Add connector** / Install connector. Store in Vault.

## Install reference (if needed later)

Debian/Ubuntu package (was used on workstation before removal):

```bash
# Only when consciously re-enabling — see SKILL.md quarantine table
sudo apt install cloudflared
```

Or official Cloudflare package docs. Prefer **quick tunnel** over prod `tunnel run` on laptop.

## QMD / search keywords

`cloudflared`, `quick tunnel`, `localhost public`, `trycloudflare`, `tunnel run`, `<github-user>`, `homelab connector`, `flarectl only workstation`, `Tailscale internal`
