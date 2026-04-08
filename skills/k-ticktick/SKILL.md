---
name: k-ticktick
description: tick-mcp operational memory — KπX TickTick project/folder map and critical V1/V2 API gotchas (silent failures). Load before any tick-mcp tool call.
license: private
metadata:
  author: KpihX
  version: "2.0.6"
allowed-tools: mcp__tick-mcp__*, mcp__tick-mcp--stdio__*
---

# Tool Memory — TickTick (tick-mcp)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Discipline (mandatory)

- You must read `$HOME/.agents/skills/k-ticktick/references/insights.md` before doing any TickTick task.
- You must append one detailed entry to `$HOME/.agents/skills/k-ticktick/references/log.md` after every tick-mcp tool use.
- You must proactively update `references/insights.md` at the end of the task with reusable learnings:
  - planning style and prioritization patterns
  - recurring calendar/task categories
  - recurring workflow preferences and phrasing
  - open loops, blockers, and follow-up behavior
- You must proactively update `## Open Threads (operational memory)` when planning thread status changes.
- You have full control over the whole `k-ticktick/` folder and must proactively keep all files up to date (`SKILL.md`, `references/log.md`, `references/insights.md`, `references/mcp.md`, and other files).
- Before ending, you must run a final self-check: "Are all files in `k-ticktick/` reflecting current reality?" If not, update them immediately.
- Before creating any task/note/event, you must first identify the correct destination (folder/project) by inspecting existing TickTick structure and examples, even if it requires multiple MCP calls.
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

## Use Cases (agent orientation)

- Use tick-mcp to provide overviews of calendar and tasks (`events_of_today`, `tasks_of_today`, `week_overview`, `week_agenda`, `upcoming_tasks`, `overdue_tasks`).
- Use tick-mcp to inspect workspace structure and planning context (`workspace_map`, `query_projects`, `query_folders`).
- For write operations, always verify post-write state with read-back tools to avoid silent V1/V2 failures.

## Open Threads (operational memory)

| Thread | Scope | Last State | Next Action |
|--------|-------|------------|-------------|
| *(none)* | | | |

## Runtime Memory Files

- `references/log.md` — detailed action log for every tick-mcp usage (timestamp, action, outcome, ids, notes)
- `references/insights.md` — durable behavioral memory and extracted patterns for proactive future planning support
- `references/mcp.md` — transport and setup reference for tick-mcp (`http` and `stdio`)

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-08 | [CODEX] | v2.0.6 — enforced mandatory destination-discovery workflow before any task/note/event creation (inspect structure/examples first, multi-call allowed). |
| 2026-04-07 | [CODEX] | v2.0.3 — aligned TickTick MCP setup reference with stdio-only command mode (`--fallback` removed) and updated allowed tool suffix. |
| [SUMMARY] | — | v2.0.5 runtime memory protocol + full-folder ownership + reality self-check + open-threads maintenance + calendar/task overview orientation; v2.0.2–v2.0.1 setup reference pointer + wording normalization; v2.0.0 migration and v1.0.0 initial creation from legacy kernel section. |
