---
name: k-codex
description: >
  Codex CLI runtime — config.toml (model, sandbox, approvals, trust_level),
  MCP config (TOML syntax), memories/rules/skills system, permissions escalation.
  Load when configuring Codex, adjusting settings, managing MCPs, or debugging behavior.
license: private
metadata:
  author: KpihX
  version: "2.12.0"
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
| `$HOME/.codex/memories/` | Persisted insights from past sessions |
| `$HOME/.codex/rules/default.rules` | Auto-allow prefix_rule patterns (accumulated by Codex) |
| `$HOME/.codex/sessions/` | Session history |
| `$HOME/.codex/history.jsonl` | Conversation/event stream |
| `$HOME/.codex/session_index.jsonl` | Session index |

### Session Storage

Codex stores conversations in two tiers:

- **`$HOME/.codex/history.jsonl`** (767 KB) — lightweight prompt log. Each line: `{"session_id": "<uuid>", "ts": <unix>, "text": "<user prompt>"}`. User messages only.
- **`$HOME/.codex/sessions/YYYY/MM/DD/rollout-<timestamp>-<uuid>.jsonl`** (69 MB total) — full session transcripts. Each line: `{"timestamp": "<iso>", "type": "<event_type>", "payload": {...}}`. Event types include `session_meta` (model, cwd, cli_version, originator), user messages, assistant replies, tool calls, and tool results. Session metadata (id, model_provider, base_instructions) is in the first `session_meta` event.

## Hooks

- **Codex-specific Python hooks (`hooks/codex/`, `session_start.py`, `user_prompt_submit.py`, `stop.py`) were removed 2026-08-09** when the kernel moved to an OpenCode-only hook architecture (see `k-opencode/references/hooks-standard.md`). Codex no longer has dedicated lifecycle hooks in `.agents/` — it still reads the shared `AGENTS.md` kernel via symlink (`$HOME/.codex/AGENTS.md`), but per-turn enforcement/context-injection is now OpenCode-exclusive.
- **`make check`** (`$HOME/.agents/scripts/check_skills/check_skills.py` via `make check-skills`) validates skill structure/content only — it never inspected Codex-specific config or `hooks.json`.
- If Codex-specific hooks are ever needed again, model them after the current `k-opencode/scripts/hooks/*.js` pattern (`TARGET_AGENTS`-style scoping, see `hooks-standard.md`) rather than restoring the old Python wrappers.

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

**Remote HTTP MCP with bearer token from env:**
```toml
[mcp_servers.<name>]
url = "https://example.com/mcp"
bearer_token_env_var = "EXAMPLE_API_KEY"
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

- **Critical shell (`sudo`, SSH passphrase, interactive auth)** → load **`k-tmux`**; use **shared tmux gate** (reuse/create short-named session → `send-keys` → poll pane **≥30s** before chat handoff). **`sui` is deprecated** — never invoke it.
- **Shared tmux gate** → do not end the turn because a password prompt appears before **30s** of polling; only after **≥30s** without validation, give full attach instructions + exact command + what KπX must do.
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

## Optimization (History & Cache)

- **History Logs:** `$HOME/.codex/history.jsonl`, `$HOME/.codex/sessions/`, `$HOME/.codex/archived_sessions/`
- **Internal Storage:** Temporary session states and traces are accumulated in `.sqlite` databases such as `logs_1.sqlite` and `state_5.sqlite`, and shell caches in `tmp/` and `shell_snapshots/`.
- **Rules:** Codex has no built-in cleanup CLI command. Safely execute `rm -rf $HOME/.codex/sessions/* $HOME/.codex/archived_sessions/* $HOME/.codex/history.jsonl $HOME/.codex/log/* $HOME/.codex/*.sqlite* $HOME/.codex/tmp/*` to deeply wipe historical buildup, retaining only the latest/active context when needed.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-codex/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-codex/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-21 | [OPENCODE] | v2.12.0 — Added Session Storage section with history.jsonl and sessions/ format docs. |
| 2026-05-18 | [AUTO] | v2.11.7 — Mandatory shared tmux gate (≥30s poll); `sui` deprecated — aligns with AGENTS + `k-tmux`. |
| [SUMMARY] | — | v2.11.6 Shared-tmux polling; v2.11.5 HTTP MCP bearer_token_env_var; v2.11.4 `$HOME` path cleanup; v2.11.3 `make check` no longer validates Codex `hooks.json` / `codex_hooks`; v2.11.2 insights discipline; v2.11.0 CLI cache/storage paths; older entries kept in file history |
