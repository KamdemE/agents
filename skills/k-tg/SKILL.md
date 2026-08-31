---
name: k-tg
description: tg-proxy — Telegram admin proxy CLI. Replaces old `tg` binary. Bot/user management, BotFather, raw access.
license: private
metadata:
  author: KpihX
  version: "4.5.0"
  scope: tool-memory
allowed-tools: "Bash(*), Read(*), Glob(*), *"
---

# KπX — Telegram (`tg-proxy`)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**
> **Project:** `$HOME/KpihX-Labs/Proxies/tg-proxy/` · **Repos:** GitHub + GitLab (tg-proxy)
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
cd $HOME/KpihX-Labs/Proxies/tg-proxy && uv tool install --editable .
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
| `chat-send` | ✅ | Telethon | **`raw`** | ✅ | Generic |
| `chat-send-file` | ✅ | Telethon | `admin setup` | ✅ | Telethon |
| `chat-download` | ❌ | Telethon | `admin status` | ❌ | Telethon |

### HITL rule (CRITICAL)
`raw` + all ✅ above MUST run in a **tmux ops pane** (any idle pane — `tmux display-message -p -t <pane> '#{pane_current_command}'` first, never send into a busy one). Pattern (updated 2026-08-27 — the old "poll with sleep"/"capture-pane" guidance below was STALE and directly contradicts `k-tmux`'s armed-notify discipline, fixed here):
1. `tmux send-keys -t <session>:<win>.<pane> "TMUX_TIMEOUT=<secs> TMUX_LINES=<n> tg-proxy do <action> '<payload>'" Enter` — armed automatically by `tmux-notify.js`.
2. **NEVER `sleep`/poll manually, NEVER `capture-pane` yourself** — wait for the automatic `<tmux-notify>` (or continue other parallel work; you'll be notified either way). Set `TMUX_TIMEOUT` generously (e.g. 300s) for HITL approval prompts — the approval click itself takes real human time.
3. **Use `raw` ONLY if no dedicated `do` command exists.**

### `bot-info` extras
Returns `about` + `description` (since v4.0.0) via `GetBotInfoRequest(lang_code="")`. If descriptions seem empty: check lang_code mismatch (BotAPI sets fallback, not "en").

### 🔴 New bot setup checklist (GRAVÉ — KπX directive 2026-08-27, never skip)

Creating a bot via `bot-create` is NOT a finished setup. Every new bot MUST also get:

1. **Folder placement** — add it to the **`KpihX-Labs`** Telegram folder (`folder-set` is an UPSERT/**replace**, not additive — always pass the FULL current chat list from `folder-list` PLUS the new bot, never just the new bot alone, or the rest get silently dropped).
2. **An icon (profile photo)** — every bot MUST have one, never left blank. No dedicated `do` action exists for uploading a photo (`bot-photo` only **downloads** an existing one) — the flow goes through BotFather's `/setuserpic` conversation, 3 steps:
   - `raw '{"method":"/setuserpic","protocol":"bf"}'` (✅ HITL, tmux) → BotFather asks "Choose a bot to change photo."
   - `chat-send` (❌ no HITL) to BotFather (ID `93372553`) with the bot's `@username` as plain text — continues the SAME BotFather conversation (state tracked server-side by BotFather, not by the API call).
   - `chat-send-file` (❌ no HITL) to BotFather with the photo file path — sets it.
   - Verify via `chat-read` on BotFather (no success is ever assumed silently).
   - To REUSE another bot's icon: `bot-photo '{"bots":["@source_bot"]}'` downloads it to `/tmp/tg-bot-photos/<username>.jpg` first, then feed that path into `chat-send-file` above.
3. **Missing on an older bot?** Same 2 steps apply retroactively — this checklist is not create-time-only.

---

## Bot Inventory (14 bots, all in `KpihX-Labs` folder)

Ask `tg-proxy do bot-list` for live data. Quick reference:

| @username | Display | ID | Ver | Webhook |
|-----------|---------|----|:---:|:-------:|
| @docker_host_kpihx_bot | Dockerhost | 8036146758 | 1 | ❌ |
| @k_n8n_x_bot | N8N | 8724946664 | 1 | ❌ |
| @k_opencode_bot | OpenCode | 8759560208 | 1 | ❌ |
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

13 of 14 have about+description set (2026-07-26) — `@k_opencode_bot` created 2026-08-27 via `tg-proxy do bot-create` (verified clean via `chat-read` on BotFather, group-join+inline disabled by the automated flow), about/description not yet set (optional polish, skipped to stay token-efficient — consumer: `opencode-notify` plugin, see `k-opencode/SKILL.md`). All tokens in `~/.config/tg-proxy/.env` (this one under `K_OPENCODE_BOT_TOKEN`) — the `.agents` kernel's own copy for the notification plugin lives separately in `~/.agents/.env` as `TELEGRAM_OPENCODE_TOKEN` (KπX adds it manually, secrets zero-touch). All webhooks empty (polling mode). Default capture bot: `@kpihx_general_capture_bot` (ID 8089748360).

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
| 2026-08-27 | [COLAB] | **v4.5.0 — `@k_opencode_bot` setup completed (KπX: "tu n'avais même pas fini le setup") + new GRAVÉ checklist + 2 doc bugs fixed**: `bot-create` alone is NOT a finished setup — added `@k_opencode_bot` to the `KpihX-Labs` Telegram folder (`folder-set` upsert with the FULL 14-bot list, since it replaces rather than appends — verified via `folder-list`, 13→14 chats) and gave it an icon (BotFather `/setuserpic` flow: `raw` HITL via tmux ops pane → `chat-send` with `@k_opencode_bot` → `chat-send-file` with `@kpihx_openclaw_bot`'s own photo, downloaded first via `bot-photo`; verified via `chat-read` on BotFather → "Success! Profile photo updated."). New **"New bot setup checklist (GRAVÉ)"** section documents both steps as mandatory for every future bot, including retroactively for older bots missing either. **2 real doc bugs found and fixed live**: (1) the HITL rule section still said "poll with sleep 3-5s" + "capture-pane" — directly contradicts the `k-tmux` armed-notify discipline established since; rewritten to the current `TMUX_TIMEOUT`/`TMUX_LINES` armed pattern. (2) the HITL status table had `chat-send`/`chat-send-file` marked ❌ (no HITL) — both actually required live browser approval; verified via `tg-proxy` source (`@require_approval()` decorator on both `chat_send`/`chat_send_file` in `client.py`), table corrected ❌→✅. |
| 2026-08-27 | [COLAB] | **v4.4.0 — `@k_opencode_bot` created (14th bot)**, dedicated Telegram bot for the new `opencode-notify` plugin (see `k-opencode/SKILL.md`). Created via `tg-proxy do bot-create` in the tmux ops pane (HITL approval), verified clean via `chat-read` on BotFather (ID `93372553`) per the tool's own post-create instruction — no errors, group-join + inline mode disabled automatically. ID `8759560208`. About/description left unset (optional, skipped to stay token-efficient). Its token stays in `~/.config/tg-proxy/.env` (`K_OPENCODE_BOT_TOKEN`); the `.agents` kernel's own copy (`TELEGRAM_OPENCODE_TOKEN` in `~/.agents/.env`) is added manually by KπX, never by an agent (secrets zero-touch). |
| 2026-08-15 | [COLAB] | **v4.3.0 — Project path updated** (`$HOME/KpihX-Labs/tg_proxy/` → `$HOME/KpihX-Labs/Proxies/tg-proxy/`) after tg-proxy was moved into `proxies/` and aligned to the kebab-case naming convention. |
| 2026-07-26 | [OPENCODE] | **v4.2.0 — Security section added (config dir perms 700/600).** Proactive skill update after tg-proxy README security hardening. |
| [SUMMARY] | — | v4.0.0–v4.1.0 — Full `tg` → `tg-proxy` rewrite + compact condensed. Earlier → `references/log.md`. |
