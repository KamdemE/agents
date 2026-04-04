---
name: k-hook
description: >
  KπX Hook Architecture — design rules and source-of-truth map for lifecycle hooks.
  Generic core/ policy layer plus thin per-agent wrappers.
license: private
metadata:
  author: KpihX
  version: "2.16.0"
  scope: agent-governance
allowed-tools: Bash, Read, Write, Edit
---

# Hook Architecture & Philosophy

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Overview

- `core/` owns shared policy and validation logic
- one subdir per runtime (`gemini/`, `claude/`, `codex/`) binds that core to the agent lifecycle
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
## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CLAUDE] | v2.16.0 — make `:` optional in `response_validator.py` section regexes (Comments/Remarks/Suggestions) — semantic detection, not punctuation |
| 2026-04-04 | [CLAUDE] | v2.15.0 — fix `session_guard.py`: `os.path.exists()` filter in `_changed_skill_paths` prevents `FileNotFoundError` on deleted SKILL.md |
| [SUMMARY] | — | v2.14.0–v2.0.0: retired runtime removal, PostToolUse advisory for Claude, compact rewrite, hooks/README.md runtime map, skill_edit_guard.py, settings centralization, guard cleanup, DRY enforcement |
