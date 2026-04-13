# Central MCP Synchronization Vision

## Objective
Avoid configuring MCP servers repeatedly across multiple agent providers (Gemini, Claude Code, Codex, Vibe, Cursor/Roo-Cline). 

## Why MCPorter isn't the silver bullet
MCPorter is a CLI tool used by OpenClaw to handle MCP transport. While it's great for agents that don't have built-in MCP clients, major platforms (Claude, Cursor, Gemini) have their own native transport implementations (in Rust, TS, Go) and enforce their specific configuration files (JSON, TOML, SQLite). They will not delegate to `mcporter`.

## The KπX Architectural Solution
Instead of forcing a shared transport proxy, we use a **Config-as-Code Centralization** pattern:
1. **Source of Truth:** A central registry file at `~/.agents/mcp-registry.yaml`.
2. **Synchronization Engine:** A script `sync-mcps.py` (which could be encapsulated in a `k-mcp` skill).
3. **Distribution Map:**
   - **Claude Code:** Translates YAML block to `~/.claude.json`.
   - **Gemini:** Translates to `~/.gemini/gemini-extension.json` & updates enablement.
   - **Codex:** Appends to the `[mcp_servers]` block in `~/.codex/config.toml`.
   - **Vibe:** Updates `~/.vibe/config.toml`.
   - **Cursor / VS Code (Cline):** Injects into `~/.cursor/mcp.json` or `~/.config/Code/User/globalStorage/rooveterinaryinc.roo-cline/cline_mcp_settings.json`.

## Flow
When a new MCP is discovered, KπX tests it.
If kept, it is added to `mcp-registry.yaml`.
KπX runs `make sync-mcps` (or `k-mcp sync`).
All active agents immediately possess the tool.
