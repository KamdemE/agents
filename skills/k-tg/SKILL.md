---
name: k-tg
description: tg-proxy — Telegram admin proxy CLI. Replaces old `tg` binary. Bot/user management, BotFather, raw access.
license: private
metadata:
  author: KpihX
  version: "4.2.0"
  scope: tool-memory
allowed-tools: "Bash(*), Read(*), Glob(*), *"
---

# KπX — Telegram (`tg-proxy`)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**
> **Project:** `$HOME/KpihX-Labs/tg_proxy/` · **Repos:** GitHub + GitLab (tg-proxy)
> **Related:** `k-tmux` (HITL shared gate) · `k-clis` (CLI registry)

## Identity

`tg-proxy` is a single Python CLI with two namespaces:
```bash
tg-proxy admin setup|status         # Always JSON
tg-proxy do <action> [payload|file] # Flat RPC, --format json|table, --output-file
```
Config: `~/.config/tg-proxy/.env` (`TG_API_ID` + `TG_API_HASH` only). Tokens stored in same file as `{USERNAME}_TOKEN`. Autosave: `/tmp/tg-proxy-autosave/{action}_{timestamp}.json`.

### Install
```bash
cd $HOME/KpihX-Labs/tg_proxy && uv tool install --editable .
```

---

## 23 `do` Commands (HITL status)

| Action | HITL | Backend | Action | HITL | Backend |
|--------|:----:|---------|--------|:----:|---------|
| `bot-list` | ❌ | MTProto | `chat-delete` | ❌ | Telethon |
| `bot-info` | ❌ | MTProto | `chat-delete-messages` | ❌ | Telethon |
| `bot-token` | ✅ | BF | `chat-move` | ❌ | Telethon |
| `bot-create` | ✅ | BF | `folder-list` | ❌ | Telethon |
| `bot-delete` | ✅ | BF | `folder-set` | ❌ | Telethon |
| `bot-send` | ✅ | BotAPI | `folder-delete` | ✅ | Telethon |
| `bot-send-file` | ✅ | BotAPI | `updates` | ❌ | BotAPI |
| `bot-photo` | ❌ | Telethon | `webhook-get` | ❌ | BotAPI |
| `chat-list` | ❌ | Telethon | `webhook-set` | ❌ | BotAPI |
| `chat-read` | ❌ | Telethon | `webhook-del` | ❌ | BotAPI |
| `chat-send` | ❌ | Telethon | **`raw`** | ✅ | Generic |
| `chat-send-file` | ❌ | Telethon | `admin setup` | ✅ | Telethon |
| `chat-download` | ❌ | Telethon | `admin status` | ❌ | Telethon |

### HITL rule (CRITICAL)
`raw` + all ✅ above MUST run in a **tmux ops pane** (prefer `<session>:0.2`). Pattern:
1. `cat > /tmp/tg.sh << SCRIPT` + `tmux send-keys -t <ses>:<win>.<pane> "bash /tmp/tg.sh" Enter`
2. **Poll with sleep 3-5s** until prompt returns
3. If BotFather: `capture-pane` to read his response before proceeding
4. **Use raw ONLY if no dedicated `do` command exists**

### `bot-info` extras
Returns `about` + `description` (since v4.0.0) via `GetBotInfoRequest(lang_code="")`. If descriptions seem empty: check lang_code mismatch (BotAPI sets fallback, not "en").

---

## Bot Inventory (13 bots, all in `KpihX-Labs` folder)

Ask `tg-proxy do bot-list` for live data. Quick reference:

| @username | Display | ID | Ver | Webhook |
|-----------|---------|----|:---:|:-------:|
| @docker_host_kpihx_bot | Dockerhost | 8036146758 | 1 | ❌ |
| @k_n8n_x_bot | N8N | 8724946664 | 1 | ❌ |
| @k_ubuntu_bot | Ubuntu | 8331655781 | 53 | ❌ |
| @kflow_homelab_bot | Flow | 8723866455 | 1 | ❌ |
| @kpihx_general_capture_bot | KpihX | 8089748360 | 1 | ❌ |
| @kpihx_labs_bot | KpihX-Labs | 7975928900 | 1 | ❌ |
| @kpihx_openclaw_bot | OpenClaw | 8948919586 | 159 | ❌ |
| @kpihx_s25_bot | S25 | 8557838158 | 1 | ❌ |
| @linkedin_homelab_bot | LinkedIn | 8662033588 | 1 | ❌ |
| @mail_homelab_bot | Mail | 8385666882 | 1 | ❌ |
| @sentinel_homelab_bot | PVE | 8589111784 | 6 | ❌ |
| @tick_homelab_bot | Ticktick | 8357989597 | 1 | ❌ |
| @whats_homelab_bot | Whatsapp | 8449692658 | 1 | ❌ |

All 13 have about+description set (2026-07-26). All tokens in `~/.config/tg-proxy/.env`. All webhooks empty (polling mode). Default capture bot: `@kpihx_general_capture_bot` (ID 8089748360).

### Channels & BotFather
BotFather ID: **93372553**. Channels: RFI (32k unread), France24 (13k), V.Poutine (22k), Cameroon Desk, Jeune Afrique, Infos Concours, Telegram Tips, Nakanime, Nakastream. (No personal contacts listed.)

---

## Security — Config Directory Permissions

The `~/.config/tg-proxy/` directory and its files contain API credentials + session data:

| Path | Required Permission |
|------|-------------------|
| `~/.config/tg-proxy/` | `700` (drwx------) |
| `~/.config/tg-proxy/.env` | `600` (-rw-------) |
| `~/.config/tg-proxy/user.session` | `600` (-rw-------) |

Set after `tg-proxy admin setup`:
```bash
chmod 700 ~/.config/tg-proxy
chmod 600 ~/.config/tg-proxy/.env ~/.config/tg-proxy/user.session
```

## Secrets (always in `~/.config/tg-proxy/.env`)

`TG_API_ID=32750118` · `TG_API_HASH=...` · 13 × `{USERNAME}_TOKEN` (convention: uppercase @username + `_TOKEN`).

---

## Operational Memory

| File | Role |
|------|------|
| `references/telegram-processed-state.md` | Last triaged message IDs per chat |
| `references/log.md` | Operation log |
| `references/insights.md` | Durable patterns |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-26 | [OPENCODE] | **v4.2.0 — Security section added (config dir perms 700/600).** Proactive skill update after tg-proxy README security hardening. |
| [SUMMARY] | — | v4.0.0–v4.1.0 — Full `tg` → `tg-proxy` rewrite + compact condensed. Earlier → `references/log.md`. |
