---
name: k-gemini
description: >
  Gemini CLI runtime — Extension system (gemini-extension.json format, $HOME/Work/AI/gemini_mcps/),
  mandatory env var block for stdio MCPs, settings.json, KG proactivity, token finesse.
  Load when configuring Gemini, managing extensions/MCPs, or debugging Gemini behavior.
license: private
metadata:
  author: KpihX
  version: "2.11.0"
  scope: agent-runtime
  target-agent: gemini
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — Gemini CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Agent home:** `$HOME/.gemini/`
- **Global kernel:** `$HOME/.gemini/GEMINI.md` → `$HOME/.agents/AGENTS.md`
- **Runtime shortcut:** `$HOME/GEMINI.md` → this file
- **Skills path:** natively scans `$HOME/.agents/skills/` (1 level deep — no symlink needed)
- **Settings:** `$HOME/.gemini/settings.json`
- **Temp data:** `$HOME/.gemini/tmp/kpihx/`

## History

- **Workspace history roots:** `$HOME/.gemini/history/`
- **Conversation cache:** `$HOME/.gemini/tmp/kpihx/chats/`
- **Antigravity conversations:** `$HOME/.gemini/antigravity/conversations/`

## MCP Server Installation

There are two distinct procedures for installing an MCP server, depending on whether it's a remote HTTP server or a local Stdio server.

**Procedure for HTTP Servers:**

This is a direct, single-step process.

1.  **Add the server using the CLI:**
    ```bash
    gemini mcp add --scope user --transport http <server_name> <url>
    ```

**Procedure for Stdio Servers:**

This involves creating a standard project structure first.

1.  **Create the MCP Project Directory:**
    *   Create a dedicated directory for your MCP source: `$HOME/Work/AI/gemini_mcps/<name>_mcp/`

2.  **Create Configuration Files:**
    *   Inside the new directory, create a `gemini-extension.json` file defining the server's command.
    *   Optionally, add a `GEMINI.md` file in the same directory for specific rules and documentation for the MCP.

3.  **Add the Server using the CLI:**
    *   Execute the `gemini mcp add` command. This command handles the necessary setup.
    ```bash
    gemini mcp add --scope user <server_name> <command> [args...]
    ```

4.  **Finalization:**
    *   After the command completes, no further steps like mirroring or manual registration are needed.
    *   Restart Gemini to ensure the new MCP is connected and available.

**Antigravity (AGY) MCPs:**
For installing MCPs specifically for the Antigravity (AGY) agent, the process is entirely different and relies on modifying a JSON config. See `$HOME/.agents/skills/k-code/references/mcp/agy.md` for full instructions.

**Env var mandate (mandatory for stdio MCPs needing secrets):**
Gemini's extension runner is restricted — `bw-env` secrets are NOT auto-inherited from the shell.
Must explicitly declare in `gemini-extension.json`:
```json
"env": { "MY_TOKEN": "$MY_TOKEN", "MY_API_KEY": "$MY_API_KEY" }
```

Do not enumerate extensions here; read `$HOME/.gemini/extension-enablement.json` and browse `$HOME/Work/AI/gemini_mcps/`.

QMD policy: do not configure QMD as a Gemini MCP. Use local CLI directly:
- `qmd status`, `qmd get`, `qmd embed` for admin/read paths
- `qmdr query/search/vsearch ...` for important searches needing freshness guarantees

## Key Rules

- **AUTH BLOCKS (mandatory):** If an MCP (WhatsApp, Mail, etc.) reports a connection or authentication failure (e.g., "WhatsApp is not connected", "Token expired"), you MUST **STOP immediately**. Do not attempt browser-based workarounds or complex hacks to bypass the auth block. Report the failure, advise the user on the reconnection steps (e.g., "scan QR code"), and wait for an explicit "continue" or "proceed" signal.
- **MCP reload:** Ask KπX to run `/mcp refresh` after any install. Full restart if still fails.
- **Secrets failures:** "Token not available" → restart Gemini from a fresh hot terminal where secrets are confirmed present.
- **Token finesse:** Avoid `full_sync` on TickTick. Prefer scoped tools. Avoid massive directory tree dumps.
- **Privilege gate:** Use `sui -r "..."` when strictly necessary outside `$HOME`; never invoke raw `sudo`, and never elevate inside `$HOME`.
- **HTTP resilience:** If HTTP MCP fails → ask KπX to reactivate the `-fallback` extension.
- **File display:** When asked to show file content, use `read_file` then explicitly print the content in the chat.
- **No echo:** Do not use `run_shell_command` just to `echo` messages; communicate directly in the chat.
- **Edit Stability (ENOSPC):** If `replace_file_content` or `write_to_file` hangs or loops indefinitely, check `fs.inotify.max_user_watches` and ensure global watcher exclusions are set in `$HOME/.config/Code/User/settings.json`. Refer to `k-code/references/agy.md` for the full debug procedure.

## Hooks

`$HOME/.gemini/settings.json` is also the source of truth for Gemini hook wiring.

- live wrappers: `session_start.py`, `before_agent.py`, `after_agent.py`, `before_tool.py`, `session_end.py`
- exact event mapping and concrete examples live in `$HOME/.agents/hooks/README.md`

## Project Context

When working in a project under `$HOME/Work/`, check for `.agents/AGENTS.md` at the project root.
If found: treat it as project-specific context — architecture rules, stack, evolution rules.
Template: `$HOME/.agents/skills/k-project/assets/AGENTS.md`.

## Optimization (History & Cache)

- **Session History:** `$HOME/.gemini/antigravity/brain/<uuid>/`
- **Internal Storage:** Each UUID folder stores `.system_generated/`, `media__*.png`, `tempMediaStorage`, et al.
- **Rules:** Use `gemini --delete-session <index>` to selectively prune, or safely wipe `$HOME/.gemini/antigravity/brain/*` as a brute-force memory reset for stale runs. No persistent graph relies on these raw files.

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-gemini/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-gemini/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-20 | [ANTIGRAVITY] | v2.11.0 — Added mandatory **AUTH BLOCKS** stop rule: agents must cease work and wait for user intervention on any MCP connection/auth failure. |
| 2026-04-18 | [CODEX] | v2.10.6 — Replaced the stale raw-`sudo` runtime note with the kernel-wide `sui -r` privilege rule. |
| [SUMMARY] | — | v2.10.5 watchers fix; v2.10.4 insights; v2.10.3 compaction; +2 older changelog entries kept in file history |
