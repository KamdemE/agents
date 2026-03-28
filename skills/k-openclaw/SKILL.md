---
name: agent-runtime-openclaw
description: >
  OpenClaw runtime — workspace root, skills sync (rsync copies — NOT symlinks),
  exec-approvals (ask=always), Key config files, CLI patterns.
  Load when configuring OpenClaw, managing skills, approvals, or debugging behavior.
license: private
metadata:
  author: KpihX
  version: "1.2.0"
  scope: agent-runtime
  target-agent: openclaw
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — OpenClaw

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Agent home:** `~/.openclaw/`
- **Workspace root:** `~/.openclaw/workspace/` — security boundary; paths outside root are rejected
- **Global kernel:** `~/.openclaw/workspace/AGENTS.md` → `~/.agents/KERNEL.md`
- **Skills path:** `~/.openclaw/workspace/skills/` — **real copies** rsynced from `~/.agents/skills/` (post-commit hook)
  - ⚠️ NOT symlinks — OpenClaw resolves symlinks before its root check and rejects out-of-root paths
  - To refresh manually: `rsync -a --delete ~/.agents/skills/<name>/ ~/.openclaw/workspace/skills/<name>/`

## Key Config Files

| File | Role |
|------|------|
| `~/.openclaw/openclaw.json` | Main config — models, providers, tools.allow, agents.defaults (workspace, compaction, thinkingDefault) |
| `~/.openclaw/exec-approvals.json` | Exec approval gates — `policy` + `ask` defaults per agent |
| `~/.openclaw/workspace/AGENTS.md` | Kernel symlink (→ `~/.agents/KERNEL.md`) |

## Exec Approvals (Shell Command Gates)

Current config: `policy=full`, `ask=always` — OpenClaw asks for approval before every bash command.

**Approval channels:** Telegram `/approve <id>`, Control UI at `kpihx-ubuntu.tail2527bd.ts.net`, or gateway TUI.

To adjust: edit `~/.openclaw/exec-approvals.json` then push live with:
```bash
openclaw approvals set --file ~/.openclaw/exec-approvals.json
```

**Policy options:** `full` (run after approval) · `allowlist` (block unless listed) · `deny` (always block)
**Ask options:** `always` · `on-miss` (ask only if not allowlisted) · `off`

To allowlist a safe binary pattern: `openclaw approvals allowlist add "~/path/to/bin"`

## Key Rules

- **Gateway restart** required after `openclaw.json` changes (model, tools, workspace)
- **Skills reload** happens on `/skill` command — no gateway restart needed after rsync
- **Workspace root** — never set workspace to `~/` (too broad); keep at `~/.openclaw/workspace/`
- **Secrets:** injected via `bw-env`; Telegram bot token + gateway auth in `openclaw.json`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-28 | [CLAUDE] | v1.2.0 — skills path: symlinks → rsync copies (workspace root fix); exec-approvals configured (ask=always); Key Config Files table; CLI patterns |
| [SUMMARY] | — | v1.0.0 initialized; v1.1.0 ⚠️ + config table added |
