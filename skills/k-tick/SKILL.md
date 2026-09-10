---
name: k-tick
description: tick-proxy — TickTick admin proxy CLI. Tasks, projects, habits, tags, queries, raw access.
license: private
metadata:
  author: KpihX
  version: "2.3.1"
  scope: tool-memory
allowed-tools: "Bash(*), Read(*), Glob(*), *"
---

# KπX — TickTick (`tick-proxy`)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**
> **Project:** `$HOME/KpihX-Labs/Proxies/tick-proxy/` · **Repos:** GitHub + GitLab (tick-proxy)
> **Related:** `k-tg` (same ADN) · `k-tmux` (HITL shared gate) · `k-clis` (CLI registry)

## Identity

`tick-proxy` is a single Python CLI with two namespaces:
```bash
tick-proxy admin setup|status|session-refresh|reset|purge   # Always JSON
tick-proxy do <action> [payload|file]           # Flat RPC, --format json|table, --output-file
```
Config: `~/.config/tick-proxy/.env` — `TICK_API_TOKEN` (V1, required), `TICK_SESSION_TOKEN`
(V2, optional), `TICK_EMAIL` (e-mail, optional). **The password is NEVER stored.**
Autosave: `/tmp/tick-proxy-autosave/{action}_{timestamp}.jsonmap`.

## Runtime Discipline (mandatory)

- **NEVER read the tool's source code when stuck on payload parameters.** The tool's code will not be local in production after the beta.
- **ALWAYS use `--help`**: resolve any query, parameter, or payload schema ambiguity by executing:
  ```bash
  tick-proxy --help
  tick-proxy do <action> --help
  ```
- **Poll with `sleep 5`** after sending a destructive or write action to the tmux ops pane until the HITL review completes or times out.

### Install
```bash
cd $HOME/KpihX-Labs/Proxies/tick-proxy && uv tool install --editable .
tick-proxy admin setup      # HITL web form: paste the V1 token (+ session token)
```

### Two APIs
| API | Auth | Unlocks |
|-----|------|---------|
| **V1** Open API | `TICK_API_TOKEN` (Bearer) | tasks, projects |
| **V2** web API | `TICK_SESSION_TOKEN` (cookie `t`) | tags, habits, folders, columns, batch, focus, history, sync, all query/view actions |

V2 token lasts ~30 days → `tick-proxy admin session-refresh` (HITL form asks for
username + password, exchanges them for a token, **discards the password**).

### V2 refresh troubleshooting

`access_forbidden` during `admin session-refresh` is a device/browser-flow failure, not a reason
to retry blindly. Require the shared canonical web headers — including `X-Device` — on sign-on,
MFA verification, and the V2 status probe. MFA must use `wc=true&remember=true`,
`x-verify-id: <authId>`, and `{code, method:"app"}` (never `authId` in JSON). If TickTick returns
a long-lived `authId`, request HITL confirmation of the email device-approval link, then retry
sign-on **once**. Keep credentials transient and never expose server error bodies.

---

## 52 `do` Actions (HITL ✅ / verified 🔒)

| Action | HITL | Action | HITL | Action | HITL |
|--------|:----:|--------|:----:|--------|:----:|
| `task-create` | ✅ | `project-list` | ❌ | `habit-list` | ❌ |
| `task-update` | ✅ | `project-info` | ❌ | `habit-section-list` | ❌ |
| `task-complete` | ❌ | `project-create` 🔒 | ❌ | `habit-create` | ❌ |
| `task-reopen` | ❌ | `project-update` 🔒 | ❌ | `habit-update` 🔒 | ❌ |
| `task-delete` | ✅ | `project-delete` | ✅ | `habit-delete` | ✅ |
| `task-info` | ❌ | `folder-list` | ❌ | `habit-checkin` | ❌ |
| `project-tasks` | ❌ | `folder-manage` | ⚠️ | `habit-records` | ❌ |
| `inbox-list` | ❌ | `column-list` | ❌ | `focus-stats` | ❌ |
| `task-batch-create` | ✅ | `column-manage` | ⚠️ | `user-status` | ❌ |
| `task-batch-update` | ✅ | `tag-list` | ❌ | `user-stats` | ❌ |
| `task-batch-delete` | ✅ | `tag-create` | ❌ | `workspace-map` | ❌ |
| `task-move` 🔒 | ❌ | `tag-update` | ❌ | `query-projects` | ❌ |
| `task-parent-set` 🔒 | ❌ | `tag-merge` | ✅ | `query-folders` | ❌ |
| `subtask-create` 🔒 | ✅ | `tag-delete` | ✅ | `query-tasks` | ❌ |
| `task-list` | ❌ | `history-query` | ❌ | `query-agenda` | ❌ |
| `sync-full` | ❌ | `view-today` | ❌ | `view-week` | ❌ |
| `view-week-overview` | ❌ | `view-upcoming` | ❌ | `view-overdue` | ❌ |
| **`raw`** | ✅ | | | | |

