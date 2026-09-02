---
name: k-whats
description: >
  WhatsApp via whats-proxy CLI (proxy-only, no MCP) — groups, JIDs, What's up slice.
  Cloud hub productivity channel. Load before any whats-proxy call.
license: private
metadata:
  author: KpihX
  version: "3.0.2"
allowed-tools: Bash(*), *
---

# KπX — WhatsApp (whats-proxy)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Cloud hub

Productivity **content** channel · map: `$HOME/.agents/skills/k-clis/references/cloud-hub.md` · Proxy CLI — `whats-proxy`.

## What's up — core policy and procedure

**Open threads first (definition):** A *What's up* for WhatsApp **always** includes fetching **recent traffic for every row in `## Open Threads (operational memory)`** using `whats-proxy do chat-read`. **Ignore calendar age** for this pass — if the thread is still open, surface **all relevant recent messages** until the story is clear.

**Calendar day:** Use **Europe/Paris** for *today* / *unread today* boundaries unless KπX specifies otherwise.

**KπX interest lens (elevate these in every section below):** Academic (courses, Moodle, exams, QCMs, grades, IME, DFHM, scolarité), professional (internships DXO/stage 2A, Career Center, conventions, certifications English), **AI** (Binet IA, IPAI, hackathons, X-IA, agents, research talks), **missions / jobs / tech** (XProjets *Offres de Missions*, *Missions XProjets*, JobTeaser-style leads if mirrored on WA), **stages**, **hackathons**, **PSC**, **soft skills**, **poly admin**, **conferences**, **sports performance** when tied to X24 — extend with anything matching `## Attention Triggers` in `k-mail` when overlapping. Messages hitting this lens get **maximum visual emphasis** (headline, bullets, quoted text).

**Section order for a full WhatsApp *What's up* slice** (single assistant turn — **only this skill**):

**Detail mandate (non-negotiable):** This slice is **not a recap**. Provide maximum available detail directly in the first response, with no synthesis-only compression and no "ask me if you want details" fallback.
**Batch depth mandate (non-negotiable):** run the WhatsApp slice as a batch deep-dive (open threads + unread + relevant historical context) and stop only once the information set is materially complete.

1. **Open-thread traffic** — per `## Open Threads`, JID by JID: sender, time, full text (or faithful summary if media-only), quoted lines for decisions/deadlines.
2. **Today's unread** — all WhatsApp messages **received today** still **unread**, ordered by **`## Group Index` priority** (HIGH → VERY LOW), then by time. Full detail: group name, JID, author, timestamp, body. Apply **KπX interest lens** — reorder within priority band so lens hits come first.
3. **Infos X24** (school pulse) — scan **`X24 — Announcements`** (`120363400296786956@g.us`) and **`Info X24`** (`120363417591278511@g.us`): today's traffic **plus** any **unread** from the last few days not yet acknowledged; highlight **course-choice campaigns**, **school events**, **amphis**, **RSE**, **4A / international**, **tech & AI** school line.
4. **Badminton X24** (`120363393577104884@g.us`) — **critical.** Surface anything about: **rassos** (time/place, e.g. early morning *levée des couleurs*), **sport slots** (*T5*, *T6*, *bulle*, gym assignment, **group 2**), **FFSU / compétitions**, **Google Sheets** / forms to fill, orders from **`mathieu.lesoualch@polytechnique.edu`** (Adjudant, CDS — see `k-mail` DFHM) or **`henry.develey@polytechnique.edu`** (Capitaine, CDU) or any staff echoing them, **chef de section** messages, equipment, cancellations.
5. **Péri-scolaire & interest groups** — prioritize **`Opportunites IA : Stages, PSC, Projets`**, **`Offres de Missions`**, **`IPAI Hackathon group 7`**, **`Sympathisants Binet IA`** (both), **`PSC IA`**, **`Competiteurs FFSU`**, **`Missions XProjets`**, **`X24⚔️🔥`**: events, deadlines, badminton-adjacent comps, binet announcements. Exhaustive for **unread**; summarize read-but-recent if action-heavy.
6. **Awaiting your reply / reaction** — messages (any chat) that **expect** an answer, poll, RSVP, reaction, or private follow-up; sort by **HIGH → LOW** contact/group match, then lens. For each: **proposed reply** (draft) and **proposed action** (e.g. *add TickTick task …*, *archive 1:1 after reply per `## Closure hygiene`*) — same proactive standard **applies to all sections above**, not only this one.
7. **Closure nudge** — List **1:1** chats that are **logically done** but **not archived**; do not suggest archiving **groups**.

