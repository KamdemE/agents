---
name: k-openclaw
description: >
  OpenClaw runtime — workspace root, skills sync (rsync copies — NOT symlinks),
  exec-approvals (ask=always), Key config files, CLI patterns.
  Load when configuring OpenClaw, managing skills, approvals, or debugging behavior.
license: private
metadata:
  author: KpihX
  version: "1.6.0"
  scope: agent-runtime
  target-agent: openclaw
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — OpenClaw

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Agent home:** `$HOME/.openclaw/`
- **Workspace root:** `$HOME/.openclaw/workspace/` — security boundary; paths outside root are rejected
- **Global kernel:** `$HOME/.openclaw/workspace/AGENTS.md` → `$HOME/.agents/AGENTS.md`
- **Skills path:** `$HOME/.openclaw/workspace/skills/` — **real copies** rsynced from `$HOME/.agents/skills/` (post-commit hook)
  - ⚠️ NOT symlinks — OpenClaw resolves symlinks before its root check and rejects out-of-root paths
  - To refresh manually: `rsync -a --delete $HOME/.agents/skills/<name>/ $HOME/.openclaw/workspace/skills/<name>/`

## Directory Layout

```
$HOME/.openclaw/
├── openclaw.json              ← MAIN CONFIG (models, auth, channels, plugins, gateway, skills, hooks)
├── exec-approvals.json        ← exec approval gates (policy + ask defaults per agent)
├── agents/
│   └── main/
│       └── sessions/          ← conversation session store
├── canvas/                    ← Control UI static assets
└── workspace/                 ← security root (all agent file access bounded here)
    ├── AGENTS.md              ← symlink → $HOME/.agents/AGENTS.md (global kernel)
    ├── skills/                ← rsync copies from $HOME/.agents/skills/ (NOT symlinks)
    └── config/
        └── mcporter.json      ← MCP server definitions (stdio + HTTP, with headers for auth)
```

## Key Config Files

| File | Role |
|------|------|
| `$HOME/.openclaw/openclaw.json` | Models, auth profiles, providers, channels, plugins, gateway, skills entries, hooks |
| `$HOME/.openclaw/exec-approvals.json` | Exec approval gates — `policy` + `ask` defaults per agent |
| `$HOME/.openclaw/workspace/config/mcporter.json` | MCP servers — use `"headers": {"x-api-key": "${ENV_VAR}"}` for HTTP auth |
| `$HOME/.openclaw/workspace/AGENTS.md` | Kernel symlink (→ `$HOME/.agents/AGENTS.md`) |

## Hooks

OpenClaw discovers managed hooks from `$HOME/.agents/hooks/openclaw/`, with runtime enablement in `$HOME/.openclaw/openclaw.json`.

| Hook dir | Runtime role |
|---------|--------------|
| `context-injector/` | startup context via `agent:bootstrap` |
| `path-guard/` | advisory `.agents/` path reminder via `message:sent` |
| `session-guard/` | advisory dirty-repo reminder via `command:stop` |

- `hooks.internal.load.extraDirs` must include `$HOME/.agents/hooks/openclaw`
- each hook dir must contain both `HOOK.md` and `handler.ts`
- `HOOK.md` frontmatter uses `metadata.openclaw.events`
- OpenClaw hooks are advisory in the current setup; there is no equivalent hard-blocking `BeforeTool` gate here yet

## Exec Approvals (Shell Command Gates)

Current config: `policy=full`, `ask=always` — OpenClaw asks for approval before every bash command.

**Approval channels:** Telegram `/approve <id>`, Control UI at `kpihx-ubuntu.tail2527bd.ts.net`, or gateway TUI.

To adjust: edit `$HOME/.openclaw/exec-approvals.json` then push live with:
```bash
openclaw approvals set --file $HOME/.openclaw/exec-approvals.json
```

**Policy options:** `full` (run after approval) · `allowlist` (block unless listed) · `deny` (always block)
**Ask options:** `always` · `on-miss` (ask only if not allowlisted) · `off`

To allowlist a safe binary pattern: `openclaw approvals allowlist add "$HOME/path/to/bin"`

## Key Rules

- **Gateway restart** required after `openclaw.json` changes (model, tools, workspace) → `openclaw gateway --force`
- **Skills reload** happens on `/skill` command — no gateway restart needed after rsync
- **Workspace root** — never set workspace to `$HOME/` (too broad); keep at `$HOME/.openclaw/workspace/`
- **Secrets:** use `${ENV_VAR_NAME}` syntax in `openclaw.json` values — OpenClaw resolves at runtime via `bw-env`
- **Gateway auth token** (`gateway.auth.token`) — static bearer generated at `openclaw onboard`/`setup`. Required for Control UI, Tailscale, HTTP clients. Do NOT delete it.
- **MCP config** — `$HOME/.openclaw/workspace/config/mcporter.json` — separate from `openclaw.json`. Exa is MCP HTTP (`https://mcp.exa.ai/mcp`) there; `plugins.entries.exa` in `openclaw.json` is the inline web search integration (both coexist).

## Google Provider — ⚠️ Ban Risk

OpenClaw has two Google providers:

| Provider | Auth | Endpoint | Risk |
|----------|------|----------|------|
| `google` | API key (`GEMINI_API_KEY` or `GOOGLE_API_KEY`) | `generativelanguage.googleapis.com` | ✅ Safe |
| `google-gemini-cli` | PKCE OAuth (piggybacks Gemini CLI client) | `cloudcode-pa.googleapis.com` | 🔴 **Ban risk** — Google actively bans accounts |

**Always use `google` (API key).** Never use `google-gemini-cli` OAuth — it violates Google ToS.

Auth profile format (in `openclaw.json`):
```json
"google:default": { "provider": "google", "mode": "api_key" }
```
OpenClaw reads the API key automatically from `GEMINI_API_KEY` or `GOOGLE_API_KEY` env var — no key in config needed.

Model refs use `google/gemini-xxx` (not `google-gemini-cli/gemini-xxx`).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CODEX] | v1.6.0 — documented the managed OpenClaw hook discovery model, the required `metadata.openclaw.events` HOOK.md format, and the live `openclaw.json` enablement points |
| 2026-04-03 | [CODEX] | v1.5.2 — normalized remaining paths to `$HOME` without changing the OpenClaw runtime guidance |
| [SUMMARY] | — | v1.5.1 standardized name to `k-openclaw`; v1.5.0 Directory Layout tree plus `mcporter.json` and provider additions; v1.4.0 Key Rules (`--force`, token, Exa); v1.3.0 Google ban risk; v1.2.0 rsync copies + exec-approvals; v1.1.0–v1.0.0 init history |