⚠️ = HITL only when the payload contains `delete`.
🔒 = carries declarative verification: the write is read back and compared; the final result includes the proof block under `data.verification` (no `--verify` flag).

### Task Write Reviews
`task-create`, `task-update`, and `subtask-create` are **always HITL** and carry the task-document reviews policy. Their proposed payload is built from `title_ops`, `content_ops`, or `desc_ops` list operations (no raw document fields accepted). The review page displays the full editable JSON beside three editable inline Monaco patch editors for title, content, and description. The final approved result overrides only those fields and returns the exact persisted document values alongside `data.diff.{title_diff,content_diff,desc_diff}`.

`task-batch-create` and `task-batch-update` are also **always HITL** but carry the standard full-JSON review policy without document diffs: use them only for clean bulk edits and rely on individual `task-*` / `subtask-create` actions when document diff reviews are preferred.

### Destructive preflight & lock
All 8 destructive actions (`project-delete`, `task-delete`, `task-batch-delete`, `tag-delete`, `tag-merge`, `habit-delete`, `folder-manage` [delete], `column-manage` [delete]) pre-read their target resources and lock their identities before the HITL page opens. If the target is absent or has been altered in the review payload, the execution terminates immediately without a client write. `project-delete` then sends exactly one V2 batch deletion and polls V1 until `404` or `{}` confirms absence.

### HITL rule (CRITICAL)
`raw` + all ✅ above open a **browser review form** on an OS-assigned free port.
Run them from a **tmux ops pane** (`<session>:0.2`) so KπX can approve:
1. `tmux send-keys -t <ses>:0.2 "tick-proxy do task-delete '{...}'" Enter`
2. **Poll with `sleep 5`** until the prompt returns
3. **Use `raw` ONLY if no dedicated `do` action exists**

---

## Envelope

Every response is `{"meta": …, "data": …}`:
```json
{"meta":{"status":"ok","comment":"","edited":false,"verification":null},"data":{…}}
```
- `status`: ok · approved · rejected · error (`approved`/`rejected` only with HITL)
- `verification`: present ⇒ verified; `null`/`{}` ⇒ not verified. **There is no `verified` field.**
- `data.diff`: present only after an approved TickTick NOTE create/update; it is the real unified
  document delta sent after human edits. No other review wrapper is added.
- `stdout` is pure JSON → `tick-proxy do … | jq` always works (logs go to stderr).

---

## Recurring queries → `assets/`

There is **no preset machinery**. Recurring queries are JSON files in this skill's
`assets/`, invoked through the payload file-path:
```bash
tick-proxy do query-tasks ~/.agents/skills/k-tick/assets/urgent.json
tick-proxy do view-week-overview ~/.agents/skills/k-tick/assets/week-planning.json
```
Edit the JSON file to change the query — nothing to migrate, git-tracked with the skill.

| Asset | Action | Purpose |
|-------|--------|---------|
| `urgent.json` | `query-tasks` | Priority-5 active tasks, soonest first |
| `today.json` | `view-today` | Today's scheduled items |
| `week-planning.json` | `view-week-overview` | Events / due / overdue split for the week |
| `stale.json` | `query-tasks` | Tasks untouched for 30+ days |
| `overdue.json` | `view-overdue` | The backlog |

---

## TickTick API gotchas (silent failures — 200 OK, data not saved)

| Operation | Gotcha | Correct approach |
|-----------|--------|------------------|
| Create subtask | `parentId` ignored at creation (V1 **and** V2 batch) | `subtask-create` (composite + verified) |
| Assign project folder | `groupId` ignored by V1; V1 reads return `null` | `project-update` (V2 + verified); `"NONE"` clears |
| Update habit | V2 `/habits/batch` = **full replacement** | `habit-update` (read-modify-write + verified) |
| Move task with children | V2 never cascades | `task-move` (auto-cascade + verified) |
| Reminders | V1 needs `dueDate` as trigger anchor | always pass `due_date` + `time_zone` with `reminder_minutes` |
| Kanban column update | `projectId` missing ⇒ silent drop (200, empty `id2etag`) | `column-manage` (injects it) |

---

## Project Map