**Tools:** Use `whats-proxy do chat-read` for per-chat history; `whats-proxy do find-messages` for keyword search across chats; `whats-proxy do chat-list` for unread counts and chat listing. All actions use the syntax `whats-proxy do <action> [payload|file] [-a phone] [-o file] [-f json|table]`.

**Sequential ladder:** If KπX started a **full** *what's up*, this skill is **one turn** in the chain — **AGENTS.md → What's up**. Do not bundle `k-mail` or `k-tick` in the same generation.

## Multi-account

| Account | Phone | Role | Stats | readreceipts |
|---------|-------|------|-------|--------------|
| KπX | 33605957785 | Main | 99 chats, 3812 contacts, 90 groups | none |
| KπX-Labs | 33745717350 | Secondary/testing | 8 chats, 419 contacts, 3 groups | all |
| Ivann | 237675836168 | Business | 22 chats, 1543 contacts, 20 groups | all |

**Default routing:** KπX (33605957785) — always pass `-a 33605957785` unless KπX specifies another account.

## Proxy architecture

- One `whats-proxy` daemon per account (O_EXCL lock file prevents duplicates)
- Auto-spawned on first `whats-proxy do <action>` if no daemon is running
- Daemon manages Baileys socket, store persistence, and reconnection
- If daemon shows disconnect, report and wait — never try to bypass

## CLI reference

```bash
whats-proxy do <action> [payload|file] [-a phone] [-o file] [-f json|table]
```

**Key actions:**

| Action | Purpose | Payload |
|--------|---------|---------|
| `chat-list` | List chats (unread, recent) | optional filter JSON |
| `chat-read` | Read messages from a chat | `{"jid":"...", "limit":50}` |
| `find-messages` | Search messages by keyword | `{"query":"...", "jid":"..."}` |
| `send-text` | Send a text message | `{"jid":"...", "text":"..."}` |
| `chat-manage` | Archive, pin, mute, mark read/unread | `{"jid":"...","action":"archive\|pin\|mute\|mark_read\|mark_unread"}` |
| `contact-info` | Get contact details | `{"jid":"..."}` |

Use `-a <phone>` to target a specific account. Use `-f table` for human-readable output, `-f json` (default) for machine parsing.

## Raw API (advanced)

For actions not exposed by `whats-proxy do`, two low-level protocols are available:

- **`baileys`** — raw Baileys socket operations (socket-level, module format)
- **`store`** — direct SQL queries against the message store (method/sql format)

Use only when `whats-proxy do` lacks the needed action. Consult `whats-proxy --help` for sub-command syntax.

## Closure hygiene (mandatory)

- **1:1 chat fully handled** (you sent the last needed message, or KπX confirms the matter closed): **archive the chat** (`whats-proxy do chat-manage '{"jid":"...","action":"archive"}' -a <phone>`), then confirm state. **Do not** archive **groups** (`@g.us`) as a blanket action — groups stay active; only mute/leave per explicit KπX instruction.
- **KπX says *I replied elsewhere* / *c'est bon*:** Still **verify** the 1:1 thread; if the story is closed, **archive** (or confirm already archived) **before** continuing.
- **Persistent nudge:** On later turns touching WhatsApp, if a **closed** 1:1 is **still unarchived**, one line *Still to archive: …* until fixed. Align with **`k-mail` `## Closure hygiene`** and **`k-tick`** for mail + tasks.

## Runtime Discipline (mandatory)

