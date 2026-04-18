---
name: k-mail
description: "Unified mail operational memory — KπX mail sources: Zimbra (poly account via mail-mcp) and Microsoft 365 Outlook/Hotmail (m365 CLI), with contacts, priorities, and what’s-up briefing rules. Load before any mail-related workflow."
license: private
metadata:
  author: KpihX
  version: "2.0.34"
allowed-tools: mcp__mail-mcp__*, mcp__mail-mcp--stdio__*
---

# Tool Memory — Mail (Zimbra + Microsoft 365)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Discipline (mandatory)

- **mail-mcp transport:** **Prefer STDIO** when both HTTP and stdio are available (**attachments**, local paths, full fidelity) — **AGENTS.md → MCP Protocol → KπX exception — mail-mcp** and `references/mcp.md`. Use **HTTP** only if stdio is missing or for **read-only** triage.
- **Hard safety rule (M365 auth):** During `what's mail` execution, agents must **never** run `m365 login` or `m365 logout`. Authentication/session lifecycle is user-owned. Agents may run only non-destructive read/status M365 commands (for example `m365 status`, `m365 outlook message list`, `m365 request` in read mode).
- You must read `$HOME/.agents/skills/k-mail/references/insights.md` before doing any mail task.
- You must append one detailed entry to `$HOME/.agents/skills/k-mail/references/log.md` after every mail-mcp tool use.
- **Run-speed policy (immediate minimal):** during active execution, log only critical facts (`UID/Message-ID`, action performed, incident/error). Keep rich synthesis and non-critical learnings for deferred memory curation.
- You must proactively update `references/insights.md` at the end of the task with reusable learnings:
  - communication style and tone patterns
  - recurring message categories received
  - recurring response patterns and preferred phrasing
  - open loops, blockers, and follow-up behavior
- You must proactively update `## Open Threads (operational memory)` when thread status changes.
- You must proactively maintain the Zimbra tag inventory in this file (`## Zimbra Tag Inventory`) after tag operations, and propose `set_labels` / `mark_messages` actions when a message is clearly important or an open thread deserves prioritization.
- You have full control over the whole `k-mail/` folder and must proactively keep all files up to date (`SKILL.md`, `references/log.md`, `references/insights.md`, `references/mcp.md`, and other files).
- Before ending, you must run a final self-check: "Are all files in `k-mail/` reflecting current reality?" If not, update them immediately.
- If you detect key actionable information in mail content (exam, deadline, event, admin/professional follow-up, or other important academic/professional facts), you must proactively propose creating or updating a TickTick item via tick-mcp.
- For local file attachments on this computer, do not use mail-mcp HTTP transport (server-side process cannot access local PC file paths). You must use stdio transport running on the PC; if stdio is unavailable, you must signal it immediately. (Same rule reinforces **stdio-first** above.)
- For any WhatsApp group message drafted from mail context, mandatory dry-run first.
- Step 1: produce preview (`target_jid`, `target_name`, `final_text`, optional mentions/quote).
- Step 2: wait for explicit user approval (`OK ENVOI` or equivalent).
- Step 3: only then call `send_text`.
- If approval is missing or ambiguous, do not send.
- **Absolute post-send verification (all outbound sends, no exceptions):** After every successful `send_message` (or equivalent), **do not** treat the tool JSON alone as proof of delivery. Wait **at least ~5 seconds** (use a deliberate delay so IMAP/SMTP side effects settle), then **re-read** (1) **`Sent`** — confirm the outbound copy is present (subject/recipients/`Message-ID` match when exposed by the API) — and (2) **`INBOX`** — scan for **`MAILER-DAEMON`**, DSN, or bounce content tied to that send. If the copy is missing from `Sent` or a bounce appears in `INBOX`, report it and stop treating the send as healthy. If the MCP exposes `verify_bounce_window_seconds` / `delivery_status`, treat those as **hints only**; this manual **Sent + INBOX** pass remains **mandatory**.
- **Closure hygiene — mail (see `## Closure hygiene (mandatory)`):** After a message is **handled**, **archive** it; after a **1:1** conversation is **fully closed**, archive the thread. **Nudge** until done. Applies even when KπX says they already acted off-thread — **verify or perform archive** before moving on.
- `SKILL.md` describes stable operating rules and how to use mail-mcp transports (**stdio preferred**, HTTP fallback).
- `## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-mail/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-mail/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog` in this file tracks only modifications to the `k-mail/` skill folder, not runtime mail actions.

