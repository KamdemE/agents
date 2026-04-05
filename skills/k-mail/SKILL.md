---
name: k-mail
description: mail-mcp operational memory — KπX Zimbra inbox (polytechnique.edu, account "poly"), key contacts by category, active courses, flagged items, and attention triggers. Load before any mail-mcp tool call.
license: private
metadata:
  author: KpihX
  version: "2.0.1"
allowed-tools: mcp__mail-mcp__*, mcp__mail-mcp--fallback__*
---

# Tool Memory — Mail (mail-mcp)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-05 | [CLAUDE] | v2.0.1 — restored `skills/k-mail/SKILL.md` (removed in error during kernel governance); changelog compacted to AGENTS limits |
| 2026-03-25 | [CLAUDE] | v2.0.0 — refonte: mail-mcp operational memory under `skills/k-mail/` |
| [SUMMARY] | — | 2026-03-24 GEMINI full Zimbra review (unread, contacts, DXO, Lokad NDA); earlier folded |