- **AUTH BLOCKS (mandatory):** If `whats-proxy` reports a connection or authentication failure (e.g., "WhatsApp is not connected", "Scan QR code"), you MUST **STOP immediately**. Do not waste tokens or time on complex browser/vision hacks to bypass the disconnect. Report the issue, wait for KπX to reconnect, and resume only after explicit confirmation.
- You must read `$HOME/.agents/skills/k-whats/references/insights.md` before doing any WhatsApp task.
- You must append one detailed entry to `$HOME/.agents/skills/k-whats/references/log.md` after every whats-proxy tool use.
- **Run-speed policy (immediate minimal):** during active execution, record only critical facts (target JID/thread, action, incident/error). Keep broader narrative and secondary patterns for deferred memory curation.
- You must proactively update `references/insights.md` at the end of the task with reusable learnings:
  - communication style and tone patterns by contact/group
  - recurring topics and message categories
  - recurring response patterns and preferred phrasing
  - open loops, blockers, and follow-up behavior
- You must proactively update `## Open Threads (operational memory)` when thread status changes.
- You have full control over the whole `k-whats/` folder and must proactively keep all files up to date (`SKILL.md`, `references/log.md`, `references/insights.md`, `references/mcp.md`, and other files).
- Before ending, you must run a final self-check: "Are all files in `k-whats/` reflecting current reality?" If not, update them immediately.
- If you detect key actionable information in WhatsApp content (exam, deadline, event, admin/professional follow-up, or other important academic/professional facts), you must proactively propose creating or updating a TickTick item via tick-proxy.
- For any WhatsApp group message, mandatory dry-run first.
- Step 1: produce preview (`target_jid`, `target_name`, `final_text`, optional mentions/quote).
- Step 2: wait for explicit user approval (`OK ENVOI` or equivalent).
- Step 3: only then call `whats-proxy do send-text`.
- If approval is missing or ambiguous, do not send.
- **Absolute post-send verification (all sends, no exceptions):** After every successful `whats-proxy do send-text`, **do not** treat the tool return alone as proof the message landed in the thread. Wait **at least ~5 seconds**, then **re-fetch the conversation** for that chat (same JID): confirm the outbound text is **visible in the recent message list** (content + ordering). If it is missing or the thread looks stale, report it explicitly before closing the task.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-whats/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-whats/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Key Contacts

| Saved As | JID | Style |
|----------|-----|-------|
| Ta Baby (Nathalie) | `127625573986382@lid` | Affectionate, concise, voice-note heavy |
| Maman | `23795844360@s.whatsapp.net` | Affectionate, reassuring, short messages, religious tone |
| Ma Ange TOUKO | `23777947720@s.whatsapp.net` | Warm family register |
| Ma Jakeline SIME | `23777680325@s.whatsapp.net` | Occasional family exchanges |

## Group Index (HIGH → VERY LOW)

| Group | JID | Members | Priority |
|-------|-----|---------|----------|
| Badminton X24 | `120363393577104884@g.us` | 41 | HIGH |
| X24 — Announcements | `120363400296786956@g.us` | 816 | HIGH (X24 Community, announce=true) |
| Info X24 | `120363417591278511@g.us` | 721 | HIGH (X24 Community, announce=false) |
| IPAI Hackathon group 7 | `120363405436750278@g.us` | 6 | HIGH |
| Sympathisants Binet IA — Announcements | `120363382112481618@g.us` | 453 | HIGH (Binet IA Community, announce=true) |
| Sympathisants Binet IA — Discussion | `120363251841330923@g.us` | 444 | HIGH (Binet IA Community, announce=false) |
| Offres de Missions | `120363377060744481@g.us` | 634 | HIGH (XProjets Community, announce=true) |
| Opportunites IA : Stages, PSC, Projets | `120363379979578334@g.us` | 257 | HIGH |
| X24⚔️🔥 | `120363293201252722@g.us` | 8 | HIGH (ENSPY classmates — standalone) |
| Missions XProjets | `120363359089349774@g.us` | 675 | MEDIUM (XProjets Community) |
| X-Afrique Sympathisants | `120363327608135460@g.us` | 79 | MEDIUM |
| X - Cameroun (large) | `120363419403445255@g.us` | 73 | MEDIUM |
| Competiteurs FFSU | `120363422527120376@g.us` | 14 | MEDIUM |
| PSC IA | `120363422379816902@g.us` | 5 | MEDIUM |
| Binet Bad | `120363149474153094@g.us` | 160 | MEDIUM |
| ENSPY ALUMNI ABROAD | `120363029059198260@g.us` | 555 | LOW (ENSPY Community, announce=true) |
| ENSPY Alumni Abroad 0 | `33659825066-1537198811@g.us` | 460 | LOW (ENSPY Community, announce=false) |
| X24 - X25 Cameroun | `120363419537806175@g.us` | 30 | LOW (X-Cameroun Community) |
| X23 - X24 Cameroun | `120363283853277949@g.us` | 22 | LOW (X-Cameroun Community) |
| Spam X24 | `120363322114150116@g.us` | 785 | VERY LOW (X24 Community) |

