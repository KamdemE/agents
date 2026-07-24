---
name: k-tg
description: tg CLI + Telegram capture/infra-bot loop — Telethon user, BotFather governance, deep *What's up* triage (Issues → General → Homelab/Ubuntu/…), processed cursors in references/.
license: private
metadata:
  author: KpihX
  version: "3.3.0"
  scope: tool-memory
allowed-tools: "Bash(*), Read(*), Glob(*), *"
---

# KπX — Telegram (`tg` CLI)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Cloud hub

Productivity **orchestration** channel (capture bots, infra bridges, Telethon user) · map: `$HOME/.agents/skills/k-clis/references/cloud-hub.md` · **last** slice in the default *What's up* ladder.

| Leg | Tool | Notes |
|-----|------|--------|
| User + DMs | `tg user` (Telethon) | Session `$HOME/.config/tg/user.session` |
| Capture / bridges | `tg` Bot API + tokens | Vaultwarden — never print tokens |

## Operating focus

~**99%** of KπX Telegram use is **loop-back orchestration**: **`tg`**, **BotFather**, **capture bots** (General / Issues), **infrastructure bridge bots** (Homelab, Ubuntu, S25, Tick, Whats, Mail, LinkedIn, N8N), and **your own account** (`tg user`). Groups, channels, and third-party DMs exist but are **out of scope** unless explicitly requested.

## Default capture bot (mandatory)

When KπX refers to a **send**, **envoi**, **forward**, or **message to the bot** **without** naming which bot:

| Default | Value |
|---------|--------|
| Telegram display name | **KpihX** |
| @username | `@kpihx_general_capture_bot` |
| `tg` alias | `general` |
| Bot user ID | `8089748360` |

**Exception:** use **`issues`** (`@kpihx_issues_capture_bot`) or another bot **only** when KπX explicitly names that bot or its `@username`.

## Identity (Telethon user)

| Field | Value |
|-------|--------|
| Telegram user ID | `1397540599` |
| @username | `@KpihX` |
| Phone | `+33605957785` (E.164 — use only in skills when already public per kernel) |

## Runtime discipline (mandatory)

- Read `$HOME/.agents/skills/k-tg/references/insights.md` before non-trivial Telegram work.
- Read `$HOME/.agents/skills/k-tg/references/telegram-processed-state.md` before a *What's up* **Telegram** slice; **update cursors** after triage in the **same** workstream.
- Append **one** row to `$HOME/.agents/skills/k-tg/references/log.md` after meaningful `tg` / BotFather / triage sessions.
- **BotFather only** for bot create/delete/token/privacy/commands — entity id **`93372553`**.
- **Run-speed policy (immediate minimal):** during active runs, log only **critical** facts (bot id, action, error). Put narratives into deferred curation or `references/log.md` once per slice.
- **No secret exfiltration:** never print full **`TELEGRAM_*_TOKEN`** values in chat; use Vaultwarden names (`TELEGRAM_GENERAL_TOKEN`, `TELEGRAM_ISSUES_TOKEN`, …).
- **`tg send` from non-interactive / agent shells:** use `zsh -l -c '…'` so **`TELEGRAM_*_TOKEN`** values load from `$HOME/.kshrc`. If `tg send` fails with **No chat ID**, **`CHAT_ID` is often not exported globally** — prefix the command with `set -a; source "$HOME/.agents/skills/k-ubuntu/scripts/backup_restore/.env"; set +a` (Phoenix backup module defines the personal notify target alongside the Ubuntu token). Never print `.env` contents.
- **What’s up / Telegram — implementation gate (mandatory):** You must **autonomously perform ALL read-only investigations** (reading screenshots/media, server exploration via SSH, parsing logs and diagnostic files). **Do not require a "go" for inspection**. You are obliged to investigate as deeply as possible yourself before making proposals. If privileged access is required, use the **shared tmux gate** (`k-tmux`) — never `sui` (deprecated) — and poll the pane ≥30s for KπX to approve `sudo`/SSH in tmux. The slice ends at **concrete, pragmatic** recommendations and **action tracks** (“pistes”) only. **Do not implement** remediations (e.g., no TickTick API writes, no mail sends, no service/config mutative changes) **until** KπX gives explicit go-ahead. **Exception:** updating this skill’s **`references/telegram-processed-state.md`** and **`references/log.md`** is bookkeeping, not remediation.

