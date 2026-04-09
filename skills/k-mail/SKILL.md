---
name: k-mail
description: mail-mcp operational memory — KπX Zimbra inbox (polytechnique.edu, account "poly"), key contacts by category, active courses, flagged items, and attention triggers. Load before any mail-mcp tool call.
license: private
metadata:
  author: KpihX
  version: "2.0.15"
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
- **Absolute post-send verification (all outbound sends, no exceptions):** After every successful `send_message` (or equivalent), **do not** treat the tool JSON alone as proof of delivery. Wait **at least ~5 seconds** (use a deliberate delay so IMAP/SMTP side effects settle), then **re-read** (1) **`Sent`** — confirm the outbound copy is present (subject/recipients/`Message-ID` match when exposed by the API) — and (2) **`INBOX`** — scan for **`MAILER-DAEMON`**, DSN, or bounce content tied to that send. If the copy is missing from `Sent` or a bounce appears in `INBOX`, report it and stop treating the send as healthy. If the MCP exposes `verify_bounce_window_seconds` / `delivery_status`, treat those as **hints only**; this manual **Sent + INBOX** pass remains **mandatory**.
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
2. **IME IME_43031_EP — re-feedback pending** — Buurtzorg part 1: Moodle feedback received **2026-04-08** (message archived); **awaiting next feedback / iteration or clarification** from teaching side (`pauline.alessandra@polytechnique.edu`, Moodle course thread).
3. **IPAI Hackathon — prize payout pending** — `hannah.conrad@join-nxtgn.com` **2026-04-08** (archived): transfer delayed; **Isabel Camps Tscherwitschke** (`isabel.camps_tscherwitschke@ipai-foundation.ai`) to confirm when funds sent.

## Attention Triggers

`*@polytechnique.edu` · `*@polytechnique.fr` · `*@ip-paris.fr` · `*@dxo.com` · Yousign · DFHM

## MCP Setup Reference

- Generic setup (HTTP + stdio): `$HOME/.agents/skills/k-mail/references/mcp.md`

## Open Threads (operational memory)

| Thread | Contacts | Last State | Next Action |
|--------|----------|------------|-------------|
| IME Buurtzorg / follow-up | `pauline.alessandra@polytechnique.edu`, Moodle | Part 1 feedback notified **2026-04-08** (mail archived) | Await **re-feedback** or submit next milestone per course rules; ping if stalled |
| IPAI Hackathon prize | `hannah.conrad@join-nxtgn.com`, `isabel.camps_tscherwitschke@ipai-foundation.ai` | Payout delayed per **2026-04-08** update (mail archived) | No reply needed unless silence; watch inbox for payout confirmation |

## Runtime Memory Files

- `references/log.md` — detailed action log for every mail-mcp usage (timestamp, action, outcome, ids, notes)
- `references/insights.md` — durable behavioral memory and extracted patterns for proactive future drafting
- `references/mcp.md` — transport and setup reference for mail-mcp (`http` and `stdio`)

**Upstream `k-mail-mcp`:** from **v0.2.4**, `/health` and `mail_guide()` report the installed **distribution** version (`k-mail-mcp`). After upgrading the MCP host, call **`mail_guide()`** once so the agent text matches tool schemas (`verify_bounce_window_seconds`, `delivery_status`, etc.).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-09 | [CURSOR] | v2.0.15 — **2026-04-08** INBOX triage: archived 3 msgs (`8444,8445,8449`); **Open Threads** + **Flagged Items** for **IME re-feedback** + **IPAI prize payout**; Apr 8 items already in Archive left as-is. |
| 2026-04-09 | [CURSOR] | v2.0.14 — `references/mcp.md`: `verify_bounce_window_seconds` as **optional complement only** after mandatory manual **`Sent` + `INBOX`** re-reads. |
| [SUMMARY] | — | v2.0.13 absolute post-send `Sent`+`INBOX`; v2.0.12 mail_guide / k-mail-mcp 0.2.4; v2.0.11–v2.0.0 IME contact, WhatsApp dry-run, attachments, TickTick, open threads, refonte, Zimbra review |
