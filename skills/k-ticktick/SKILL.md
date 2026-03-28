---
name: kpihx-ticktick
description: tick-mcp operational memory — KπX TickTick project/folder map and critical V1/V2 API gotchas (silent failures). Load before any tick-mcp tool call.
license: private
metadata:
  author: KpihX
  version: "2.0.0"
allowed-tools: mcp__tick-mcp__*, mcp__tick-mcp--fallback__*
---

# Tool Memory — TickTick (tick-mcp)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

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

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-25 | [CLAUDE] | v2.0.0 — refonte, migrated to skills/kpihx/ticktick/ |
| [SUMMARY] | — | v1.0.0 — initial creation, migrated from ~/.agent/AGENT.md §7 |
