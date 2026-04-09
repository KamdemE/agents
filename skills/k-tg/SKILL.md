---
name: k-tg
description: tg CLI + Telegram capture/infra-bot loop — Telethon user, BotFather governance, deep *What's up* triage (Issues → General → Homelab/Ubuntu/…), processed cursors in references/.
license: private
metadata:
  author: KpihX
  version: "3.0.2"
  scope: tool-memory
allowed-tools: "Bash(*), Read(*), Glob(*), *"
---

# Tool Memory — Telegram (k-tg)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Operating focus

~**99%** of KπX Telegram use is **loop-back orchestration**: **`tg`**, **BotFather**, **capture bots** (General / Issues), **infrastructure bridge bots** (Homelab, Ubuntu, Tick, Whats, Mail, LinkedIn, N8N), and **your own account** (`tg user`). Groups, channels, and third-party DMs exist but are **out of scope** unless explicitly requested.

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
- **What’s up / Telegram — implementation gate (mandatory):** The slice ends at **concrete, pragmatic** recommendations and **action tracks** (“pistes”) only. **Do not implement** remediations — no TickTick API writes, no mail sends, no writes/copies into `Gdrive_X` or project trees, no service/config/deploy changes, no corrective shell that mutates state — **until** KπX gives **explicit** go-ahead (e.g. *feu vert*, *go*, *OK implémente*). **Read-only** investigation (read logs, inspect files, SSH **diagnostic** cat/grep/journalctl) **is** in scope and expected before proposals. **Exception:** updating this skill’s **`references/telegram-processed-state.md`** and **`references/log.md`** after triage is **bookkeeping** (avoid re-triage), not remediation.

## What's up — Telegram slice (single assistant turn, **k-tg only**)

**Calendar / timezone:** **Europe/Paris** unless KπX specifies otherwise.

This slice is **not** a shallow inbox scan. The agent must **close the diagnostic loop**: ingest, **inspect** (including SSH / logs / scripts when an infra bot reports breakage), and return **actionable** conclusions and **ready-to-run** next steps — not a list of “still TODO” without diagnosis. **Stopping point:** proposals and pistes only; **execution** waits for **Runtime discipline → implementation gate** above.

### Step 0 — Preconditions (blocking)

1. **`tg` / Telethon:** `tg user me` must succeed (session at `$HOME/.config/tg/user.session`).
2. **Capture bots (recommended):** `TELEGRAM_GENERAL_TOKEN` and `TELEGRAM_ISSUES_TOKEN` available (e.g. via `bw-env`) so `tg updates --bot general` / `--bot issues` works.
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

**Escalation examples (non-exhaustive):**

- **Homelab / backup / sentinel errors:** SSH per **`k-homelab`**, inspect **units**, **scripts**, **remote backup** logs, **docker** — do **not** stop at “backup failed” without reading **why**.
- **Ubuntu / cleanup / vault:** read the **report message**, then inspect the **invoked script**, **cron/systemd**, **local logs** on the workstation.
- **Bridge bots (Tick/Whats/Mail/LinkedIn):** correlate with MCP health on homelab + **local** MCP config; propose concrete fixes (restart, token, tunnel, Cursor MCP reload).

After each bot’s pass: **update** `telegram-processed-state.md`.

### Sequential ladder

When KπX runs the **full** *what's up*, **Telegram is the last turn** — **AGENTS.md → What's up** — do **not** combine with mail / WhatsApp / TickTick in one generation.

## Secrets matrix

| Env var | Alias (`tg`) | Purpose |
|---------|----------------|---------|
| `TELEGRAM_GENERAL_TOKEN` | `general` | **General** (display name) — agent inbox |
| `TELEGRAM_ISSUES_TOKEN` | `issues` | **Issues** (display name) — bug/incident inbox |
| `TELEGRAM_HOMELAB_TOKEN` | `homelab` | Sentinel / Homelab |
| `TELEGRAM_UBUNTU_TOKEN` | `ubuntu` | Ubuntu workstation reports |
| `TELEGRAM_N8N_HOMELAB_TOKEN` | `n8n-homelab` | N8N signals |
| `TELEGRAM_*_TOKEN` | `*` auto | Other bridge bots when present |

Also: `TELEGRAM_CHAT_ID` / per-bot `default_chat` in `$HOME/.config/tg/config.yaml` when used.

## Bot inventory

| Group | Bot name | ID | @username | Status |
|-------|----------|----|-----------|--------|
| **Capture** | General | `8089748360` | `@kpihx_general_capture_bot` | **New — add token to Vault** |
| **Capture** | Issues | `8656241501` | `@kpihx_issues_capture_bot` | **New — add token to Vault** |
| **Homelab** | Homelab | `8589111784` | `@sentinel_homelab_bot` | Active |
| **Homelab** | Mail Homelab | `8385666882` | — | Active (token often via `bw-env`) |
| **Homelab** | LinkedIn Homelab | `8662033588` | — | Active (token often via `bw-env`) |
| **Homelab** | Whats Homelab | `8449692658` | — | Active (token often via `bw-env`) |
| **Homelab** | Tick Homelab | `8357989597` | — | Active (token often via `bw-env`) |
| **Homelab** | N8N Homelab | `8724946664` | `@k_n8n_x_bot` | Active |
| **Ubuntu** | Ubuntu | `8331655781` | `@k_ubuntu_bot` | Active |
| **Ubuntu** | Openclaw Ubuntu | `8758962418` | — | **Inactive / token 401** |
| **Ubuntu** | Openclaw Watcher | `8393219020` | — | Inactive |

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

## BotFather quick map

| Command | Use |
|---------|-----|
| `/newbot` | Create capture or infra bot |
| `/token` | Retrieve token (sensitive) |
| `/setcommands` | Bot menu |
| `/setprivacy` | Group message visibility |

Full table lives in older agent transcripts; keep **BotFather id** `93372553` immutable.

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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-09 | [CURSOR] | v3.0.2 — *What’s up / Telegram* **implementation gate**: proposals/pistes only; no remediations until KπX explicit go-ahead; read-only investigation remains mandatory. |
| 2026-04-09 | [CURSOR] | v3.0.1 — BotFather `/setname`: capture bots display names shortened to **General** and **Issues** (@usernames unchanged). |
| [SUMMARY] | — | v3.0.0 capture bots + deep *What's up* + `references/`; v1.5.0–v1.0.0 BotFather tables, `tg` install, prior inventory |
