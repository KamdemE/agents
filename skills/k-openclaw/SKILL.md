---
name: k-openclaw
description: >
  OpenClaw runtime — workspace root, managed skills sync, exec approvals, core config files,
  and hook integration points. Load when configuring OpenClaw, managing skills/approvals,
  or debugging runtime behavior.
license: private
metadata:
  author: KpihX
  version: "1.7.1"
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

| Hook dir | Runtime role |
|---------|--------------|
| `context-injector/` | startup context via `agent:bootstrap` |
| `path-guard/` | advisory `.agents/` path reminder via `message:sent` |
| `session-guard/` | advisory dirty-repo reminder via `command:stop` |

- `hooks.internal.load.extraDirs` must include `$HOME/.agents/hooks/openclaw`
- each hook dir must contain both `HOOK.md` and `handler.ts`
- `HOOK.md` frontmatter uses `metadata.openclaw.events`
- these hooks are advisory in the current OpenClaw lifecycle surface

## Exec Approvals

- current policy is defined in `$HOME/.openclaw/exec-approvals.json`
- apply changes with:

```bash
openclaw approvals set --file $HOME/.openclaw/exec-approvals.json
```

- use allowlists only for genuinely safe repeat patterns

## Operational Notes

- restart the gateway after `openclaw.json` changes: `openclaw gateway --force`
- skill reload happens from the OpenClaw side without needing a gateway restart after skill sync
- Google provider: use the API-key-backed `google` provider, not `google-gemini-cli`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v1.7.1 — documented that skill renames require explicit stale-copy cleanup in the OpenClaw workspace to avoid duplicate indexing and runtime drift |
| 2026-04-03 | [CODEX] | v1.7.0 — rewrote the skill into a compact source-of-truth map, kept the OpenClaw-specific root/sync/hook rules, and removed the large inline layout/config snapshot in favor of direct pointers to the real runtime files |
| [SUMMARY] | — | v1.6.0–v1.0.0 documented hook discovery, workspace-root, provider, approvals, rename, and MCP/runtime guidance, with paths normalized to `$HOME` |
