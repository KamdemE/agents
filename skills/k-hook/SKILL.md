---
name: k-hook
description: >
  KπX Hook Architecture — design rules and source-of-truth map for lifecycle hooks.
  Generic core/ policy layer plus thin per-agent wrappers. Python-first, TypeScript for OpenClaw.
license: private
metadata:
  author: KpihX
  version: "2.11.1"
  scope: agent-governance
allowed-tools: Bash, Read, Write, Edit
---

# Hook Architecture & Philosophy

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Overview

Hooks are the governance layer of the KπX agent stack.

- `core/` owns reusable policy and validation logic
- `gemini/`, `codex/`, `claude/`, and `openclaw/` only wrap that core for each runtime's documented hook lifecycle
- normative rule text lives in `$HOME/.agents/AGENTS.md`, not in wrapper-specific copies

## Source Of Truth

| Topic | Source |
|------|--------|
| Response contract | `$HOME/.agents/hooks/core/response_validator.py` |
| Dynamic turn context | `$HOME/.agents/hooks/core/prompt_injector.py` |
| Per-turn AGENTS pointer reminder | `$HOME/.agents/hooks/core/skill_watcher.py` |
| Startup context | `$HOME/.agents/hooks/core/context_injector.py` |
| `.agents/` path generalization | `$HOME/.agents/hooks/core/path_guard.py` |
| `SKILL.md` post-edit enforcement | `$HOME/.agents/hooks/core/skill_edit_guard.py` |
| Final dirty-repo reminder | `$HOME/.agents/hooks/core/session_guard.py` |
| `SKILL.md` structure guard | `$HOME/.agents/hooks/core/skill_structure_guard.py` |
| Bundled-file coverage guard | `$HOME/.agents/hooks/core/skill_content_guard.py` |
| Hook feature toggles | `$HOME/.agents/hooks/core/settings.py` |
| Human-readable runtime/checker map | `$HOME/.agents/hooks/README.md` |
| Full recheck entrypoint | `$HOME/.agents/hooks/audit.py` |
| Normative writing and changelog rules | `$HOME/.agents/AGENTS.md` |

## Directory Map

```
$HOME/.agents/hooks/
├── core/
│   ├── __init__.py
│   ├── settings.py
│   ├── context_injector.py
│   ├── prompt_injector.py
│   ├── skill_watcher.py
│   ├── response_validator.py
│   ├── path_guard.py
│   ├── session_guard.py
│   ├── skill_structure_guard.py
│   └── skill_content_guard.py
├── audit.py
├── gemini/
│   ├── session_start.py
│   ├── before_agent.py
│   ├── after_agent.py
│   ├── before_tool.py
│   └── session_end.py
├── codex/
│   ├── session_start.py
│   ├── user_prompt_submit.py
│   ├── stop.py
│   └── hooks.json
├── claude/
│   ├── session_start.py
│   ├── user_prompt_submit.py
│   ├── pre_tool_use.py
│   ├── stop.py
│   └── session_end.py
└── openclaw/
    ├── context-injector/  ← HOOK.md + handler.ts
    ├── path-guard/        ← HOOK.md + handler.ts
    └── session-guard/     ← HOOK.md + handler.ts
```

## Core Rules

### Generic Core

- `core/` stays agent-agnostic
- no `gemini`, `claude`, `codex`, or `openclaw` wording inside core policy logic unless a runtime-specific schema difference is unavoidable
- runtime-specific event names and JSON/TS shapes belong in the wrappers only

### No Desync

- wrappers call core helpers instead of rephrasing the same rule text locally
- reminders point back to `$HOME/.agents/AGENTS.md`
- per-turn hook copy stays minimal on purpose; AGENTS is the normative text, not the wrapper payload
- if a rule changes, update the owning core module or `AGENTS.md`, not four wrappers
- wrapper docstrings and inline schemas must stay aligned with the real runtime wire contract; misleading code comments are also desync
- hook enable/disable switches live in one place only: `$HOME/.agents/hooks/core/settings.py`

### Path Scope

`path_guard.py` applies `$HOME` / `$USER` generalization only to edit/write content targeting `$HOME/.agents/`.

### Dynamic Context

