# Cloud & productivity tool map (source of truth)

> **Load `k-cloud-tools` first** for registry-wide routing. Domain skills own operational detail.

## Layer model

| Layer | Meaning | Examples |
|-------|---------|----------|
| **Container** | Cloud account / infra / network | `gcloud`, `cloudflared`, `tailscale` (`az` **off** on KπX — no Azure sub) |
| **Content** | User data APIs (mail, files, calendar) | `gws`, `m365`, mail-mcp, tick-mcp, whats-mcp |
| **Local files** | FUSE mounts, tree semantics | rclone → `$HOME/Gdrive*`, `k-drive` |
| **MCP** | Agent tool transport | stdio preferred for mail-mcp; HTTP for whats-mcp |

## Skill routing

| Domain | Primary skill | Tools / MCP | Runbook |
|--------|---------------|-------------|---------|
| **Registry** | `k-cloud-tools` | Tailscale, social API portals | this file |
| **Cloudflare** | `k-cloudflare` | `cloudflared`, `flarectl` | `k-cloudflare/references/setup.md` |
| **Google** | `k-google` | `gcloud` (container), `gws` (content) | `techskills/gws-cli.md` |
| **Google Drive files** | `k-rclone` + `k-drive` | `rclone` mounts | `k-rclone/SKILL.md` |
| **Microsoft** | `k-microsoft` | `m365` (content only; `az` **deactivated**) | `techskills/m365-cli.md` |
| **Mail** | `k-mail` | mail-mcp (poly), `m365 outlook` (Hotmail) | `k-mail/references/mcp.md` |
| **Tasks / calendar** | `k-ticktick` | tick-mcp | `k-ticktick/references/mcp.md` |
| **WhatsApp** | `k-whatsapp` | whats-mcp (HTTP preferred) | `k-whatsapp/references/mcp.md` |
| **LinkedIn** | `k-linkedin` | linkedin-mcp | `k-linkedin/references/mcp.md` |
| **Telegram** | `k-tg` | `tg` CLI (Telethon + Bot API) | `k-tg/SKILL.md` |
| **Secrets** | `k-bw` | Vaultwarden, `bw-env` | all OAuth / API keys |
| **Homelab edge** | `kpihx-labs` | Traefik, Docker, GitLab | not public cloud |
| **Tailscale API** | `ts-proxy` project | CLI `do` + JSON payloads | `$HOME/Work/KpihX-Labs/Fluid/ts_proxy/CONTRACT.md` |

## What's up ladder (one skill per turn)

1. `k-context` → 2. `k-mail` → 3. `k-whatsapp` → 4. `k-ticktick` → 5. `k-tg`

## Future: CLI + MCP unified contract

Reference: `ts-proxy`, `whats_proxy` — same API via CLI and HTTP; HITL on destructive ops.

- Google: `k-google/references/mcp-cli-vision.md`, `k-context/references/google-workspace-full-mcp-vision.md`
- Microsoft: `k-microsoft/references/mcp-cli-vision.md`

## Social / dev APIs

**Hub:** **`k-media`** · registry: `references/social-dev-platforms.md` · **no `k-publish` skill** (vision only).

| Platform | Skill | Status |
|----------|-------|--------|
| YouTube | `k-media` + `k-google` | LIVE `@kpihx` |
| X | `k-x` | LIVE `me`; tweet needs credits |
| Meta Graph | `k-meta` | LIVE core; System User for WA Graph |
| WhatsApp chat | `k-whatsapp` | ACTIVE (whats-mcp) |
| LinkedIn | `k-linkedin` | ACTIVE (linkedin-mcp) |
