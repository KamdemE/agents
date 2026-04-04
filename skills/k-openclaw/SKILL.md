---
name: k-openclaw
description: >
  OpenClaw runtime — workspace root, managed skills sync, exec approvals, core config files,
  and hook integration points. Load when configuring OpenClaw, managing skills/approvals,
  or debugging runtime behavior.
license: private
metadata:
  author: KpihX
  version: "1.11.0"
  scope: agent-runtime
  target-agent: openclaw
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — OpenClaw

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Agent home:** `$HOME/.openclaw/`
- **Workspace root:** `$HOME/.openclaw/workspace/`
- **Global kernel:** `$HOME/.openclaw/workspace/AGENTS.md` → `$HOME/.agents/AGENTS.md`
- **Managed skills path:** `$HOME/.openclaw/workspace/skills/`
- **Session history:** `$HOME/.openclaw/agents/main/sessions/`
- **Memory stores:** `$HOME/.openclaw/memory/` and `$HOME/.openclaw/workspace/memory/`

## Source Of Truth

| File or dir | Role |
|------------|------|
| `$HOME/.openclaw/openclaw.json` | main runtime config: models, channels, hooks, workspace, plugins |
| `$HOME/.openclaw/exec-approvals.json` | exec approval policy |
| `$HOME/.openclaw/workspace/config/mcporter.json` | MCP server definitions |
| `$HOME/.openclaw/workspace/skills/` | live OpenClaw-visible skill copies |
| `$HOME/.agents/hooks/openclaw/` | managed hook implementations and `HOOK.md` manifests |

## Core Rules

- keep workspace rooted at `$HOME/.openclaw/workspace/`; do not point OpenClaw at `$HOME/`
- OpenClaw rejects out-of-root symlinks after resolution, so KπX skills are copied/rsynced into the workspace instead of linked
- `openclaw.json` and `mcporter.json` are separate sources of truth; do not merge their responsibilities mentally
- use `${ENV_VAR_NAME}` syntax for secrets in config values

## Skills Sync

- KπX skills are synchronized from `$HOME/.agents/skills/` into `$HOME/.openclaw/workspace/skills/`
- the normal path is the `.agents` post-commit hook
- after a KπX skill rename, explicitly remove stale legacy copies from `$HOME/.openclaw/workspace/skills/` so OpenClaw and QMD do not keep indexing both old and new names
- manual refresh fallback:

```bash
rsync -a --delete $HOME/.agents/skills/<name>/ $HOME/.openclaw/workspace/skills/<name>/
```

## Hooks

OpenClaw discovers managed hooks from `$HOME/.agents/hooks/openclaw/`, with enablement in `$HOME/.openclaw/openclaw.json`.

- `hooks.internal.load.extraDirs` must include `$HOME/.agents/hooks/openclaw`
- the managed hook dirs are `context-injector/`, `path-guard/`, and `session-guard/`
- each hook dir must contain both `HOOK.md` and `handler.ts`
- exact event mapping and advisory limitations live in `$HOME/.agents/hooks/README.md`

## Exec Approvals

- current policy is defined in `$HOME/.openclaw/exec-approvals.json`
- apply changes with:

```bash
openclaw approvals set --file $HOME/.openclaw/exec-approvals.json
```

- use allowlists only for genuinely safe repeat patterns

## Operational Notes

- local Ollama source of truth: `http://127.0.0.1:11434`; default local model: `phi4-mini:latest`
- current local-only optimization posture on KpihX Ubuntu: `contextTokens=16384`, `maxConcurrent=1`, `subagents.maxConcurrent=1`, `memorySearch.enabled=false`, `verboseDefault=off`
- active local Ollama model set for OpenClaw should stay lean: `phi4-mini:latest`, `llama3.1:8b`, `qwen2.5-coder:3b`
- `gemma3:4b` is not part of the active OpenClaw local set because the tested Ollama/OpenClaw tool path rejected it
- restart the gateway after `openclaw.json` changes: `openclaw gateway --force`
- skill reload happens from the OpenClaw side without needing a gateway restart after skill sync
- Google provider: use the API-key-backed `google` provider, not `google-gemini-cli`
- keep Telegram disabled unless `TELEGRAM_OPENCLAW_UBUNTU_TOKEN` is actually resolved; do not leave unresolved secret placeholders in active channel config
- do not configure QMD as an OpenClaw MCP; use local CLI instead: `qmd` for admin/read, `qmdr` for important searches
- for shared optimization posture, `.agents/` hygiene, and QMD cleanup rules, load `k-optim` instead of duplicating that maintenance playbook here

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CODEX] | v1.11.0 — recorded the lean local-only OpenClaw defaults derived from the Ubuntu benchmark and removed `gemma3:4b` from the active local set |
| 2026-04-04 | [CODEX] | v1.10.2 — documented the CLI-only QMD policy for OpenClaw and removed the expectation that QMD should stay in `mcporter.json` |
| 2026-04-04 | [CODEX] | v1.10.1 — documented the active local Ollama endpoint/model and the Telegram-token guard needed to keep the gateway healthy |
| [SUMMARY] | — | v1.10.2–v1.0.0: CLI-only QMD policy, compact hook guidance, history pointers, `k-optim` pointer, stale-copy cleanup after renames, hook discovery, workspace-root, provider, approvals, and broader OpenClaw runtime guidance with paths normalized to `$HOME` |
