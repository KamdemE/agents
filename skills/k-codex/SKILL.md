---
name: k-codex
description: >
  Codex CLI runtime — config.toml (model, sandbox, approvals, trust_level),
  MCP config (TOML syntax), memories/rules/skills system, permissions escalation.
  Load when configuring Codex, adjusting settings, managing MCPs, or debugging behavior.
license: private
metadata:
  author: KpihX
  version: "2.10.2"
  scope: agent-runtime
  target-agent: codex
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — Codex CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Home:** `$HOME/.codex/`
- **Global kernel:** `$HOME/.codex/AGENTS.md` → `$HOME/.agents/AGENTS.md`
- **Skills path:** `$HOME/.codex/skills/` → `$HOME/.agents/skills/` (symlink)
- **Config file:** `$HOME/.codex/config.toml`
- **Logs:** `$HOME/.codex/log/codex-tui.log` — check before bulk troubleshooting

## Key Config Files

| File | Role |
|------|------|
| `$HOME/.codex/config.toml` | Model, behavior (sandbox/approvals/trust), MCPs — **source of truth** |
| `$HOME/.codex/hooks.json` | Deployed hook config — symlink or copy of `$HOME/.agents/hooks/codex/hooks.json` |
| `$HOME/.codex/memories/` | Persisted insights from past sessions |
| `$HOME/.codex/rules/default.rules` | Auto-allow prefix_rule patterns (accumulated by Codex) |
| `$HOME/.codex/sessions/` | Session history |
| `$HOME/.codex/history.jsonl` | Conversation/event stream |
| `$HOME/.codex/session_index.jsonl` | Session index |

## Hooks

- source of truth: `$HOME/.codex/hooks.json` and `$HOME/.agents/hooks/codex/`
- required runtime flag: `features.codex_hooks = true` in `$HOME/.codex/config.toml`
- live wrappers: `session_start.py`, `user_prompt_submit.py`, `stop.py`
- Codex-specific JSON envelope details live in `$HOME/.agents/hooks/README.md`
- `.agents/` write guards are intentionally not wired on Codex in this setup; `pre_tool_use.py` exists only as a compatibility shim

## MCP Config Format (Codex — TOML)

```toml
[mcp_servers.<name>]
command = "/absolute/path/to/binary"
args = ["serve"]
cwd = "$HOME"
```

**Login shell wrapper (secrets):**
```toml
[mcp_servers.<name>]
command = "zsh"
args = ["-l", "-c", "/path/to/binary serve"]
```

**GUI-dependent MCPs (bw-mcp with zenity):** Inject display vars:
```toml
[mcp_servers.bw_mcp.env]
DISPLAY = "$DISPLAY"
DBUS_SESSION_BUS_ADDRESS = "$DBUS_SESSION_BUS_ADDRESS"
XDG_RUNTIME_DIR = "$XDG_RUNTIME_DIR"
WAYLAND_DISPLAY = "$WAYLAND_DISPLAY"
XAUTHORITY = "$XAUTHORITY"
```
**WARNING:** Do NOT add `[mcp_servers.<name>.env]` blocks by default — can break Codex startup.

Do not enumerate MCPs here; read `$HOME/.codex/config.toml` directly.

## Permissions & Escalation

- **Sudo required** → STOP before retry loop; ask KπX to run the command manually; then resume.
- if sandbox restrictions block a legitimate Codex maintenance action (for example `.agents` commit/push or a repo push), rerun the exact command with scoped escalation instead of inventing shell workarounds
- for Git/network maintenance, prefer a narrow `prefix_rule` tied to the real command family (`git ... push`, `git ... commit`, `make -C $HOME/.agents push`) so the approval stays reusable but bounded
- when an escalated command fails because it still needs user authentication or a manual step, stop there; tell KπX exactly what to run/fix, then continue once KπX says it is done
- **rules/default.rules** — prefix_rule patterns auto-accumulated by Codex. Edit directly to remove stale entries.

## Project Context

When working in a project under `$HOME/Work/`, check for `.agents/AGENTS.md` at the project root.
If found: treat it as project-specific context — architecture rules, stack, evolution rules.
Template: `$HOME/.agents/skills/k-project/assets/AGENTS.md`.

## Maintenance Reflex

- for `.agents/` hygiene, QMD cleanliness, or optimization/cleanup posture, load `k-optim`
- keep runtime-specific details here, but do not duplicate the cross-cutting maintenance playbook that now lives in `k-optim`
- after editing any `SKILL.md`, re-read the full YAML frontmatter before commit; if the edit touched the header, validate indentation and keys explicitly before pushing
- never reindent an existing frontmatter key while patching a version line; in `metadata:`, sibling keys must stay aligned exactly

Correct:
```yaml
metadata:
  author: KpihX
  version: "2.10.2"
  scope: agent-runtime
  target-agent: codex
```

Incorrect:
```yaml
metadata:
  author: KpihX
    version: "2.10.2"
  scope: agent-runtime
  target-agent: codex
```

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CODEX] | v2.10.2 — added explicit correct/incorrect frontmatter examples and the rule to never reindent existing `metadata` child keys while patching a skill version line |
| 2026-04-04 | [CODEX] | v2.10.1 — added the frontmatter safety reflex: after editing any `SKILL.md`, Codex must re-read and validate the YAML header before commit, especially when top-of-file metadata was patched |
| [SUMMARY] | — | v2.10.0–v2.0.0: sandbox/escalation reflex, explicit history pointers, delayed finalization reminder, lighter per-turn reminder, Codex payload contract, maintenance routing to `k-optim`, hook wiring, path normalization, project-context auto-load, config anatomy, memories/rules, and the initial runtime baseline |
