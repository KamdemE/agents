---
name: k-cloud-tools
description: >
  Cloud tool registry — Cloudflare, Tailscale, social dev APIs. Routes Google/Microsoft
  workspace to k-google and k-microsoft. Load for edge/network registry or full-stack routing.
license: private
metadata:
  author: KpihX
  version: "1.1.1"
  scope: operations
---

# KπX — Cloud Tools (registry hub)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Role

Central **routing hub** for KπX cloud CLIs and dev APIs. Operational detail lives in domain skills — not here.

**Full map (mandatory read for routing):** `$HOME/.agents/skills/k-cloud-tools/references/cloud-hub.md`

## Quick routing

| Need | Skill |
|------|-------|
| Google GCP or Workspace | **`k-google`** (+ `k-rclone`, `k-drive` for files) |
| Microsoft Azure or M365 | **`k-microsoft`** (+ **`k-mail`** for briefings) |
| Mail / tasks / WhatsApp / LinkedIn / Telegram | **`k-mail`**, **`k-ticktick`**, **`k-whatsapp`**, **`k-linkedin`**, **`k-tg`** |
| Secrets / OAuth app ids | **`k-bw`** |
| Homelab deploy | **`kpihx-labs`**, **`k-docker`** |

## Installed CLIs (verify live — `!<cmd>`)

### Networking & edge

| Tool | Status | Purpose |
|------|--------|---------|
| `cloudflared` | INSTALLED | Tunnels, Zero Trust |
| `wrangler` | INSTALLED | Workers, Pages, R2 |
| `tailscale` | INSTALLED | Mesh VPN |

### Cloud providers (detail → domain skills)

| Tool | Plane | Skill |
|------|-------|-------|
| `gcloud` | Google container | **`k-google`** |
| `gws` | Google content | **`k-google`** |
| `az` | Azure container | **`k-microsoft`** |
| `m365` | M365 content | **`k-microsoft`** |

## Procedures (this skill only)

**Cloudflare**

```bash
cloudflared tunnel list
wrangler deploy
```

Cursor Cloudflare MCP: Workers/KV/D1/R2/observability — **not** full DNS/Tunnel/Zero Trust inventory → `references/insights.md`.

**Tailscale**

- Non-trivial policy: read `references/insights.md` first.
- API verification: **`ts-proxy`** (`$HOME/Work/KpihX-Labs/Fluid/ts_proxy/`).
- Check device **tags** vs ACL `src` before blaming host firewall.

## Credentials

- OAuth/API keys: **Vaultwarden** + **`bw-env`** (never commit secrets).
- Config paths: `~/.cloudflared/`, `~/.config/gcloud/`, `/etc/tailscale/`, `$HOME/.local/share/m365/` (tokens).

## Social dev APIs (portal links only)

| Platform | Dev portal | Operational skill |
|----------|------------|-------------------|
| Meta | developers.facebook.com | `k-whatsapp` (bot); Cloud API TBD |
| Google | console.cloud.google.com | `k-google` |
| LinkedIn | developer.linkedin.com | **`k-linkedin`** |
| X | developer.twitter.com | TBD |

Pending: YouTube Data API, Meta app validation, X API tier — track in `references/insights.md` when status changes.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-cloud-tools/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-cloud-tools/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-25 | [CURSOR] | v1.1.1 — `k-tg` in hub map + quick routing; AGENTS `k-cloud-tools` row. |
| [SUMMARY] | — | v1.1.0 hub SOT; v1.0.x registry + Tailscale/Cloudflare insights. |
