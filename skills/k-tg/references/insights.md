# k-tg — durable insights

> Update when a **reusable** Telegram / `tg` pattern appears (tokens, BotFather, capture workflow, infra-bot triage).

## Capture bots

- **Default bot (unspecified send):** when KπX says *send/envoi/forward to the bot* without naming one → **`@kpihx_general_capture_bot`** (display **KpihX**, alias `general`). **Issues** only when explicitly named.
- **Display names (Telegram):** **General** and **Issues** — `@kpihx_general_capture_bot` / `@kpihx_issues_capture_bot` are unchanged unless Bot Support renames handles.
- **Vault / bw-env:** store API tokens as **`TELEGRAM_GENERAL_TOKEN`** and **`TELEGRAM_ISSUES_TOKEN`** → `tg` aliases **`general`** and **`issues`** (auto-discovered).
- **First DM:** use `@username` with `tg user send` (numeric bot id may not resolve until entity cache warms).
- **Token display:** BotFather messages may be **truncated** in `tg user read` output — use BotFather **`/token`** or the Telegram client to copy the **full** secret into Vaultwarden.

## Infra bots

- **`tg send` (SENSY / bot→user pushes) in Agent shells:** run `zsh -l -c 'set -a; source "$HOME/Work/sh/backup_restore/.env"; set +a; tg send --bot ubuntu --plain "…"'` so **tokens** come from the login shell and **`CHAT_ID`** comes from the Phoenix backup notifier config (global login shell often has tokens but **not** `CHAT_ID`).
- **`tg bots`** only lists bots with **`TELEGRAM_*_TOKEN`** present in the **current** environment; load `bw-env` (or `set -a; source /tmp/tokens/*.env; set +a` **temporarily**) so all aliases appear.
- Homelab MCP bridges use **`@tick_homelab_bot`**, **`@whats_homelab_bot`**, **`@linkedin_homelab_bot`**, **`@mail_homelab_bot`** (see **`## Bot inventory`** in `SKILL.md`).
- **Openclaw Ubuntu** was retired — remove **`TELEGRAM_OPENCLAW_UBUNTU_TOKEN`** from any secret shell if it is still exported.

## Media

- **`tg user read`** surfaces media as `[Type]` placeholders — for PDF/photo **ingestion**, use **`tg user download @kpihx_general_capture_bot <msg_id> -o $HOME/.cache/k-tg/<run-id>/`** (works without bot token in env; avoid bare `$TMPDIR` paths — can be empty → `PermissionError`). Bot API path: **`tg updates --download-media`** when `TELEGRAM_GENERAL_TOKEN` is loaded.

## Lebara eSIM (2026-05-25)

- Android generic **« Checking SIM information… » → An error occurred. Please try again. »** during QR scan is often **network/provisioning** (SM-DP+ `leb.prod.ondemandconnectivity.com`), not a bad PDF — **disable VPN** first if status bar shows VPN key.
- Lebara PDF ships **LPA string** (`LPA:1$<SM-DP+>$<activation>`) — prefer **manual entry** (*Enter code instead*) over re-scanning QR after repeated failures (codes may be partially consumed).
- Two orders = two distinct activation codes; do not mix profiles. Check **Settings → SIM manager** for a ghost/pending Lebara eSIM before re-adding.

## What’s up — implementation gate

- End the Telegram slice with **concrete** options and **pistes**; **never** apply fixes, file moves, TickTick/mail writes, or mutating infra actions **without** KπX **explicit** approval after the briefing.