## Account

- **Address:** `ivann.kamdem-pouokam@polytechnique.edu` (Zimbra, hosted at polytechnique.fr)
- **Account ID in MCP:** `poly`
- **Folders:** INBOX · Sent · Archive · Drafts · Outbox · Junk · Trash (7 flat, no sub-folders)
- **Stats (2026-03-24):** 1,519 total · 86 unread
- **Custom labels:** `Dx0` (DXO internship) · `Hi-ParisAI:FLAG7760` (IPAI Hackathon) · `Important`
- **Flags/labels operations (mail-mcp stdio):**
  - `mark_messages` manages IMAP system flags (`seen`, `flagged`, `answered`, `draft`) on target UIDs.
  - `set_labels` adds/removes custom keyword labels (including Zimbra tags surfaced by `list_labels`).
  - `search_messages` supports `flagged_only=true` and `keyword="<label>"` (e.g. `Important`) to audit priority mail.
- **Outlook / m365:** `ivann.kamdem@hotmail.com` — use **`m365 outlook *`** CLI (Graph) for the Hotmail mailbox; see `$HOME/Work/techskills/m365-cli.md` (`m365 status`, `m365 outlook message list`, …). **Redirection:** much **institutional X mail** is visible both in Zimbra (`poly`) and in Outlook; in *What's up*, treat **poly as canonical** and **deduplicate** Outlook (see **`## What's up (mail briefing)`**). **`postmaster@zimbra.polytechnique.fr`** notifications in Hotmail are **delivery receipts**, not conversational mail.
- **`.agents` git (KπX 2026-04-09):** Do **not** `git commit` / `make push` this repo unless KπX explicitly requests end-of-session finalization (see `k-context` HOT block).

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
| 2026-04-13 | [CODEX] | v2.0.31 — Standardized insights discipline and autonomous maintenance hooks for this skill. |
| `scolarite.1a-2a@polytechnique.fr` | Primary admin — PSC, placements, exams, internship conventions | CRITICAL |
| `noreply@ip-paris.fr` | Moodle: grades, QCMs, TD feedback | CRITICAL |
| `camille.challant@polytechnique.edu` | Notes publication, academic schedule | HIGH |
| `anne.taupin@polytechnique.edu` | Career Center — stage 2A guidance | HIGH |
| `stages.x2a@polytechnique.fr` | Official 2A internship office | HIGH |
| `pauline.alessandra@polytechnique.edu` | IME teaching contact — assignment feedback/follow-up | HIGH |

**IME Alessandra — addressing rule:** Use **`@polytechnique.edu` only**. **`pauline.alessandra@polytechnique.fr` is invalid** (SMTP **550 Non-existent address** on outbound poly relay). Same pattern may apply to other `@polytechnique.edu` mailboxes — never assume a `.fr` twin exists.

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

### Microsoft 365 / Outlook (Hotmail) — key people

> Used for the **m365** leg of *What's up* and for **dedup** context. **Maintain:** after **Graph + poly** passes, patch provenance (dates, subjects) — avoid inventing email local-parts without a mailbox line.

| Name | Address | Role / context | Discovery |
|------|---------|----------------|-----------|
| **Liu Clément** (Outlook: *Clément Liu*) | `clement.liu@lokad.com` | **Lokad** **PSC INF01** coordinator (company side, with poly supervisor **`johannes.lutzeyer@polytechnique.edu`**). Threads in Hotmail/poly mirror: **PSC** cadence, **contract** alignment, **API tokens** and **benchmark** / **rapport final** with the student group (**Gaétan**, CC to you on **`ivann.kamdem@hotmail.com`**). | **Verified 2026-04-09** — Microsoft Graph (CLI v11): `m365 request -m get -u 'https://graph.microsoft.com/v1.0/me/messages?$search=%22lokad%22&$top=30&$select=subject,from,toRecipients,ccRecipients,receivedDateTime'` + poly `search_messages`. |

### PSC INF01 — Lokad Project
| Address | Role |
|---------|------|
| `johannes.lutzeyer@polytechnique.edu` | PSC supervisor (poly) |
| `clement.liu@lokad.com` | **Clément Liu** — PSC coordinator (Lokad) |

## Active Courses (P2)

| Code | Description |
|------|-------------|


## Flagged Items (action required)

1. **English certification** (`certification-anglais-dlc@polytechnique.fr` — official sender in school mailings) — test to schedule; reply with existing C1 proof per their instructions
2. **IME IME_43031_EP — re-feedback pending** — Buurtzorg part 1: Moodle feedback received **2026-04-08** (message archived); **awaiting next feedback / iteration or clarification** from teaching side (`pauline.alessandra@polytechnique.edu`, Moodle course thread).
3. **IPAI Hackathon — prize payout pending** — `hannah.conrad@join-nxtgn.com` **2026-04-08** (archived): transfer delayed; **Isabel Camps Tscherwitschke** (`isabel.camps_tscherwitschke@ipai-foundation.ai`) to confirm when funds sent.

## Attention Triggers

`*@polytechnique.edu` · `*@polytechnique.fr` · `*@ip-paris.fr` · `*@dxo.com` · `*@lokad.com` · DFHM

## Zimbra Tag Inventory

> Source of truth: live mail-mcp stdio checks (`search_messages keyword=...`, `flagged_only`, `set_labels`, `mark_messages`).
> Keep this section synchronized after each non-trivial tag/flag operation.

| Tag / Flag | Type | Current observed scope | Notes |
|------------|------|------------------------|-------|
| `Important` | IMAP keyword label | Active (currently concentrated in `INBOX` after archive cleanup) | Priority triage tag; managed with `set_labels` and queried via `keyword="Important"` |
| `Hi-ParisAI:FLAG7760` | IMAP keyword label | Active (`INBOX` + `Archive`) | IPAI / Hi! PARIS thread grouping |
| `Dx0` | IMAP keyword label | Active (`INBOX` + `Archive`) | DXO internship thread grouping |
| `Eco` | IMAP keyword label | Active (mostly `Archive`, some `INBOX`) | ECO course thread grouping |
| `\\Flagged` | IMAP system flag (favorite/star) | Active (`INBOX` and some `Archive`) | Use for short-term follow-up; managed by `mark_messages(flagged=...)` |

## KπX interest lens (mail + cross-reference for WhatsApp)

Use this list to **rank** and **highlight** messages in any *What's up* mail slice (and align with `k-whatsapp` **KπX interest lens**): **academic** (Moodle, QCMs, grades, TD/TP, IME, scolarité, Challant schedule), **professional** (internships, Career Center, conventions stage 2A, certifications e.g. English Linguaskill), **AI** (IPAI, Hi-Paris, hackathons, research mail), **missions / jobs / tech** (XProjets, HR, labs), **stages** (DXO, administrative threads), **hackathons**, **PSC**, **DFHM / soft skills**, **poly admin**, **conferences**, **legal / contracts**, **bounces / MAILER-DAEMON** (surface as incidents).

## Closure hygiene (mandatory)

- **Single message handled** (you replied via MCP, or KπX confirms action taken): **move that message to `Archive`** (or KπX’s agreed folder) **via mail-mcp in the same workstream** before switching topics — do not rely on “mental” done.
- **1:1 conversation complete** (no pending answer on either side for that counterparty): **archive remaining messages for that thread** / counterpart where the mailbox model allows. **Do not** treat **mailing lists**, **course-wide noreply**, or obvious **bulk `List-Id`** traffic as a 1:1 “conversation” for this rule — archive individual messages as above, but do not assume “close thread” semantics for the whole list.
- **KπX says *I already replied* / *it’s handled*:** Treat as **mandatory archive verification**: if copies still sit in **`INBOX`**, **archive them now** (or report why not) **before** continuing.
- **Persistent nudge:** On **every** later assistant turn that touches mail, if a previously-handled item is **still in INBOX**, surface **one line**: *Still to archive: …* until cleared.

## What's up (mail briefing)

**Calendar / timezone:** **Europe/Paris** for *today* unless stated otherwise.

### Step 0 — Connectivity preflight (blocking)

Before **any** substantive briefing (do **not** run steps 1–6 below until this passes):

1. **mail-mcp (stdio preferred):** Confirm **stdio** mail-mcp works — e.g. `mail_guide()` or **`list_messages`** on account **`poly`** with a **small limit**. If stdio fails, you may try **HTTP** for **read-only** snapshot **or** stop and explain that sends/attachments need stdio. If **poly** is unreachable, **STOP**.
2. **Microsoft 365 (Hotmail):** Run **`m365 status`** and a trivial read such as **`m365 outlook message list`** with a tiny limit (see `$HOME/Work/techskills/m365-cli.md`). If auth is missing or the command errors, **STOP**.

**If either check fails:** Output **diagnostics + concrete recovery** (for example: ask KπX to run M365 auth manually outside agent control, fix `mail-mcp serve`, Tailscale, token cache). **Never run `m365 login/logout` as the agent.** Tell KπX clearly: **say `continue` when both are healthy** — **do not** present the mail *What's up* body until then.

**Manual M365 recovery block (user-run only, no agent auth mutation):**

```bash
m365 cli config set --key autoOpenLinksInBrowser --value false
m365 cli config set --key copyDeviceCodeToClipboard --value false
m365 login --authType deviceCode --appId <your-app-id> --tenant consumers
```

If troubleshooting is needed, use:

```bash
m365 login --authType deviceCode --appId <your-app-id> --tenant consumers --debug
```

Interpretation note: `m365 status` may still show `connectedAs` as empty even when Graph reads are working; validate with a real read command (`m365 outlook message list`).

**When both pass:** continue.

### Order of presentation (same assistant turn, maximum exhaustivity)

**Detail mandate (non-negotiable):** This briefing is **not a résumé**. Present the full factual content with maximum detail available from tools, minimize synthesis, and do not defer detail behind "ask if you want more". The first pass must already be complete.
**Batch depth mandate (non-negotiable):** execute this slice as a batch workflow: continue opening relevant messages/threads across `INBOX`/`Archive`/Outlook until the mail picture is materially complete; stop only then and present the full result.

1. **Open pipelines (unread first, any age; Important-priority)** — For every row in **`## Open Threads`** and **`## Flagged Items`**, run `search_messages` / `list_messages` on **`INBOX`** then **`Archive`** (and `Sent` if tracking your own pending replies): surface **unread** or **unanswered** messages tied to those threads **even if weeks old**. Within this block, prioritize messages carrying `Important` first, then the rest. Full headers + body summary + suggested next action + optional TickTick.
2. **Today’s mail — poly (`Zimbra`)** — All messages **dated today** in `INBOX` (then optionally filed **today** in `Archive`): blocks **Admin / Academic / Professional** using **KπX interest lens**; sort by contact priority.
3. **Today / recent — Outlook (m365), deduplicated** — Query **`m365 outlook message list`** (e.g. unread and/or last 24–48h). **Poly is canonical** for **X / school** mail that is **mirrored** from Zimbra. **Suppress** from the Outlook summary any message **already represented** in poly (`INBOX`, `Archive`, or `Sent`): match by **`Message-ID`** when both APIs expose it; else **fallback fingerprint** = **normalized `Subject` + primary `From` + received time within ±3 minutes** (or obvious thread id if present). **Highlight net-new:** personal mail, external senders **not** in poly, Hotmail-only receipts, and **`## Key contacts (Microsoft 365 / Outlook)`** traffic even when a duplicate exists (summarize once, note *also in poly* if applicable).
4. **Microsoft 365 — key contacts pulse** — Short pass over **`## Microsoft 365 / Outlook (Hotmail) — key people`** (priority: **Clément Liu (Lokad PSC)**, then other rows): any **recent** thread not already summarized; **enrich** `*@lokad.com` details when surfaced.
5. **Backward window (poly)** — **Yesterday**; optional **last 7 days** unread stragglers.
6. **Proactive close** — Drafts + TickTick **proposals** (execute TickTick in a **later** turn per AGENTS unless KπX scoped mail-only and approved writes). **Apply `## Closure hygiene (mandatory)`** for any item marked done in this pass.