| Folder | Projects |
|--------|---------|
| 🎓 X | 📒 Notes · ✅ Todos · 📅 Agenda · 🎭 Extra Scolaire |
| 💼 Careers | ✅ Todos · 📝 Notes · 📅 Agenda |
| 🏠 Persos | 🛒 Courses · 👥 Proches · 📋 Administratif · 🏥 Santé · ✅ Todos · 📝 Notes · 📅 Agenda |
| 🛠️ Tech & Science | 📝 Notes · 💬 Prompts · 🪟 Windows · 🐧 Ubuntu · ✅ Todos · 🗂️ Projets · 🤖 Agent OS · ✍️ Articles & Publications |
| 🌊 Flow | 💡 Ideas · ✅ Tasks · 📝 Pense Bêtes · 🔬 Research · 👀 À voir |
| 🖥️ Homelab | ✅ Todos · 💡 Ideas · 📒 Notes · 🚀 Boost |

Read it live — never hardcode ids:
```bash
tick-proxy do workspace-map      # folder → project tree with task counts
tick-proxy do project-list       # flat list (⚠️ groupId always null in V1)
```

## What's up — tick slice

**When:** KπX asks *what's up* **tick**, *what's tick*, or the **fourth** step of the full *what's up* ladder (after context, mail, WhatsApp) — **this skill only** in that turn.

**CLI Commands (non-exhaustive):**
- `tick-proxy do view-today` — today's calendar and active tasks
- `tick-proxy do view-week` — 7-day scheduled agenda
- `tick-proxy do view-overdue` — active tasks with past due dates
- `tick-proxy do view-week-overview` — weekly events / due / overdue planning split
- `tick-proxy do query-tasks ~/.agents/skills/k-tick/assets/urgent.json` — urgent items
- `tick-proxy do workspace-map` — project folder hierarchy and active counts

**Detail mandate (non-negotiable):** This briefing is **not a summary output**. Deliver full factual details in the first response, avoid synthesis-only compression, and do not postpone detail behind follow-up questions.
**Batch depth mandate (non-negotiable):** execute this slice as a deep batch exploration (tasks, events, overdue, horizon, linked context) and stop only after materially complete coverage.

1. **Today — academic / professional first** — Tasks and calendar events touching **`🎓 X`**, **`💼 Careers`**, exam/deadline keywords, stage, PSC, certifications, IPAI/hackathon, poly admin mirrors; include time, project, folder, notes, recurrence.
2. **Today — personal projects & other folders** — **`🛠️ Tech & Science`**, **`🖥️ Homelab`**, **`🌊 Flow`**, **`🏠 Persos`** (condense only if empty).
3. **Overdue** — Every overdue task: age, project, suggested next step (one line each); **propose** rescheduling or completion.
4. **Horizon — soon** — Buckets: **within a few hours**, **tomorrow**, **day after tomorrow**; include events (location, time zone Europe/Paris default) and tasks with due time.
5. **Proactive layer** — Cross-link to mail/WhatsApp *What's up* findings from **previous turns** (if any in session): *« Suggested TickTick: … »*; **do not** bundle those other skills’ data fetches into **this** same generation unless KπX scoped only tick + already provided context.
6. **Closure nudge** — List any task **explicitly discussed as done** in the session that is **still open** in TickTick; propose **`task-complete`** (or equivalent) before closing the slice.

**Sequential ladder:** **AGENTS.md → What's up** — one domain per assistant response; **never** pair with `k-mail` or `k-whats` fetches in the same generation.

---

## Runtime Memory Files

- `references/insights.md` — Append-only operational memory for `tick-proxy` lessons
- `references/log.md` — Changelog Archive rotated from `SKILL.md`
- `references/mcp-runtime-log.md` — Legacy runtime execution log for TickTick operations

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial work in this domain.
- Update it at the end with durable lessons (mistakes to avoid, validated fixes).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-09-07 | [LIVE] | v2.3.1 — Insights: `task-batch-create` uses raw fields (NOT ops), `task-move` requires `moves` array, large NOTE via `task-create` OK. |
| 2026-08-15 | [COLAB] | **v2.3.0 — Project path updated** (`$HOME/KpihX-Labs/tick_proxy/` → `$HOME/KpihX-Labs/Proxies/tick-proxy/`) after tick-proxy was moved into `proxies/` and aligned to the kebab-case naming convention. |
| [SUMMARY] | -- | v1.0.4 . v1.0.3 task-create/update HITL unconditional (→ `references/log.md`) · v1.0.2 TickTick refresh recovery → `references/log.md` · v1.0.1 TICK_EMAIL rename → `references/log.md`. v1.0.0 — Skill created for **`tick-proxy` v1.0.0**, the non-MCP CLI that replaces the old TickTick MCP entirely. 52 `do` actions + 3 `admin` commands, `meta`+`data` envelope with no `verified` field, `@always_verify` decorator on the 6 silent-failure writes, HITL on the 7 destructive actions + `raw`, recurring ... |