`prompt_injector.py` injects a lightweight block with date, time, shell-style `user@host`, and current working directory.

### Skill Edit Guard

- `skill_edit_guard.py` runs before a write tool commits changes to a KπX-owned `SKILL.md`
- it blocks incomplete skill edits that skipped `metadata.version` or `## Changelog`
- for `k-context`, it also requires `## Session Log`; `## Active Projects` stays a soft reminder, not a hard block

### Structural Coverage

- `skill_structure_guard.py` validates KπX-owned `k-*` `SKILL.md` header/footer structure
- `skill_content_guard.py` validates that bundled top-level files are surfaced in the matching skill
- external skills such as `microsoft-foundry` are outside this KπX structural standard unless AGENTS explicitly says otherwise

### Hook Toggles

- every check can be enabled or disabled in `$HOME/.agents/hooks/core/settings.py`
- change only the `HOOK_FEATURES` booleans there; wrappers should adapt automatically
- default policy stays `True` everywhere unless KπX explicitly turns a check off
- examples: startup context, dynamic context, governance reminder, response-validation subchecks, path generalization, skill-edit checks, dirty-repo finalization, skill structure/content reports

## Runtime Mapping

| Concern | Gemini | Codex | Claude | OpenClaw |
|--------|--------|-------|--------|----------|
| Startup context | `SessionStart` | `SessionStart` | `SessionStart` | `agent:bootstrap` |
| Dynamic context + reminder | `BeforeAgent` | `UserPromptSubmit` | `UserPromptSubmit` | — |
| Write/path/skill guard | `BeforeTool` | — not wired in current Codex setup | `PreToolUse` | `message:sent` advisory |
| Response validation | `AfterAgent` | `Stop` | `Stop` | — |
| Finalization reminder | `SessionEnd` | `Stop` | `SessionEnd` and `Stop` | `command:stop` advisory |

## Runtime Registration

| Agent | Runtime config |
|------|----------------|
| Gemini | `$HOME/.gemini/settings.json` |
| Codex | `$HOME/.codex/hooks.json` plus `$HOME/.codex/config.toml` with `features.codex_hooks = true` |
| Claude | `$HOME/.claude/settings.json` |
| OpenClaw | `$HOME/.openclaw/openclaw.json` plus discovered `HOOK.md` files in `$HOME/.agents/hooks/openclaw/` |

## Runtime-Specific Wire Notes

- Gemini and Claude can keep their own runtime shapes, but the policy logic still comes from `core/`
- the per-turn reminder is intentionally short and only points to `AGENTS.md`
- Codex is strict about wrapper envelopes:
  - `SessionStart` and `UserPromptSubmit` inject text under `hookSpecificOutput.additionalContext`
    - `Stop` blocks require a non-empty root `reason`
  - Codex `.agents/` write guards are intentionally absent until the runtime exposes structured file-edit events worth guarding
  - when a runtime schema changes, update the wrapper first, then this skill, then the matching runtime skill

## Recheck

- Run `python3 $HOME/.agents/hooks/audit.py` after hook or skill-governance changes
- The audit is the compact health check for wrapper syntax, config wiring, YAML validity, and KπX skill guards
- Read `$HOME/.agents/hooks/README.md` when you need the quick checker → runtime map with concrete examples

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.11.1 — fixed the runtime-mapping table so Claude keeps `PreToolUse` for write guards while Codex stays explicitly unwired for structured `.agents/` file-edit enforcement in the current setup |
| 2026-04-03 | [CODEX] | v2.11.0 — moved the shared audit entrypoint from `hooks/core/` to `$HOME/.agents/hooks/audit.py` so the recheck lives at the hooks layer it validates, and resynced the directory map and recheck guidance accordingly |
| [SUMMARY] | — | v2.11.0–v2.0.0: corrected runtime-mapping table, top-level `hooks/audit.py`, `hooks/README.md` runtime/checker map, `skill_edit_guard.py`, settings centralization, Codex wire-contract notes, compact source-of-truth rewrite, generic-core plus thin-wrapper clarification, prompt/session/path guard cleanup, codex/openclaw wrapper rollout, and DRY/no-desync enforcement |
