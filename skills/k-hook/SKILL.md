---
name: k-hook
description: >
  KπX Hook Architecture — design rules and source-of-truth map for lifecycle hooks.
  Generic core/ policy layer plus thin per-agent wrappers. Python-first, TypeScript for OpenClaw.
license: private
metadata:
  author: KpihX
  version: "2.12.0"
  scope: agent-governance
allowed-tools: Bash, Read, Write, Edit
---

# Hook Architecture & Philosophy

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Overview

- `core/` owns shared policy and validation logic
- one subdir per runtime (`gemini/`, `claude/`, `codex/`, `openclaw/`) binds that core to the agent lifecycle
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
| OpenClaw | `$HOME/.openclaw/openclaw.json` plus `$HOME/.agents/hooks/openclaw/` |

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.12.0 — compacted the skill to the minimal architectural map, removed duplicated runtime/checker detail, and pushed exact mapping/examples down to `$HOME/.agents/hooks/README.md` |
| 2026-04-03 | [CODEX] | v2.11.1 — fixed the runtime-mapping table so Claude keeps `PreToolUse` for write guards while Codex stays explicitly unwired for structured `.agents/` file-edit enforcement in the current setup |
| [SUMMARY] | — | v2.11.1–v2.0.0: compact architectural rewrite, corrected runtime-mapping table, top-level `hooks/audit.py`, `hooks/README.md` runtime/checker map, `skill_edit_guard.py`, settings centralization, Codex wire-contract notes, prompt/session/path guard cleanup, codex/openclaw wrapper rollout, and DRY/no-desync enforcement |
