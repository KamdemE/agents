---
name: k-tg
description: tg CLI operational memory — local source path, uv tool install pattern, user workflow commands, and troubleshooting notes for ModuleNotFoundError/import issues.
license: private
metadata:
  author: KpihX
  version: "1.1.1"
  scope: tool-memory
allowed-tools: "Bash(*), *"
---

# Tool Memory — tg CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Purpose

Use this skill before working with the `tg` CLI so runtime fixes and usage patterns stay consistent.

## Source Of Truth

| Item | Path |
|------|------|
| Local project root | `$HOME/Work/Tools/tg/` |
| Tool shim | `$HOME/.local/bin/tg` |
| uv tool env | `$HOME/.local/share/uv/tools/tg/` |

Do not treat global PyPI `tg` as source of truth for KpihX runtime behavior.

## Install / Repair

Preferred install is editable from local source:

```bash
uv tool install --editable $HOME/Work/Tools/tg
```

If launcher breaks with `ModuleNotFoundError: No module named 'tg'`:

```bash
uv tool install --editable $HOME/Work/Tools/tg
```

Verification:

```bash
tg --help
tg user chats --limit 5
```

## Runtime Checks

```bash
command -v tg
ls -l $(command -v tg)
sed -n '1,40p' $(command -v tg)
sed -n '1,80p' $HOME/.local/share/uv/tools/tg/uv-receipt.toml
```

Expected receipt pattern:

- `requirements` includes editable source at `$HOME/Work/Tools/tg`
- entrypoint `from = "tg"`

## Command Surface (Runtime Help)

From `tg --help`:

- `bots` — list configured bots with Telegram identity
- `status` — bot identity/capabilities/webhook status
- `send` — send message via bot
- `updates` — fetch recent bot updates
- `version` — show tg version
- `webhook` — webhook management
- `commands` — bot command management
- `chat` — chat/group inspection
- `user` — Telethon user-account commands

From `tg user --help`:

- `setup`, `me`, `chats`, `read`, `send`, `edit`, `delete`, `contacts`

From `tg webhook --help`:

- `get`, `set`, `del`

From `tg commands --help`:

- `get`, `set`

From `tg chat --help`:

- `info`, `admins`

## Secrets Matrix

| Secret | Required For | Purpose |
|--------|---------------|---------|
| `TELEGRAM_<ALIAS>_TOKEN` | Bot API commands (`bots`, `status`, `send`, `updates`, `webhook`, `commands`, `chat`) | Authenticates one Telegram bot; alias is derived from env var name. |
| `CHAT_ID` | Bot `send` fallback | Default target chat when `--to` is not provided. |
| `TG_API_ID` | `tg user *` | Telethon user API key id for MTProto login. |
| `TG_API_HASH` | `tg user *` | Telethon user API hash paired with `TG_API_ID`. |

Additional local auth artifact:

- `$HOME/.config/tg/user.session` — Telethon persisted login session after OTP setup.

## API Boundaries

- Bot API layer is stateless and token-scoped: strong for bot operations, limited to bot permissions.
- User API layer (Telethon/MTProto) is broader for personal-account actions, but still constrained by Telegram permissions and rate limits.
- `tg` does not auto-load `.env`; secrets must already exist in process env (for example via `bw-env`) or in `$HOME/.config/tg/config.yaml` where supported.

## Common Pitfalls

- Installing `tg` from index instead of local source can remove expected executable behavior.
- A stale uv tool venv can keep a launcher while dropping the importable module.
- Debug from launcher shebang first, then receipt binding, then reinstall editable.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-06 | [CLAUDE] | v1.1.1 — AGENTS path compliance: `$HOME` for tg config/session paths; `allowed-tools` aligned with other `k-*` skills |
| 2026-04-05 | [COPILOT] | v1.1.0 — synced skill with live `tg --help` command surface, added secrets matrix (`TELEGRAM_*_TOKEN`, `CHAT_ID`, `TG_API_ID`, `TG_API_HASH`), and clarified Bot API vs User API boundaries |
| [SUMMARY] | — | v1.0.0 initial install/repair + diagnostics; command/help and auth-boundary alignment |
