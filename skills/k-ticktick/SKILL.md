---
name: k-ticktick
description: tick-mcp operational memory — KπX TickTick project/folder map and critical V1/V2 API gotchas (silent failures). Load before any tick-mcp tool call.
license: private
metadata:
  author: KpihX
  version: "2.0.12"
allowed-tools: mcp__tick-mcp__*, mcp__tick-mcp--stdio__*
---

# Tool Memory — TickTick (tick-mcp)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Discipline (mandatory)

- You must read `$HOME/.agents/skills/k-ticktick/references/insights.md` before doing any TickTick task.
- You must append one detailed entry to `$HOME/.agents/skills/k-ticktick/references/log.md` after every tick-mcp tool use.
- **Run-speed policy (immediate minimal):** during active execution, record only critical task/event facts (ids, write action, silent-failure incident). Defer broader retrospective synthesis to batch memory curation.
- You must proactively update `references/insights.md` at the end of the task with reusable learnings:
  - planning style and prioritization patterns
  - recurring calendar/task categories
  - recurring workflow preferences and phrasing
  - open loops, blockers, and follow-up behavior
- You must proactively update `## Open Threads (operational memory)` when planning thread status changes.
- You have full control over the whole `k-ticktick/` folder and must proactively keep all files up to date (`SKILL.md`, `references/log.md`, `references/insights.md`, `references/mcp.md`, and other files).
- Before ending, you must run a final self-check: "Are all files in `k-ticktick/` reflecting current reality?" If not, update them immediately.
- Before creating any task/note/event, you must first identify the correct destination (folder/project) by inspecting existing TickTick structure and examples, even if it requires multiple MCP calls.
- **Closure hygiene — TickTick:** When a task is **done** (work finished, or KπX says they completed it), **mark it completed** via tick-mcp **in the same workstream**, then **read back** state to catch silent API failures. **Do not** continue as if closed while the task still shows open. **Persistent nudge:** on later turns, if a named done-task is still open, repeat *Still to mark done: …* until fixed (see **`k-mail` / `k-whatsapp` `## Closure hygiene`** for the same loop across channels).
- `SKILL.md` describes stable operating rules and how to use tick-mcp transports (`stdio` and/or `http`).
- `## Changelog` in this file tracks only modifications to the `k-ticktick/` skill folder, not runtime TickTick actions.

## Project Map

| Folder | Projects |
|--------|---------|
| Scolaire X | Notes · Todos · Agenda · Extra Scolaire |
| Careers | Todos · Notes · Agenda |
| Persos | Courses · Proches · Administratif · Sante · Todos · Notes · Agenda |
| Tech & Dev | Notes · Prompts · Windows · Ubuntu · Todos · Projets · Agent OS |
| Flow | Ideas · Tasks · Pense Betes · Research · A voir |
| Homelab | Todos · Ideas · Notes · Boost |

## Critical API Gotchas (V1/V2)

These are **silent failures** — no error thrown, data simply not saved:

| Operation | Gotcha | Correct approach |
|-----------|--------|-----------------|
| Create subtask | `parentId` silently ignored at creation | `create task` → `set_subtask_parent` (two-step) |
| Create project group | `groupId` silently ignored by V1 | Follow up with V2 `batch/project` |
| Update habit | `PATCH /habits/batch` = full replacement | Always read-modify-write before updating |
| Move tasks with children | `move_tasks` does NOT cascade to children | Fetch `childIds` and move atomically in one batch |

## MCP Setup Reference

- Generic setup (HTTP + stdio): `$HOME/.agents/skills/k-ticktick/references/mcp.md`
- **Missing Tool / MCP Action:** If KπX asks to use tick-mcp and the agent doesn't already see it in its activated tools, the agent MUST look at `references/mcp.md` for the process of adding it, and proactively add it as an MCP before attempting to continue the task. Use the naming convention **`tick-mcp-http`** and **`tick-mcp-stdio`**.

## Use Cases (agent orientation)

- Use tick-mcp to provide overviews of calendar and tasks (`events_of_today`, `tasks_of_today`, `week_overview`, `week_agenda`, `upcoming_tasks`, `overdue_tasks`).
- Use tick-mcp to inspect workspace structure and planning context (`workspace_map`, `query_projects`, `query_folders`).
- For write operations, always verify post-write state with read-back tools to avoid silent V1/V2 failures.

## What's up (TickTick briefing)

**When:** KπX says *what's up* **tick**, *what's tick*, or the **fourth** step of the full *what's up* ladder (after context, mail, WhatsApp) — **this skill only** in that turn.

**Tools (non-exhaustive):** `tasks_of_today`, `events_of_today`, `week_agenda`, `week_overview`, `upcoming_tasks`, `overdue_tasks`, `workspace_map`, `query_projects`, `query_folders`, `priority_dashboard` — combine so nothing is missed.

**Presentation order — exhaustive detail:**

1. **Today — academic / professional first** — Tasks and calendar events touching **`Scolaire X`**, **`Careers`**, exam/deadline keywords, stage, PSC, certifications, IPAI/hackathon, poly admin mirrors; include time, project, folder, notes, recurrence.
2. **Today — personal projects & other folders** — **`Tech & Dev`**, **`Homelab`**, **`Flow`**, **`Persos`** (condense only if empty).
3. **Overdue** — Every overdue task: age, project, suggested next step (one line each); **propose** rescheduling or completion.
4. **Horizon — soon** — Buckets: **within a few hours**, **tomorrow**, **day after tomorrow**; include events (location, time zone Europe/Paris default) and tasks with due time.
5. **Proactive layer** — Cross-link to mail/WhatsApp *What's up* findings from **previous turns** (if any in session): *« Suggested TickTick: … »*; **do not** bundle those other skills’ data fetches into **this** same generation unless KπX scoped only tick + already provided context.
6. **Closure nudge** — List any task **explicitly discussed as done** in the session that is **still open** in TickTick; propose **`complete`** (or equivalent) before closing the slice.

**Sequential ladder:** **AGENTS.md → What's up** — one domain per assistant response; **never** pair with `k-mail` or `k-whatsapp` fetches in the same generation.

## Open Threads (operational memory)

| Thread | Scope | Last State | Next Action |
|--------|-------|------------|-------------|
| Linguaskill certification windows | `🎓 X/📅 Agenda` | Created 3 items on 2026-04-09: session windows (`13-17` and `20-24` Apr) + daily prep loop to 2026-04-25 (06:30 and 20:00 reminders) | Watch mailbox assignment from certification thread UID `8323`; complete irrelevant duplicates once slot is assigned |

## Runtime Memory Files

- `references/log.md` — detailed action log for every tick-mcp usage (timestamp, action, outcome, ids, notes)
- `references/insights.md` — durable behavioral memory and extracted patterns for proactive future planning support
- `references/mcp.md` — transport and setup reference for tick-mcp (`http` and `stdio`)
- `references/tool-keep-matrix.md` — permanent YES/NO tool matrix used to drive MCP disabled-tools policy

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-13 | [CODEX] | v2.0.12 — Registered `references/tool-keep-matrix.md` as bundled source-of-truth for TickTick tool reduction policy. |
| 2026-04-13 | [GEMINI] | v2.0.11 — Added instruction: if requested but absent from tools, verify `references/mcp.md` and add as MCP first. |
| [SUMMARY] | — | v2.0.10 immediate-minimal run policy; v2.0.9 open-thread Linguaskill tracking; v2.0.8 closure hygiene + nudge loop; v2.0.7–v2.0.0 prior runtime memory/migration |
