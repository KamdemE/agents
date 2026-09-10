# k-tg — durable insights

> Update when a **reusable** Telegram / `tg` pattern appears (tokens, BotFather, capture workflow, infra-bot triage).

## Capture bots

- **Default bot (unspecified send):** when  says *send/envoi/forward to the bot* without naming one → **`@kpihx_general_capture_bot`** (display ****, alias `general`). **Issues** only when explicitly named.
- **Display names (Telegram):** **General** and **Issues** — `@kpihx_general_capture_bot` / `@kpihx_issues_capture_bot` are unchanged unless Bot Support renames handles.
- **Vault:** store API tokens as **`TELEGRAM_GENERAL_TOKEN`** and **`TELEGRAM_ISSUES_TOKEN`** → `tg` aliases **`general`** and **`issues`** (auto-discovered).
- **First DM:** use `@username` with `tg user send` (numeric bot id may not resolve until entity cache warms).
- **Token display:** BotFather messages may be **truncated** in `tg user read` output — use BotFather **`/token`** or the Telegram client to copy the **full** secret into Vaultwarden.

## Infra bots

- **`tg send` (SENSY / bot→user pushes) in Agent shells:** run `set -a; source "$HOME/.agents/skills/k-ubuntu/scripts/backup_restore/.env"; set +a; tg send --bot ubuntu --plain "…"` so **tokens** `CHAT_ID` come from the Phoenix backup notifier config.
- **`tg bots`** only lists bots with **`TELEGRAM_*_TOKEN`** present in the **current** environment; ensure tokens are loaded (via `.kshrc` or env source) so all aliases appear.
- Homelab MCP bridges use **`@tick_homelab_bot`**, **`@whats_homelab_bot`**, **`@linkedin_homelab_bot`**, **`@mail_homelab_bot`** (see **`## Bot inventory`** in `SKILL.md`).
- **OpenClaw Telegram** (2026-05-27): dedicated bot **`@kpihx_openclaw_bot`** (id **8948919586**). Gateway token = **`TELEGRAM_BOT_TOKEN`** in `$HOME/.config/openclaw/gateway.env`. Use **`dmPolicy: allowlist`** + **`allowFrom: [1397540599]`** — no pairing. Place the bot in the Telegram **folder** **Labs** (filter id **11**) and **pin** the DM (not a new Telegram group). **`@k_ubuntu_bot`** = infra-only (`bot.py`).
- **Openclaw Ubuntu** was retired — remove **`TELEGRAM_OPENCLAW_UBUNTU_TOKEN`** from any secret shell if it is still exported.

## Media

- **`tg user read`** surfaces media as `[Type]` placeholders — for PDF/photo **ingestion**, use **`tg user download @kpihx_general_capture_bot <msg_id> -o $HOME/.cache/k-tg/<run-id>/`** (works without bot token in env; avoid bare `$TMPDIR` paths — can be empty → `PermissionError`). Bot API path: **`tg updates --download-media`** when `TELEGRAM_GENERAL_TOKEN` is loaded.

## Lebara eSIM (2026-05-25)

- Android generic **« Checking SIM information… » → An error occurred. Please try again. »** during QR scan is often **network/provisioning** (SM-DP+ `leb.prod.ondemandconnectivity.com`), not a bad PDF — **disable VPN** first if status bar shows VPN key.
- Lebara PDF ships **LPA string** (`LPA:1$<SM-DP+>$<activation>`) — prefer **manual entry** (*Enter code instead*) over re-scanning QR after repeated failures (codes may be partially consumed).
- Two orders = two distinct activation codes; do not mix profiles. Check **Settings → SIM manager** for a ghost/pending Lebara eSIM before re-adding.

## What’s up — implementation gate

- End the Telegram slice with **concrete** options and **pistes**; **never** apply fixes, file moves, TickTick/mail writes, or mutating infra actions **without**  **explicit** approval after the briefing.
