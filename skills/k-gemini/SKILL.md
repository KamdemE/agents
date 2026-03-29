---
name: agent-runtime-gemini
description: >
  Gemini CLI runtime — Extension system (gemini-extension.json format, ~/Work/AI/gemini_mcps/),
  mandatory env var block for stdio MCPs, settings.json, KG proactivity, token finesse.
  Load when configuring Gemini, managing extensions/MCPs, or debugging Gemini behavior.
license: private
metadata:
  author: KpihX
  version: "2.4.0"
  scope: agent-runtime
  target-agent: gemini
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — Gemini CLI

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Runtime Context

- **Agent home:** `~/.gemini/`
- **Global kernel:** `~/.gemini/GEMINI.md` → `~/.agents/KERNEL.md`
- **Runtime shortcut:** `~/GEMINI.md` → this file
- **Skills path:** natively scans `~/.agents/skills/` (1 level deep — no symlink needed)
- **Settings:** `~/.gemini/settings.json`
- **Temp data:** `~/.gemini/tmp/kpihx/`

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
    *   Create a dedicated directory for your MCP source: `~/Work/AI/gemini_mcps/<name>_mcp/`

2.  **Create Configuration Files:**
    *   Inside the new directory, create a `gemini-extension.json` file defining the server's command.
    *   Optionally, add a `GEMINI.md` file in the same directory for specific rules and documentation for the MCP.

3.  **Add the Server using the CLI:**
    *   Execute the `gemini mcp add` command. This command handles the necessary setup.
    ```bash
    gemini mcp add --scope user <server_name> <command> [args...]
    ```
    *   **Example:** `gemini mcp add --scope user qmd-mcp zsh -l -c "/path/to/qmd mcp"`

4.  **Finalization:**
    *   After the command completes, no further steps like mirroring or manual registration are needed.
    *   Restart Gemini to ensure the new MCP is connected and available.

**Env var mandate (mandatory for stdio MCPs needing secrets):**
Gemini's extension runner is restricted — `bw-env` secrets are NOT auto-inherited from the shell.
Must explicitly declare in `gemini-extension.json`:
```json
"env": { "MY_TOKEN": "$MY_TOKEN", "MY_API_KEY": "$MY_API_KEY" }
```

**Current extension list:** read `~/.gemini/extension-enablement.json` and browse `~/Work/AI/gemini_mcps/` — they are the source of truth.

## Key Rules

- **MCP reload:** Ask KπX to run `/mcp refresh` after any install. Full restart if still fails.
- **Secrets failures:** "Token not available" → restart Gemini from a fresh hot terminal where secrets are confirmed present.
- **Token finesse:** Avoid `full_sync` on TickTick. Prefer scoped tools. Avoid massive directory tree dumps.
- **Sudo:** Authorized when strictly necessary (outside `$HOME`). Never sudo within home dir. 
- **HTTP resilience:** If HTTP MCP fails → ask KπX to reactivate the `-fallback` extension.

## Project Context

When working in a project under `~/Work/`, check for `.agents/AGENTS.md` at the project root.
If found: treat it as project-specific context — architecture rules, stack, evolution rules.
Template: `~/.agents/skills/k-project/templates/AGENTS.md`.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-29 | [CLAUDE] | v2.4.0 — added Project Context section (.agents/AGENTS.md auto-load rule) |
| 2026-03-28 | [CLAUDE] | v2.3.0 — removed redundant edit reminder; broadened description; changelog condensed |
| [SUMMARY] | — | v2.2.0 clarified HTTP vs stdio install; v2.1.0 skills path + dedup; v2.0.0 migrated to skills/ |