**Sequential ladder:** When KπX runs the **full** *what's up*, **mail is exactly one assistant response** — do not combine with `k-context`, `k-whatsapp`, or `k-ticktick` output in the same generation.

## MCP Setup Reference

- Generic setup (HTTP + stdio): `$HOME/.agents/skills/k-mail/references/mcp.md`
- **Missing Tool / MCP Action:** If KπX asks to use mail-mcp and the agent doesn't already see it in its activated tools, the agent MUST look at `references/mcp.md` for the process of adding it, and proactively add it as an MCP before attempting to continue the task. Use the naming convention **`mail-mcp-http`** and **`mail-mcp-stdio`**.

## Open Threads (operational memory)

| Thread | Contacts | Last State | Next Action |
|--------|----------|------------|-------------|
| English certification / Linguaskill (UID `8323`, `10071`) | `certification-anglais-dlc@polytechnique.fr`, `service@wefitgroup.com` | Slot now confirmed by WEFIT: **Thu 2026-04-30 09:00 Europe/Paris** (registration success page + confirmation message). `UID 10071` is now `Important` + `\Flagged` in `INBOX`. Primary IDs: `<1496528695.157357129.1775126042536.JavaMail.zimbra@zimbra.polytechnique.fr>`, `<1986239662.360.1776236071674@localhost>` | Keep watch for convocation / technical instructions / username-password send before exam day; archive thread after test completion and results receipt |
| IME Buurtzorg / follow-up | `pauline.alessandra@polytechnique.edu`, Moodle | Part 1 feedback notified **2026-04-08** (mail archived) | Await **re-feedback** or submit next milestone per course rules; ping if stalled |
| IPAI Hackathon prize | `hannah.conrad@join-nxtgn.com`, `isabel.camps_tscherwitschke@ipai-foundation.ai` | Payout delayed per **2026-04-08** update (mail archived) | No reply needed unless silence; watch inbox for payout confirmation |