## What's up — Telegram slice (single assistant turn, **k-tg only**)

**Calendar / timezone:** **Europe/Paris** unless KπX specifies otherwise.

This slice is **not** a shallow inbox scan. The agent must **close the diagnostic loop**: ingest, **inspect** (including SSH / logs / scripts when an infra bot reports breakage), and return **actionable** conclusions and **ready-to-run** next steps — not a list of “still TODO” without diagnosis. **Stopping point:** proposals and pistes only; **execution** waits for **Runtime discipline → implementation gate** above.
This slice is also **not a résumé**: deliver maximum available evidence and detail in the first response, with no synthesis-only compression and no deferred-detail prompting.
Treat this as a **batch deep investigation** and stop only once the relevant message/log/evidence set is materially complete.

### Step 0 — Preconditions (blocking)

1. **`tg` / Telethon:** `tg user me` must succeed (session at `$HOME/.config/tg/user.session`).
2. **Capture bots (recommended):** `TELEGRAM_GENERAL_TOKEN` and `TELEGRAM_ISSUES_TOKEN` available (loaded via `.kshrc` or env source) so `tg updates --bot general` / `--bot issues` works.
3. **Cross-skills:** load **`k-homelab`** before **any** SSH / docker-host / Proxmox investigation triggered by Homelab bot alerts; load **`k-ticktick`** / **`k-drive`** when suggestions include tasks or `Gdrive_X` placement.

If Telethon is broken: **STOP** and give recovery steps (`tg user setup`, session file, API id/hash). Do **not** emit the *What's up* body until Step 0 passes or KπX scopes a reduced slice.

### Section 1 — **Issues** capture bot (highest priority)

Display name **Issues** (Telegram). Target: `@kpihx_issues_capture_bot` (**bot user id** `8656241501`).

1. Read **`references/telegram-processed-state.md`** → row `issues`.
2. List **new** user→bot traffic since the last triaged **`message_id`**:
   - Prefer **`tg updates --bot issues`** (Bot API) for structured payloads + file hints.
   - Complement with **`tg user read @kpihx_issues_capture_bot`** for the human-side thread if needed.
3. For **each** new item: classify (bug / incident / env / “needs screenshot”), quote text, note **media**.
4. **Media:** stage under **`$TMPDIR/k-tg/<UTC-ISO>/issues/`** (create dir). If `tg` cannot download yet, document **file_id / message_id** and use Bot API **getFile** (script or manual) — do not pretend binary content was read when only `[Photo]` was shown.
5. **Deep dive mandate:** for each issue, pursue root cause **until** you have a concrete hypothesis validated by **evidence** (log lines, config snippets, command output — **no secrets**). Use `k-homelab` SSH / journal / compose **when** the issue touches servers or backups.
6. **Deliver:** exhaustive per-item **analysis**, **fix proposal**, and **draft** `k-ticktick` / `.md` / `k-mail` **actions** (wording + target) — **do not execute** them in this slice without KπX go-ahead.
7. **Update** `telegram-processed-state.md` with the **latest fully processed** message ids.

### Section 2 — **General** capture bot

Display name **General** (Telegram). Target: `@kpihx_general_capture_bot` (**bot user id** `8089748360`).

Same pipeline as Issues, but theme = **facts, links, credentials reminders (never store secrets in skills)**, school/admin **screenshots**, forward dumps.

- Extract structured facts; propose **where** to persist (`$HOME/Work/techskills/`, project `AGENTS.md`, `k-mail` open threads, **TickTick**) — **describe** the write; **do not** perform it until KπX approves.
- For **school PDFs / transcripts:** suggest **`Gdrive_X`** paths using **`k-drive`** conventions (e.g. academic subtree under `$HOME/Gdrive_X/X/`).
- Update **processed cursors** after triage.

### Section 3 — Infrastructure bots (incoming, priority order)

For **each** bot below, read **new** bot→user messages since the stored cursor (**`tg user read <bot_user_id>`** or `@username` when resolvable). If a bot lacks a token in the **current** env, say so and **still** try **Telethon read** (user inbox).

| Order | Bot | Numeric ID |
|-------|-----|------------|
| 1 | Homelab | `8589111784` |
| 2 | Ubuntu | `8331655781` |
| 3 | Tick Homelab | `8357989597` |
| 4 | Whats Homelab | `8449692658` |
| 5 | LinkedIn Homelab | `8662033588` |
| 6 | Mail Homelab | `8385666882` |
| 7 | N8N Homelab | `8724946664` |
| 8 | S25 | `8557838158` |

