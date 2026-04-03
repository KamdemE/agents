---
name: k-hook
description: >
  KπX Hook Architecture — design rules and source-of-truth map for lifecycle hooks.
  Generic core/ policy layer plus thin per-agent wrappers. Python-first, TypeScript for OpenClaw.
license: private
metadata:
  author: KpihX
  version: "2.5.0"
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
| Startup context | `$HOME/.agents/hooks/core/context_injector.py` |
| `.agents/` path generalization | `$HOME/.agents/hooks/core/path_guard.py` |
| Final dirty-repo reminder | `$HOME/.agents/hooks/core/session_guard.py` |
| `SKILL.md` structure guard | `$HOME/.agents/hooks/core/skill_structure_guard.py` |
| Bundled-file coverage guard | `$HOME/.agents/hooks/core/skill_content_guard.py` |
| Full recheck entrypoint | `$HOME/.agents/hooks/core/audit.py` |
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
│   ├── skill_content_guard.py
│   └── audit.py
├── gemini/
│   ├── session_start.py
│   ├── before_agent.py
│   ├── after_agent.py
│   ├── before_tool.py
│   └── session_end.py
├── codex/
│   ├── session_start.py
│   ├── user_prompt_submit.py
│   ├── pre_tool_use.py
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
- if a rule changes, update the owning core module or `AGENTS.md`, not four wrappers

### Path Scope

`path_guard.py` applies `$HOME` / `$USER` generalization only to content targeting `$HOME/.agents/`.

### Dynamic Context

`prompt_injector.py` injects a lightweight block with date, time, shell-style `user@host`, and current working directory.

### Structural Coverage

- `skill_structure_guard.py` validates KπX-owned `k-*` `SKILL.md` header/footer structure
- `skill_content_guard.py` validates that bundled top-level files are surfaced in the matching skill
- external skills such as `microsoft-foundry` are outside this KπX structural standard unless AGENTS explicitly says otherwise

## Runtime Mapping

| Concern | Gemini | Codex | Claude | OpenClaw |
|--------|--------|-------|--------|----------|
| Startup context | `SessionStart` | `SessionStart` | `SessionStart` | `agent:bootstrap` |
| Dynamic context + reminder | `BeforeAgent` | `UserPromptSubmit` | `UserPromptSubmit` | — |
| Write/path guard | `BeforeTool` | `PreToolUse` | `PreToolUse` | `message:sent` advisory |
| Response validation | `AfterAgent` | `Stop` | `Stop` | — |
| Finalization reminder | `SessionEnd` | `Stop` | `SessionEnd` and `Stop` | `command:stop` advisory |

## Runtime Registration

| Agent | Runtime config |
|------|----------------|
| Gemini | `$HOME/.gemini/settings.json` |
| Codex | `$HOME/.codex/hooks.json` plus `$HOME/.codex/config.toml` with `features.codex_hooks = true` |
| Claude | `$HOME/.claude/settings.json` |
| OpenClaw | `$HOME/.openclaw/openclaw.json` plus discovered `HOOK.md` files in `$HOME/.agents/hooks/openclaw/` |

## Recheck

- Run `python3 $HOME/.agents/hooks/core/audit.py` after hook or skill-governance changes
- The audit is the compact health check for wrapper syntax, config wiring, YAML validity, and KπX skill guards

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v2.5.0 — rewrote the skill into a compact source-of-truth map, documented the now-live Claude wrappers and `core/audit.py`, and removed stale TODO/legacy wording so the skill matches the real generic-core plus thin-wrapper architecture |
| 2026-04-03 | [CODEX] | v2.4.0 — clarified that `core/` stays generic while wrappers bind concrete lifecycle events, documented `skill_content_guard.py`, and restricted structural guards to KπX-owned `k-*` skills |
| [SUMMARY] | — | v2.3.0–v2.0.0: centralized settings extraction, prompt/session/path guard cleanup, codex/openclaw wrapper rollout, and DRY/no-desync enforcement |
