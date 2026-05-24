---
name: k-microsoft
description: >
  KπX Microsoft stack — az (Azure container) and m365 (M365/Graph content only).
  Load before Azure or Microsoft 365 tasks. Mail briefings → k-mail.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
  scope: operations
allowed-tools: Bash(m365:*), Bash(az:*)
---

# KπX — Microsoft (Azure + Microsoft 365)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Cloud hub

Registry map: `$HOME/.agents/skills/k-cloud-tools/references/cloud-hub.md` · load **`k-cloud-tools`** when routing across providers.

## Two planes (mandatory)

| Plane | Tool | Scope |
|-------|------|--------|
| **Container** | `az` | Azure subscriptions, VMs, AKS, storage, Entra admin |
| **Content** | `m365` | Outlook, OneDrive, Calendar, To Do, Planner, Teams, SPO |

**Rule:** Azure infra → `az`. M365 user data → **`m365` only**. Symmetry with Google: `az`+`m365` ≈ `gcloud`+`gws`.

## Tools (verify with `!<cmd>`)

| Binary | Runbook |
|--------|---------|
| `m365` | `$HOME/Work/techskills/m365-cli.md` |
| `az` | `az version` |

**Agent auth (mandatory):** never `m365 login` / `logout` / `setup` — KπX only. Read/status + approved reads. Details: **`k-mail`**.

Escape hatch: `m365 request --url "https://graph.microsoft.com/v1.0/..." --method get`

```bash
m365 status
m365 outlook message list --folderName Inbox --output json
m365 onedrive list
```

## Mail routing

| Mailbox | Tool | Skill |
|---------|------|-------|
| Hotmail / Outlook | `m365 outlook *` | **`k-mail`** + this skill |
| Poly Zimbra | mail-mcp | **`k-mail`** — not `m365` |

What's up: Zimbra canonical; dedupe Outlook — **`k-mail`**.

## MCP / future

| Now | Optional later |
|-----|----------------|
| CLI `m365` + `az` | `ms-365-mcp-server` if native MCP needed |
| | `references/mcp-cli-vision.md` (ts-proxy model) |

## Cross-skills

| Task | Load |
|------|------|
| Mail briefing / send gates | `k-mail` |
| Foundry / Azure OpenAI | `microsoft-foundry` |
| Registry | `k-cloud-tools` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-microsoft/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-microsoft/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-25 | [CURSOR] | v1.1.0 — Uniform cloud-hub routing; compact layout. |
| [SUMMARY] | — | v1.0.0 — m365 + az stack; mail cross-ref k-mail. |
