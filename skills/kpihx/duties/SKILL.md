---
name: kpihx-duties
description: Mandatory behavioral rules for all agents in the KπX workspace. Load at every session alongside kpihx/soul. Covers tool discipline, security, MCP protocol, changelog rules, and TODO system.
license: private
metadata:
  author: KpihX
  version: "2.0.0"
allowed-tools: "*"
---

# KπX — Agent Duties

## Core Rules

- **Language:** All files in `~/.agents/` → English only. French only as literal quoted strings.
- **Tool discipline:** NEVER use `sed`/`printf`/shell redirections for file edits. Always: Read → Edit. Write only for new files.
- **No sensitive data:** No real IPs, tokens, full legal names in docs. Use placeholders.
- **Security check:** When inspecting env vars/tokens → list key **names only**, never values: `env | grep -E "API|TOKEN" | cut -d= -f1`
- **Project scope:** `~/` is not a project root. All projects live in `~/Work/`.

## TODO System

- TODOs are centralized in `~/.agents/memory/context.md` (HOT tier)
- Only KπX adds TODO entries. Agents execute + remove them.
- At every response end: remind KπX of any open TODOs.
- Stop hook enforces daily update of `context.md` + `dailylog.md`.

## Agent Behavior Mandates

- **Changelog order:** Always newest-first. Max 10 entries in `dailylog.md` — condense oldest into one `[SUMMARY]` row. SKILL.md changelogs: max 3 entries + [SUMMARY].
- **Context save gate:** Propose saves → WAIT for explicit KπX approval before writing to KERNEL.md or any skill.
- **Kernel sync:** After any `~/.agents/` modification → propose `git commit` + push to all remotes.
- **Post-write verification:** After every file write → read back to confirm final state.
- **MCP fallback rule:** If any HTTP MCP fails → immediately suggest its `--fallback` stdio counterpart.
- **tutos_live trigger:** Any new tool installed or non-trivial system fix → propose adding to `~/Work/tutos_live/`.

## Tool Memory Protocol (mandatory)

**BEFORE** using any tool MCP → load the corresponding skill if not already in context:

| MCP | Skill to load |
|-----|---------------|
| `whats-mcp` / `whats-mcp--fallback` | `kpihx/whatsapp` |
| `mail-mcp` / `mail-mcp--fallback` | `kpihx/mail` |
| `linkedin-mcp` / `linkedin-mcp--fallback` | `kpihx/linkedin` |
| `tick-mcp` / `tick-mcp--fallback` | `kpihx/ticktick` |

**AFTER** each use → append a timestamped `[AGENT]` entry to the skill's `## Changelog` section.

## Security Posture

- Git: **SSH only**. Remotes named `github` / `gitlab`. Never HTTPS.
- Secrets: managed via **Vaultwarden** + injected to RAM via `bw-env`. Never hardcode or commit.
- `~/.zshenv` does **NOT** source `~/.kshrc` (fires in untrusted script contexts — deliberate).
- MCP secrets injection: always wrap binary with `zsh -l -c "<binary> serve"`.
- `bw-env` guard: `BW_ENV_LOADED=$$` (PID-scoped — child processes always reload secrets).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-25 | [CLAUDE] | v2.0.0 — refonte: ~/.agents/ refs, new TODO system, new skill names |
| 2026-03-25 | [CLAUDE] | v1.0.0 — initial creation in skills/kpihx-duties/ |