**Escalation examples (non-exhaustive):**

- **Homelab / backup / sentinel errors:** SSH per **`k-homelab`**, inspect **units**, **scripts**, **remote backup** logs, **docker** — do **not** stop at “backup failed” without reading **why**.
- **Ubuntu / cleanup / vault:** read the **report message**, then inspect the **invoked script**, **cron/systemd**, **local logs** on the workstation.
- **S25:** phone bridge logs, ADB/SSH connectivity.
- **Bridge bots (Tick/Whats/Mail/LinkedIn):** correlate with MCP health on homelab + **local** MCP config; propose concrete fixes (restart, token, tunnel, Cursor MCP reload).

After each bot’s pass: **update** `telegram-processed-state.md`.

### Sequential ladder

When KπX runs the **full** *what's up*, **Telegram is the last turn** — **AGENTS.md → What's up** — do **not** combine with mail / WhatsApp / TickTick in one generation.

## Secrets matrix

| Env var | Alias (`tg`) | Purpose |
|---------|----------------|---------|
| `TELEGRAM_GENERAL_TOKEN` | `general` | **General** (display name) — agent inbox |
| `TELEGRAM_ISSUES_TOKEN` | `issues` | **Issues** (display name) — bug/incident inbox |
| `TELEGRAM_UBUNTU_BOT` | `pve` | PVE bridge |
| `TELEGRAM_DOCKERHOST_TOKEN` | `dockerhost` | Docker host bridge |
| `TELEGRAM_HOMELAB_TOKEN` | `homelab` | Sentinel / Homelab |
| `TELEGRAM_UBUNTU_TOKEN` | `ubuntu` | Ubuntu workstation reports |
| `TELEGRAM_S25_TOKEN` | `s25` | S25 phone bot |
| `TELEGRAM_N8N_HOMELAB_TOKEN` | `n8n-homelab` | N8N signals |
| `TELEGRAM_TICK_HOMELAB_TOKEN` | `tick-homelab` | Tick MCP bridge (`@tick_homelab_bot`) |
| `TELEGRAM_WHATS_HOMELAB_TOKEN` | `whats-homelab` | Whats MCP bridge (`@whats_homelab_bot`) |
| `TELEGRAM_LINKEDIN_HOMELAB_TOKEN` | `linkedin-homelab` | LinkedIn MCP bridge (`@linkedin_homelab_bot`) |
| `TELEGRAM_MAIL_HOMELAB_TOKEN` | `mail-homelab` | Mail MCP bridge (`@mail_homelab_bot`) |
| `TELEGRAM_*_TOKEN` | `*` auto | Other bots when present |

Also: `TELEGRAM_CHAT_ID` / per-bot `default_chat` in `$HOME/.config/tg/config.yaml` when used.

## Bot inventory

| Group | Bot name | ID | @username | Status |
|-------|----------|----|-----------|--------|
| **Capture** | KpihX (**default** when bot unspecified) | `8089748360` | `@kpihx_general_capture_bot` | Active |
| **Homelab** | Homelab | `8036146758` | `@docker_host_kpihx_bot` | Active |
| **Homelab** | KpihX-Labs | `7975928900` | `@kpihx_labs_bot` | Active |
| **Homelab** | PVE | `8589111784` | `@sentinel_homelab_bot` | Active |
| **Homelab** | Mail | `8385666882` | `@mail_homelab_bot` | Active |
| **Homelab** | LinkedIn | `8662033588` | `@linkedin_homelab_bot` | Active |
| **Homelab** | Whatsapp | `8449692658` | `@whats_homelab_bot` | Active |
| **Homelab** | Ticktick | `8357989597` | `@tick_homelab_bot` | Active |
| **Homelab** | N8N | `8724946664` | `@k_n8n_x_bot` | Active |
| **Homelab** | Flow | `(managed)` | `@kflow_homelab_bot` | Active |
| **OpenClaw** | OpenClaw | `8948919586` | `@kpihx_openclaw_bot` | Active — **OpenClaw gateway** (`TELEGRAM_BOT_TOKEN` in `$HOME/.config/openclaw/gateway.env`; ephemeral export `/tmp/claw.env`) |
| **Ubuntu** | Ubuntu | `8331655781` | `@k_ubuntu_bot` | Active — **infra only** (`/clean`, `/status`, `/backup` via `$HOME/.agents/skills/k-ubuntu/scripts/bot.py`; **not** OpenClaw) |
| **Ubuntu** | Openclaw Watcher | `8393219020` | — | Inactive (legacy) |
| **S25** | S25 | `8557838158` | `@kpihx_s25_bot` | Active — S25 phone bot |

