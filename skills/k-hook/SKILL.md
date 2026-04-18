---
name: k-hook
description: >
  KπX Hook Architecture — design rules and source-of-truth map for lifecycle hooks.
  Generic core/ policy layer plus thin per-agent wrappers.
license: private
metadata:
  author: KpihX
  version: "2.17.2"
  scope: agent-governance
allowed-tools: Bash, Read, Write, Edit
---

# Hook Architecture & Philosophy

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Overview

- `core/` owns shared policy and validation logic
- one subdir per runtime (`gemini/`, `claude/`, `codex/`, `copilot/`) binds that core to the agent lifecycle
- normative rule text stays in `$HOME/.agents/AGENTS.md`
- detailed checker/runtime mapping stays in `$HOME/.agents/hooks/README.md`

## Source Of Truth

| Topic | Source |
|------|--------|
| Normative rules | `$HOME/.agents/AGENTS.md` |
| Hook tree overview and live examples | `$HOME/.agents/hooks/README.md` |
| Shared hook settings and feature toggles | `$HOME/.agents/hooks/core/settings.py` |
| Shared recheck entrypoint | `$HOME/.agents/hooks/audit.py` |
| Runtime-specific wiring | `$HOME/.agents/hooks/<agent>/` plus the matching runtime config |

## Operating Rules

- keep `core/` agent-agnostic; runtime shapes belong only in wrappers
- wrappers must call core helpers instead of copying rules locally
- hook reminders must point back to `AGENTS.md` instead of restating it
- keep this skill high-level: if you need exact events, payloads, or examples, read `$HOME/.agents/hooks/README.md`
- after hook or skill-governance changes, run `python3 $HOME/.agents/hooks/audit.py`

## Runtime Registration

| Agent | Runtime config |
|------|----------------|
| Gemini | `$HOME/.gemini/settings.json` |
| Codex | `$HOME/.codex/hooks.json` plus `$HOME/.codex/config.toml` |
| Claude | `$HOME/.claude/settings.json` |
| Copilot (VS Code) | `$HOME/.config/Code/User/settings.json` — `chat.hookFilesLocations` → `$HOME/.agents/hooks/copilot/hooks.json` · scripts `$HOME/.agents/hooks/copilot/` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-hook/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-hook/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-13 | [CODEX] | v2.17.2 — Standardized insights discipline and autonomous maintenance hooks for this skill. |
| 2026-04-11 | [CODEX] | v2.17.1 — `hooks/audit.py` now reports missing optional runtime config files as findings instead of crashing the whole audit pass. |
| [SUMMARY] | — | +1 older changelog entries kept in file history; condensed for table limits |