---
name: k-microsoft
description: >
  KπX Microsoft stack — m365 (M365/Graph content) only. Azure CLI (az) deactivated
  (no subscription). Load before Microsoft 365 tasks. Mail briefings → k-mail.
license: private
metadata:
  author: KpihX
  version: "1.4.0"
  scope: operations
allowed-tools: Bash(m365:*)
---

# KπX — Microsoft 365 (`m365`)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Cloud hub

Registry map: `$HOME/.agents/skills/k-clis/references/cloud-hub.md` · load **`k-clis`** when routing across providers.

## Azure CLI (`az`) — deactivated

| Status | Reason |
|--------|--------|
| **OFF** | No Azure subscription on KπX workstation — container plane not used |
| **CLI** | `azure-cli` **removed** from system; do not reinstall without a subscription + explicit KπX decision |
| **Agents** | **Never** invoke `az`, suggest `az login`, or read `$HOME/.azure/` for Microsoft work |

**Microsoft universe on KπX = `m365` only** (Graph: Outlook, OneDrive, Calendar, To Do, Teams, Planner, raw `m365 request`).

For Azure Foundry / AOAI deploy **if** a subscription exists later → external skill **`microsoft-foundry`** (not this stack); re-enable `az` only then.

## Tool (verify with `!<cmd>`)

| Binary | Runbook |
|--------|---------|
| `m365` | `$HOME/Work/techskills/m365-cli.md` |

**Agent auth (mandatory):** never `m365 login` / `logout` / `setup` — KπX only. Read/status + approved reads. Mail gates: **`k-mail`**.

### Session persistence (v11 — mandatory)

| Layer | Lifetime | KπX notes |
|-------|----------|-----------|
| **Access token** | ~1 h | Auto-refreshed by CLI; no re–device-code each hour |
| **Refresh token** | **90 days** idle (Microsoft default, MSA `consumers`) | Not configurable on personal Hotmail; password change / “sign out everywhere” revokes early |

**Token files (do not delete unless `m365 logout`):** `$HOME/.cli-m365-msal.json`, `$HOME/.cli-m365-connection.json`, `$HOME/.cli-m365-all-connections.json`.  
**Obsolete paths (ignore):** `$HOME/.config/m365`, `$HOME/.local/share/m365`.

**Stable config (KπX sets once):**

```bash
m365 cli config set --key authType --value deviceCode
m365 cli config set --key tenantId --value consumers
m365 cli config set --key autoOpenLinksInBrowser --value false
m365 cli config set --key copyDeviceCodeToClipboard --value false
```

**Health check (prefer over `status` alone):** `m365 request --url "https://graph.microsoft.com/v1.0/me" --method get --output json` → `userPrincipalName`.  
`m365 status` may show **`connectedAs` empty** while Graph works — see **`k-mail`** + `references/insights.md`.

**Inbox reads:** avoid `--folderName Inbox` when Graph Inbox `totalItemCount` is 0 on MSA; use `m365 outlook message list` without folder or `m365 request` on `/me/messages`. Details → **`k-mail`**.

Escape hatch: `m365 request --url "https://graph.microsoft.com/v1.0/..." --method get`

```bash
m365 request --url "https://graph.microsoft.com/v1.0/me" --method get --output json
m365 outlook message list --output json --query "[0:10].{subject:subject,from:from.emailAddress.address}"
m365 onedrive list
m365 outlook event list --query '$top=10&$select=subject,start,end'
```

## Explore Microsoft (m365 map)

| Area | Entry commands | Skill pair |
|------|----------------|------------|
| **Mail** | `m365 outlook message list/get` | **`k-mail`** |
| **Calendar** | `m365 outlook event list` | this skill |
| **OneDrive** | `m365 onedrive list`, `m365 file get` | this skill |
| **To Do** | `m365 todo task list` | **`k-tick`** (dedupe) |
| **Planner** | `m365 planner plan list` | this skill |
| **Teams** | `m365 teams message list` (if licensed) | this skill |
| **Contacts** | `m365 request` → `/me/contacts` | `scripts/m365_inspect_contacts.py` |
| **Search** | `m365 search` | this skill |
| **Anything else Graph** | `m365 request --url …` | this skill |

Poly academic mail: **mail-mcp** — not `m365`.

## Mail routing

| Mailbox | Tool | Skill |
|---------|------|-------|
| Hotmail / Outlook | `m365 outlook *` | **`k-mail`** + this skill |
| Poly Zimbra | mail-mcp | **`k-mail`** — not `m365` |

What's up: Zimbra canonical; dedupe Outlook — **`k-mail`**.

## MCP / future

| Now | Optional later |
|-----|----------------|
| CLI `m365` | `ms-365-mcp-server` if native MCP needed |
| | `references/mcp-cli-vision.md` (ts-proxy model) |

## Pre-Fluid scripts (until level-up)

**Until** the Fluid **ts-proxy**-style bridge (see `references/mcp-cli-vision.md`), agents **must prefer** `$HOME/.agents/skills/k-microsoft/scripts/` over ad-hoc `/tmp` glue.

| Script | When to run |
|--------|-------------|
| `m365_inspect_status.py` | Auth/session check — **never** `m365 login` / `logout` / `setup` |
| `m365_inspect_inbox.py` | Recent Outlook folder messages (`--folder Inbox`) |
| `m365_inspect_contacts.py` | Graph contacts via `m365 request` (`--top`) |

**Inventory + examples:** `scripts/README.md` · shared helpers: `scripts/_m365_common.py`.

**Agent ownership (mandatory):** keep `scripts/` ordered; document every script in `README.md` + this table; bump version + Changelog when behavior changes. **Forbidden** in scripts: login/logout/setup commands.

```bash
python3 "$HOME/.agents/skills/k-microsoft/scripts/m365_inspect_inbox.py" --folder Inbox
```

## Cross-skills

| Task | Load |
|------|------|
| Mail briefing / send gates | `k-mail` |
| Azure Foundry (only if subscription later) | `microsoft-foundry` — not active on this workstation |
| Registry | `k-clis` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-microsoft/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-microsoft/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-25 | [CURSOR] | v1.4.0 — Session persistence: `~/.cli-m365-*`, deviceCode+consumers, `/me` check. |
| 2026-05-25 | [CURSOR] | v1.3.0 — **`az` deactivated**; skill = **m365-only**. |
| [SUMMARY] | — | v1.2.x `scripts/_m365_common.py` helpers; v1.1.0 cloud-hub; v1.0.0 m365+az. |
