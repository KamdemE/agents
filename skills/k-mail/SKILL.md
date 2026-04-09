---
name: k-mail
description: mail-mcp operational memory — KπX Zimbra inbox (polytechnique.edu, account "poly"), key contacts by category, active courses, flagged items, and attention triggers. Load before any mail-mcp tool call.
license: private
metadata:
  author: KpihX
  version: "2.0.12"
allowed-tools: mcp__mail-mcp__*, mcp__mail-mcp--stdio__*
---

# Tool Memory — Mail (mail-mcp)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Discipline (mandatory)

- You must read `$HOME/.agents/skills/k-mail/references/insights.md` before doing any mail task.
- You must append one detailed entry to `$HOME/.agents/skills/k-mail/references/log.md` after every mail-mcp tool use.
- You must proactively update `references/insights.md` at the end of the task with reusable learnings:
  - communication style and tone patterns
  - recurring message categories received
  - recurring response patterns and preferred phrasing
  - open loops, blockers, and follow-up behavior
- You must proactively update `## Open Threads (operational memory)` when thread status changes.
- You have full control over the whole `k-mail/` folder and must proactively keep all files up to date (`SKILL.md`, `references/log.md`, `references/insights.md`, `references/mcp.md`, and other files).
- Before ending, you must run a final self-check: "Are all files in `k-mail/` reflecting current reality?" If not, update them immediately.
- If you detect key actionable information in mail content (exam, deadline, event, admin/professional follow-up, or other important academic/professional facts), you must proactively propose creating or updating a TickTick item via tick-mcp.
- For local file attachments on this computer, do not use mail-mcp HTTP transport (server-side process cannot access local PC file paths). You must use stdio transport running on the PC; if stdio is unavailable, you must signal it immediately.
- For any WhatsApp group message drafted from mail context, mandatory dry-run first.
- Step 1: produce preview (`target_jid`, `target_name`, `final_text`, optional mentions/quote).
- Step 2: wait for explicit user approval (`OK ENVOI` or equivalent).
- Step 3: only then call `send_text`.
- If approval is missing or ambiguous, do not send.
- For sensitive outbound emails, mandatory post-send verification: check `Sent` for the message copy, then check `INBOX` for DSN/bounce (`MAILER-DAEMON`) in a short window before considering delivery healthy.
- `SKILL.md` describes stable operating rules and how to use mail-mcp transports (`stdio` and/or `http`).
- `## Changelog` in this file tracks only modifications to the `k-mail/` skill folder, not runtime mail actions.

## Account

- **Address:** `ivann.kamdem-pouokam@polytechnique.edu` (Zimbra, hosted at polytechnique.fr)
- **Account ID in MCP:** `poly`
- **Folders:** INBOX · Sent · Archive · Drafts · Outbox · Junk · Trash (7 flat, no sub-folders)
- **Stats (2026-03-24):** 1,519 total · 86 unread
- **Custom labels:** `Dx0` (DXO internship) · `Hi-ParisAI:FLAG7760` (IPAI Hackathon) · `Important`
- **Outlook rule:** `ivann.kamdem@hotmail.com` receives forwarding notifications from `postmaster@zimbra.polytechnique.fr` — these are delivery receipts, NOT real emails. Use `m365 outlook *` CLI for Outlook.

## Messaging Style

- **French** for academic/administrative contacts; **English** for international/tech contacts
- Formal register for administration (scolarite, professors, DFHM)
- Semi-formal for peers and student associations
- Concise, structured; re-quotes relevant parts when replying
- Signs as: **Ivann KAMDEM** (semi-formal) or **Ivann Kamdem Pouokam** (formal)

## Key Contacts

### Academic Administration
| Address | Role | Priority |
|---------|------|----------|
| `scolarite.1a-2a@polytechnique.fr` | Primary admin — PSC, placements, exams, internship conventions | CRITICAL |
| `noreply@ip-paris.fr` | Moodle: grades, QCMs, TD feedback | CRITICAL |
| `camille.challant@polytechnique.edu` | Notes publication, academic schedule | HIGH |
| `anne.taupin@polytechnique.edu` | Career Center — stage 2A guidance | HIGH |
| `stages.x2a@polytechnique.fr` | Official 2A internship office | HIGH |
| `pauline.alessandra@polytechnique.edu` | IME teaching contact — assignment feedback/follow-up | HIGH |

### DFHM / Military Hierarchy
| Address | Role |
|---------|------|
| `henry.develey@polytechnique.edu` | Capitaine (CDU) DEVELEY |
| `mathieu.lesoualch@polytechnique.edu` | Adjudant (CDS) LESOUALCH |
| `vincent.beurel@polytechnique.edu` | Active contact — directives, evaluations |

### Internship / Active Threads
| Address | Company | Status |
|---------|---------|--------|
| `rsapaico@dxo.com` | DXO Labs | ACCEPTED — "Stage Image Research (Learning to Cull)" |
| `mschermann@dxo.com` | DXO Labs (CEO) | Active |

### PSC INF01 — Lokad Project
| Address | Role |
|---------|------|
| `johannes.lutzeyer@polytechnique.edu` | PSC supervisor |
| `notifications@yousign.app` | Lokad NDA — PENDING SIGNATURE |

## Active Courses (P2)

| Code | Description |
|------|-------------|


## Flagged Items (action required)

1. **English certification** (`certification-anglais-dlc@polytechnique.edu`) — test to schedule

## Attention Triggers

`*@polytechnique.edu` · `*@polytechnique.fr` · `*@ip-paris.fr` · `*@dxo.com` · Yousign · DFHM

## MCP Setup Reference

- Generic setup (HTTP + stdio): `$HOME/.agents/skills/k-mail/references/mcp.md`

## Open Threads (operational memory)

| Thread | Contacts | Last State | Next Action |
|--------|----------|------------|-------------|
| *(none)* | | | |

## Runtime Memory Files

- `references/log.md` — detailed action log for every mail-mcp usage (timestamp, action, outcome, ids, notes)
- `references/insights.md` — durable behavioral memory and extracted patterns for proactive future drafting
- `references/mcp.md` — transport and setup reference for mail-mcp (`http` and `stdio`)

**Upstream `k-mail-mcp`:** from **v0.2.4**, `/health` and `mail_guide()` report the installed **distribution** version (`k-mail-mcp`). After upgrading the MCP host, call **`mail_guide()`** once so the agent text matches tool schemas (`verify_bounce_window_seconds`, `delivery_status`, etc.).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-09 | [CURSOR] | v2.0.12 — documented **k-mail-mcp 0.2.4** version/`mail_guide` alignment + reminder to refresh `mail_guide()` after MCP upgrades |
| 2026-04-08 | [CODEX] | v2.0.11 — added mandatory post-send verification policy for sensitive emails (`Sent` copy check + short-window DSN/bounce check in `INBOX`). |
| [SUMMARY] | — | v2.0.10 IME contact `pauline.alessandra@polytechnique.edu`; v2.0.9 WhatsApp dry-run from mail context; v2.0.8 local-attachment transport; v2.0.7 TickTick proposals; v2.0.6–v2.0.5 open threads + self-check; v2.0.0 refonte + 2026-03-24 Zimbra review; earlier folded |
