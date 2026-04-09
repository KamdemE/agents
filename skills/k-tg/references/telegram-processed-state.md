# Telegram — processed cursors (What's up / k-tg)

> Source of truth for **last fully triaged messages** per chat. After each *What's up* **Telegram** slice, update the relevant rows in the **same workstream**.
> Message IDs are **Telegram** identifiers (channel-specific). Use **monotonic** `message_id` ordering within each chat.

## Capture DMs (you → bot)

These chats collect **outbound** content from `$USER` for agent ingestion (`issues` first, `general` second in *What's up*).

| Bot alias | Display name | @username | Bot user ID | Chat notes | Last triaged outbound `message_id` (from you) | Last triaged inbound `message_id` (bot) | Agent run (ISO date) |
|-----------|--------------|-----------|-------------|------------|-----------------------------------------------|----------------------------------------|----------------------|
| `issues` | Issues | `@kpihx_issues_capture_bot` | `8656241501` | Bugs / incidents / screenshots | — | — | — |
| `general` | General | `@kpihx_general_capture_bot` | `8089748360` | Facts, screenshots, forward dumps | — | — | — |

## Infrastructure bots (bot → you)

Order for **section 3** of *What's up* (after capture bots). Triaged = alert read, escalations executed, and concrete follow-ups written.

| Priority | Bot name | User ID | @username (if set) | Last triaged `message_id` | Agent run (ISO date) |
|----------|----------|---------|---------------------|---------------------------|----------------------|
| 1 | Homelab | `8589111784` | `@sentinel_homelab_bot` | — | — |
| 2 | Ubuntu | `8331655781` | `@k_ubuntu_bot` | — | — |
| 3 | Tick Homelab | `8357989597` | *(token often via `bw-env` — set when known)* | — | — |
| 4 | Whats Homelab | `8449692658` | *(token often via `bw-env` — set when known)* | — | — |
| 5 | LinkedIn Homelab | `8662033588` | *(token often via `bw-env` — set when known)* | — | — |
| 6 | Mail Homelab | `8385666882` | *(token often via `bw-env` — set when known)* | — | — |
| 7 | N8N Homelab | `8724946664` | `@k_n8n_x_bot` | — | — |

## Inactive / legacy

| Bot name | User ID | Note |
|----------|---------|------|
| Openclaw Ubuntu | `8758962418` | **401** with current token — rotate or drop `TELEGRAM_OPENCLAW_UBUNTU_TOKEN` if unused |
| Openclaw Watcher | `8393219020` | Inactive — do not use |

## Self-DM loopback (optional)

| Chat | Telegram user ID | Purpose |
|------|------------------|---------|
| Saved Messages / `@KpihX` | `1397540599` | Optional “note to self”; treat like low-priority capture unless tagged |
