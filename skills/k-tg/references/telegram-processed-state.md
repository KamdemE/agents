# Telegram — processed cursors (What's up / k-tg)

> Source of truth for **last fully triaged messages** per chat. After each *What's up* **Telegram** slice, update the relevant rows in the **same workstream**.
> Message IDs are **Telegram** identifiers (channel-specific). Use **monotonic** `message_id` ordering within each chat.

## Capture DMs (you → bot)

These chats collect **outbound** content from `$USER` for agent ingestion (`issues` first, `general` second in *What's up*).

| Bot alias | Display name | @username | Bot user ID | Chat notes | Last triaged outbound `message_id` (from you) | Last triaged inbound `message_id` (bot) | Agent run (ISO date) |
|-----------|--------------|-----------|-------------|------------|-----------------------------------------------|----------------------------------------|----------------------|
| `issues` | Issues | `@kpihx_issues_capture_bot` | `8656241501` | Bugs / incidents / screenshots | 6871 | — | 2026-04-09 |
| `general` | General | `@kpihx_general_capture_bot` | `8089748360` | Facts, screenshots, forward dumps | 6914 | — | 2026-04-11 |

## Infrastructure bots (bot → you)

Order for **section 3** of *What's up* (after capture bots). Triaged = alert read, escalations executed, and concrete follow-ups written.

| Priority | Bot name | User ID | @username (if set) | Last triaged `message_id` | Agent run (ISO date) |
|----------|----------|---------|---------------------|---------------------------|----------------------|
| 1 | Homelab | `8589111784` | `@sentinel_homelab_bot` | 6939 | 2026-04-11 |
| 2 | Ubuntu | `8331655781` | `@k_ubuntu_bot` | 6919 | 2026-04-11 |
| 3 | Tick Homelab | `8357989597` | `@tick_homelab_bot` | — | — |
| 4 | Whats Homelab | `8449692658` | `@whats_homelab_bot` | — | — |
| 5 | LinkedIn Homelab | `8662033588` | `@linkedin_homelab_bot` | — | — |
| 6 | Mail Homelab | `8385666882` | `@mail_homelab_bot` | — | — |
| 7 | N8N Homelab | `8724946664` | `@k_n8n_x_bot` | — | — |

## Inactive / legacy

| Bot name | User ID | Note |
|----------|---------|------|
| Openclaw Watcher | `8393219020` | Inactive — do not use |

## Self-DM loopback (optional)

| Chat | Telegram user ID | Purpose |
|------|------------------|---------|
| Saved Messages / `@KpihX` | `1397540599` | Optional “note to self”; treat like low-priority capture unless tagged |
| general | 7533 | 2026-05-06 | Processed Julius Caesar PDFs |