**Agent rule:** Maintain HIGH → MEDIUM → LOW → VERY LOW order when inserting rows.

## Community Map

Community roots are NOT chats — never message them directly.

| Community | Root JID | Sub-groups |
|-----------|----------|------------|
| Binet IA | `120363377205265375@g.us` | Announcements · Discussion |
| XProjets | `120363360032776776@g.us` | Offres de Missions · Missions XProjets |
| ENSPY Alumni Abroad | `120363028960717937@g.us` | ALUMNI ABROAD · Alumni Abroad 0 |
| X-Cameroun | `120363420960425072@g.us` | X24-X25 Cameroun · X23-X24 Cameroun |
| X24 | `120363399574799388@g.us` | Announcements · Info X24 · Spam X24 |
| KπX-Labs | `120363431336606230@g.us` | General (`120363429571495382@g.us`, 3 members) |

## Contact Search Pitfalls

```
WRONG: whats-proxy do find-messages '{"query":"maman"}'   → searches message content, not names → 0 results
WRONG: baileys list_contacts + name filter               → Baileys stores name: null for most contacts

CORRECT:
  1. Get phone number from KπX
  2. Strip '+' and spaces → E.164 digits only (e.g. +237 77947720 → 23777947720)
  3. JID = <digits>@s.whatsapp.net
  4. Confirm: whats-proxy do contact-info '{"jid":"23777947720@s.whatsapp.net"}'
```

## Audio transcription helper (local)

- For voice notes/audio files downloaded from WhatsApp, use the sovereign **`k-whisper`** CLI tool (Vulkan GPU accelerated, managed via the **`k-ai`** skill).
- **Command pattern (recommended):**
```bash
# Uses the Vulkan GPU optimized wrapper with index 1 (large-v3-turbo)
k-whisper 1 -p "audio.m4a"
# The transcript is automatically generated next to the source audio file as "audio.txt".
```
- **Model quick picks (speed vs quality):** use `k-whisper ls` to see installed models, then `k-whisper <numéro|nom> -p "audio.m4a"`.
- **Intel Arc acceleration:** `k-whisper` uses the native Whisper.cpp Vulkan GPU build — the Intel Arc iGPU is used automatically (see `k-ai`).

## Open Threads (operational memory)

| Thread | Contact/Group | Last State | Next Action |
|--------|---------------|------------|-------------|
| *(none)* | | | |

## Runtime Memory Files

- `references/log.md` — detailed action log for every whats-proxy usage (timestamp, action, outcome, ids, notes)
- `references/insights.md` — durable behavioral memory and extracted patterns for proactive future drafting
- `references/mcp.md` — legacy MCP reference (DEPRECATED, kept for history only)

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-03 | [LIVE] | v3.0.2 — Default media-download path relocated to `~/Downloads/Whats-Proxy/<phone>/`. |
| 2026-09-02 | [LIVE] | v3.0.1 — Fixed action names: `chat-archive` → `chat-manage`, `get-contact-info` → `contact-info`. Updated `tick-mcp` → `tick-proxy`. |
| [SUMMARY] | — | v3.0.0 Full rewrite proxy-only · v2.2.3 MCP purge annotation · older → `references/log.md` |