*Third-party bots (e.g. “Nano Banana”, “ChatGPT”) are **not** KπX infra — exclude from *What's up* unless KπX asks.*

## Source of truth (tooling)

| Item | Path |
|------|------|
| `tg` project | `$HOME/Work/Tools/tg/` |
| Shim | `$HOME/.local/bin/tg` |
| Optional YAML | `$HOME/.config/tg/config.yaml` |

## Install / repair

```bash
uv tool install --editable $HOME/Work/Tools/tg
tg --help
```

## BotFather (entity id **`93372553`**)

Compact command map (official names — always use BotFather, never third-party “bot managers”):

| Area | Commands |
|------|----------|
| **Entry** | `/start` · `/help` (full list) |
| **Lifecycle** | `/newbot` · `/mybots` (manager) · `/deletebot` |
| **Profile / UX** | `/setname` · `/setdescription` · `/setabouttext` · `/setuserpic` · `/setcommands` · `/setdomain` |
| **Security** | `/token` **(sensitive)** · `/revoke` |
| **Groups** | `/setprivacy` · `/setjoingroups` |
| **Inline** | `/setinline` · `/setinlinegeo` · `/setinlinefeedback` |
| **Web Apps** | `/newapp` · `/myapps` · `/listapps` · `/editapp` · `/deleteapp` |
| **Games** | `/newgame` · `/mygames` · `/listgames` · `/editgame` · `/deletegame` |

### Operational snippets (`tg user`)

**Token (copy from BotFather message into Vault — do not paste into skills or chat):**

```bash
tg user send 93372553 "/token"
sleep 3 && tg user read 93372553 --limit 6
# If prompted for which bot:
tg user send 93372553 "@your_bot_username"
```

**New bot:** `/newbot` → display name → `@username` ending in `bot` → read last BotFather message for token.

**Set commands menu:** `/setcommands` → pick `@bot` → paste `command - Description` lines (or `/empty`).

**Delete bot:** `/deletebot` → select bot (CLI may need Telegram UI for inline keyboards; or use Telethon `click` on `/mybots` rows).

**Audit DM (no bot token):** `tg user read <bot_user_id> --limit 50`

**Ephemeral token files:** one-off exports may land under `$TMPDIR/tokens/` (e.g. `/tmp/tokens/*.env`) or **`/tmp/claw.env`** (OpenClaw bot) — **chmod 600**, import into Vaultwarden, then **delete** local copies.

**Full token from BotFather (CLI):** use the **`uv tool install` shim** python, not the project venv — `$(dirname $(readlink -f $(which tg)))/python3 -c "from tg import user as u; …"` with `u.get_messages(93372553)` and regex on message text (display in `tg user read` truncates).

## Command surface (essentials)

| Command | Role |
|---------|------|
| `tg bots` / `tg status` | Bot API identity (needs tokens in env) |
| `tg updates -n N --bot ALIAS` | Bot-side inbox (capture + bridges) |
| `tg user me` / `read` / `send` | Telethon user (human-side DMs) |
| `tg send` / `tg updates` | Bot API send / poll |

## Runtime memory layout

| File | Role |
|------|------|
| `references/telegram-processed-state.md` | Last triaged **message_id**s per chat |
| `references/log.md` | Action log |
| `references/insights.md` | Durable patterns |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-tg/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-tg/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-23 | [OPENCODE] | v3.3.0 — Created **`@kpihx_s25_bot`** (S25, id **8557838158**) via BotFather; tokens written to `/tmp/a.txt` for setup; added to k-tg inventory + secrets matrix + infra bot list. |
| [SUMMARY] | — | v3.2.13 OpenClaw bot + folder; v3.2.12 Cloud hub; v3.2.11 default bot + Lebara PDF; v3.2.10 tg send/CHAT_ID; v3.2.9–v3.2.3 → references/log.md |