## Runtime Memory Files

- `references/log.md` — detailed action log for every mail-mcp usage (timestamp, action, outcome, ids, notes)
- `references/insights.md` — durable behavioral memory and extracted patterns for proactive future drafting
- `references/mcp.md` — transport and setup reference for mail-mcp (`http` and `stdio`)
- `references/tool-keep-matrix.md` — permanent YES/NO tool matrix used to drive MCP disabled-tools policy

**Upstream `k-mail-mcp`:** from **v0.2.4**, `/health` and `mail_guide()` report the installed **distribution** version (`k-mail-mcp`). After upgrading the MCP host, call **`mail_guide()`** once so the agent text matches tool schemas (`verify_bounce_window_seconds`, `delivery_status`, etc.).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-16 | [CODEX] | v2.0.34 — Added validated Hotmail recovery runbook (user-run only): set browser/clipboard flags, force `--tenant consumers`, and use `--debug` for diagnostics; updated Outlook read command references to `outlook message list`. |
| 2026-04-15 | [CODEX] | v2.0.32 — Updated Linguaskill open thread with confirmed slot (2026-04-30 09:00), new WEFIT message IDs, and state (`UID 10071` flagged + Important). |
| [SUMMARY] | — | v2.0.33 unified scope + no login/logout by agents; v2.0.31 insights discipline; v2.0.30 batch depth; v2.0.29 zero-synthesis; v2.0.28 tool matrix; v2.0.27..v2.0.0 prior stack |
