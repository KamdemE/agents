---
name: k-gemini
description: >
  Gemini CLI runtime — Extension system (gemini-extension.json format, $HOME/Work/AI/gemini_mcps/),
  mandatory env var block for stdio MCPs, settings.json, KG proactivity, token finesse.
  Load when configuring Gemini, managing extensions/MCPs, or debugging Gemini behavior.
license: private
metadata:
  author: KpihX
  version: "2.8.1"
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

- **MCP reload:** Ask KπX to run `/mcp refresh` after any install. Full restart if still fails.
- **Secrets failures:** "Token not available" → restart Gemini from a fresh hot terminal where secrets are confirmed present.
- **Token finesse:** Avoid `full_sync` on TickTick. Prefer scoped tools. Avoid massive directory tree dumps.
- **Sudo:** Authorized when strictly necessary (outside `$HOME`). Never sudo within home dir. 
- **HTTP resilience:** If HTTP MCP fails → ask KπX to reactivate the `-fallback` extension.
- **File display:** When asked to show file content, use `read_file` then explicitly print the content in the chat.
- **No echo:** Do not use `run_shell_command` just to `echo` messages; communicate directly in the chat.

## Hooks

`$HOME/.gemini/settings.json` is also the source of truth for Gemini hook wiring.

- live wrappers: `session_start.py`, `before_agent.py`, `after_agent.py`, `before_tool.py`, `session_end.py`
- exact event mapping and concrete examples live in `$HOME/.agents/hooks/README.md`

## Project Context

When working in a project under `$HOME/Work/`, check for `.agents/AGENTS.md` at the project root.
If found: treat it as project-specific context — architecture rules, stack, evolution rules.
Template: `$HOME/.agents/skills/k-project/assets/AGENTS.md`.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CODEX] | v2.8.1 — removed the qmd-mcp example and documented the CLI-only QMD policy for Gemini (`qmd` for admin/read, `qmdr` for important searches) |
| 2026-04-03 | [CODEX] | v2.8.0 — added the real Gemini conversation-history paths and kept the skill compact by exposing only the owning dirs to inspect |
| [SUMMARY] | — | v2.7.0–v2.0.0: compact hooks section, project-context auto-load, name normalization, HTTP vs stdio install guidance, skills-path behavior, and the original migration into `skills/` |
