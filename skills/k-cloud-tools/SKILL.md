---
name: k-cloud-tools
description: >
  Cloud tool registry — routes Cloudflare to k-cloudflare, Tailscale, social dev APIs.
  Google/Microsoft → k-google and k-microsoft. Load for edge/network registry or full-stack routing.
license: private
metadata:
  author: KpihX
  version: "1.3.5"
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
| **Cloudflare** (tunnel, DNS) | **`k-cloudflare`** |
| Google GCP or Workspace | **`k-google`** (+ `k-rclone`, `k-drive` for files) |
| Microsoft M365 (Graph) | **`k-microsoft`** (+ **`k-mail`** for briefings) — `az` off |
| YouTube / Meta / X publish | **`k-media`** |
| Mail / tasks / WhatsApp / LinkedIn / Telegram | **`k-mail`**, **`k-ticktick`**, **`k-whatsapp`**, **`k-linkedin`**, **`k-tg`** |
| Secrets / OAuth app ids | **`k-bw`** |
| Homelab deploy | **`kpihx-labs`**, **`k-docker`** |

## Installed CLIs (verify live — `!<cmd>`)

### Networking & edge

| Tool | Status | Skill |
|------|--------|-------|
| `flarectl` | ACTIVE (workstation) | **`k-cloudflare`** |
| `cloudflared` | **Homelab server only** — quarantined on workstation | **`k-cloudflare`** → `references/cloudflared-quarantine.md` |
| `tailscale` | INSTALLED | Mesh VPN |
| `ts-proxy` | INSTALLED | Tailscale API + HITL — `$HOME/Work/KpihX-Labs/Fluid/ts_proxy/` |

### Cloud providers (detail → domain skills)

| Tool | Plane | Skill |
|------|-------|-------|
| `gcloud` | Google container | **`k-google`** |
| `gws` | Google content | **`k-google`** |
| `m365` | M365 content (sole Microsoft CLI) | **`k-microsoft`** |
| ~~`az`~~ | **Deactivated** — no Azure subscription | — |
| ~~`wrangler`~~ | **Off** on workstation — IDE only | **`k-cloudflare`** (mention) |

## Procedures (this skill only)

**Tailscale**

- Non-trivial policy: read `references/insights.md` first.
- API verification: **`ts-proxy`** (`$HOME/Work/KpihX-Labs/Fluid/ts_proxy/`).
- Check device **tags** vs ACL `src` before blaming host firewall.

**Cloudflare** → load **`k-cloudflare`** (not duplicated here).

## Vault token gate (mandatory)

For **any** cloud CLI or API tool that needs Vault-backed tokens (`CF_API_TOKEN`, Graph, OAuth, MCP keys, etc.):

1. **Never** display, log, or read secret **values** in chat or tool output. Names only: `env | grep -E 'API|TOKEN' | cut -d= -f1`.
2. **Run the target CLI first** (e.g. `flarectl zone list`). If it works, continue — do not touch Vault.
3. If env/auth fails → **`k-tmux`**: session **`default`** or **`remote`** → `send-keys` the same command → poll `capture-pane` **≥30s** → hand off `tmux attach` to KπX.
4. If still failing → in that tmux pane: `bw-env unlock && bw-env get` → **stop** and ask KπX in chat to enter the **Vault password** (never in agent raw shell).
5. After KπX confirms unlock → retry CLI in tmux.

Full ladder: `references/token-gate.md` · Bitwarden detail: **`k-bw`**.

## Credentials

- OAuth/API keys: **Vaultwarden** + **`bw-env`** (never commit secrets).
- Cloudflare: **`CF_API_TOKEN`** in Vault → **`k-cloudflare`** · Tailscale: **`ts-proxy`** · Google: `~/.config/gcloud/` · M365: `$HOME/.local/share/m365/`.

## Social / video dev APIs

**Registry (BW items, program order):** `references/social-dev-platforms.md`  
**YouTube / video ops:** **`k-media`**  
**Architecture vision:** `k-context/references/vision/social-media-apis.md`

| Platform | Vault item | Skill |
|----------|------------|-------|
| YouTube | OAuth `kpihx-labs` | **`k-media`** + **`k-google`** |
| Meta (WA + Graph) | **Meta Dev** | **`k-meta`** · WA chat → **`k-whatsapp`** |
| X | **X Dev** | **`k-x`** |
| LinkedIn | — | **`k-linkedin`** |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-cloud-tools/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-cloud-tools/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-25 | [CURSOR] | v1.3.5 — Social hub: **`k-media`** + **`k-meta`** + **`k-x`**; JSON creds outside git; no **`k-publish`** skill. |
| 2026-05-25 | [CURSOR] | v1.3.4 — `social-dev-platforms.md` + X/Meta/YouTube SOT pointers. |
| [SUMMARY] | — | v1.3.0–v1.3.3 token gate, k-cloudflare hub, cloudflared quarantine; v1.1.x registry. |
