---
name: k-tg
description: tg CLI operational memory — local source path, uv tool install pattern, user workflow commands, and troubleshooting notes for ModuleNotFoundError/import issues.
license: private
metadata:
  author: KpihX
  version: "1.5.0"
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

## Bot Manager Mode (BotFather)

> [!IMPORTANT]
> **MASTER RULE:** All bot administration, lifecycle management (creation/deletion), and global security settings (token rotation, privacy, commands) **MUST** pass through **BotFather** (`93372553`). This is the exclusive and mandatory gateway for bot governance.

Use `tg user` to communicate with BotFather directly from the CLI. This ensures full transparency and centralized control without depending on the Telegram UI.

### BotFather Reference (ID: `93372553`)

| Category | Command | Description |
|----------|---------|-------------|
| **General** | `/start` | Activate BotFather and see intro |
| | `/help` | **(ROOT)** Show this exhaustive command list |
| **Lifecycle** | `/newbot` | Initialize and create a new Telegram bot |
| | `/mybots` | **(MANAGER)** Entry point to edit/manage all your existing bots |
| | `/deletebot` | Irreversibly delete a bot and its token |
| **Profile & UX** | `/setname` | Update the bot's public display name |
| | `/setdescription` | Update the "What can this bot do?" long-form text |
| | `/setabouttext` | Update the short blurb seen on the bot's profile |
| | `/setuserpic` | Upload/Change the bot's profile avatar photo |
| | `/setcommands` | **(UI)** Define the '/' command list for the user menu |
| | `/setdomain` | Bind a website domain (mandatory for some Link/Web login features) |
| **Security** | `/token` | **(SENSITIVE)** Generate or view the Bot API token |
| | `/revoke` | Immediately kill current token and issue a new one |
| **Group Settings** | `/setprivacy` | Toggle if bot can read all group messages (OFF) or only '/' commands (ON) |
| | `/setjoingroups` | Toggle if the bot can be added to Telegram groups at all |
| **Capabilities** | `/setinline` | Enable/Disable Inline Mode (use bot from anywhere via @username) |
| | `/setinlinegeo` | Toggle requests for location in Inline Mode |
| | `/setinlinefeedback` | Adjust how much feedback the bot gets about inline usage |
| **Web Apps** | `/newapp` | Create a new integrated Telegram Web App |
| | `/myapps` | Manage and edit your existing Web Apps |
| | `/listapps` | View the full list of your registered Web Apps |
| | `/editapp` | Modify configuration for a specific Web App |
| | `/deleteapp` | Remove a Web App registration |
| **Games** | `/newgame` | Create a new interactive Telegram game |
| | `/mygames` | Manage and edit your game catalog |
| | `/listgames` | View the full list of your registered games |
| | `/editgame` | Modify configuration for a specific game |
| | `/deletegame` | Remove a game from the platform |

### Operational Patterns (Bot Management)

**1. Retrieve a Bot Token:**
```bash
tg user send 93372553 "/token"
# Wait 3s then read
tg user read 93372553 --limit 5
# If prompted, send the bot's @username
tg user send 93372553 "@k_your_bot"
```

**2. Audit Bot Interactions (User Perspective):**
To see what a bot is receiving or sending (even if you don't have the token), use the User API:
```bash
tg user read <bot_id> --limit 50
```

**3. Set Bot Commands:**
```bash
tg user send 93372553 "/setcommands"
# Follow prompts to select bot and send command list:
# status - Get current system status
# help - Show available commands
```

### Rich Operational Examples

**1. Creating a New Assistive Bot (Full Cycle):**
```bash
# A. Start sequence
tg user send 93372553 "/newbot"
# B. Provide display name (after reading BotFather reply)
tg user send 93372553 "My Helper Bot"
# C. Provide unique @username
tg user send 93372553 "k_my_helper_bot"
# D. Retrieve API Token from the confirmation message
tg user read 93372553 --limit 3
```

**2. Deleting an Obsolete Bot:**
```bash
tg user send 93372553 "/deletebot"
# Wait and read the list of bots
tg user read 93372553 --limit 10
# Select the bot by its @username or by sending the confirmation string if prompted
tg user send 93372553 "@k_obsolete_bot"
# Confirm deletion (usually by sending 'Yes, I am totally sure.')
tg user send 93372553 "Yes, I am totally sure."
```

**3. Automated Command Dispatch & Retrieval:**
To verify a bot's logic remotely (e.g., the new /clean command):
```bash
# A. Trigger the action
tg user send <bot_id> "/clean"
# B. Monitor the 'typing' status or wait for the initial 'Starting...' message
tg user read <bot_id> --limit 1
# C. Final Verification: read the result report once complete
tg user read <bot_id> --limit 5

**4. Audit Bot History (Full Report Retrieval):**
To see the latest automated reports (e.g., Weekly Cleanup):
```bash
tg user read 8331655781 --limit 50
# Search for specific reports in history
tg user read 8331655781 --limit 100 | grep -C 5 "Cleanup Report"
```
```

**4. Setting Command Menu for an Infrastructure Bot:**
```bash
tg user send 93372553 "/setcommands"
tg user send 93372553 "@k_ubuntu_bot"
# Send the pre-formatted list:
tg user send 93372553 "status - Global health audit
clean - Full system maintenance
backup - Run workstation backup
vault - Verify Bitwarden RAM bridge"
```

## API Boundaries

- Bot API layer is stateless and token-scoped: strong for bot operations, limited to bot permissions.
- User API layer (Telethon/MTProto) is broader for personal-account actions, but still constrained by Telegram permissions and rate limits.
- `tg` does not auto-load `.env`; secrets must already exist in process env (for example via `bw-env`) or in `$HOME/.config/tg/config.yaml` where supported.

## Common Pitfalls

- Installing `tg` from index instead of local source can remove expected executable behavior.
- A stale uv tool venv can keep a launcher while dropping the importable module.
- Debug from launcher shebang first, then receipt binding, then reinstall editable.

## Bot Inventory

| Group | Bot Name | ID | Status | Mission |
|-------|----------|----|--------|---------|
| **Ubuntu** | Ubuntu | `8331655781` | Active | kpihx-ubuntu weekly cleanup reports |
| | Openclaw Ubuntu | `8758962418` | **Inactive** | Assistive server bot |
| | Openclaw Watcher | `8393219020` | **Inactive** | *Uninstalled* (was responsible for group surveillance) |
| **Homelab** | Homelab | `8589111784` | Active | Sentinel system status (default_bot) |
| | Mail Homelab | `8385666882` | Active | mail-mcp health & bridge |
| | LinkedIn Homelab | `8662033588` | Active | linkedin-mcp health & bridge |
| | Whats Homelab | `8449692658` | Active | whats-mcp health & bridge |
| | Tick Homelab | `8357989597` | Active | tick-mcp health & bridge |
| | N8N Homelab | `8724946664` | Active | N8N workflow signals |

*Note: Nano Banana (`8442646954`) and ChatGPT are not KpihX private bots and are excluded from this inventory.*

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-07 | [GEMINI] | v1.5.0 — Added history audit commands (tg user read + grep) for report retrieval. |
| 2026-04-07 | [GEMINI] | v2.5.0 — Mandated Telegram reporting at the end of optimization cycles. |
| [SUMMARY] | — | v2.4.1 Phoenix loop; v1.3.0 Bot Manager; v1.2.0 Bot Inventory; v1.1.1–v1.0.0 Initial setup |
