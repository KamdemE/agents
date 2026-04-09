# k-tg — durable insights

> Update when a **reusable** Telegram / `tg` pattern appears (tokens, BotFather, capture workflow, infra-bot triage).

## Capture bots

- **Display names (Telegram):** **General** and **Issues** — `@kpihx_general_capture_bot` / `@kpihx_issues_capture_bot` are unchanged unless Bot Support renames handles.
- **Vault / bw-env:** store API tokens as **`TELEGRAM_GENERAL_TOKEN`** and **`TELEGRAM_ISSUES_TOKEN`** → `tg` aliases **`general`** and **`issues`** (auto-discovered).
- **First DM:** use `@username` with `tg user send` (numeric bot id may not resolve until entity cache warms).
- **Token display:** BotFather messages may be **truncated** in `tg user read` output — use BotFather **`/token`** or the Telegram client to copy the **full** secret into Vaultwarden.

## Infra bots

- **`tg bots`** only lists bots with **`TELEGRAM_*_TOKEN`** present in the **current** environment; several homelab bridge bots may exist but only appear after `bw-env` (or similar) loads their tokens.
- **Openclaw Ubuntu** may show **401** if the token is revoked — clean up env vars to avoid noisy errors.

## Media

- **`tg user read`** surfaces media as `[Type]` placeholders — for PDF/photo **ingestion**, combine **`tg updates --bot <alias>`** (Bot API) with a small **getFile** download into `$TMPDIR/k-tg/<run-id>/`, or extend the `tg` tool when a subcommand exists.

## What’s up — implementation gate

- End the Telegram slice with **concrete** options and **pistes**; **never** apply fixes, file moves, TickTick/mail writes, or mutating infra actions **without** KπX **explicit** approval after the briefing.
