---
name: agent-runtime-gemini
description: >
  Gemini CLI runtime — Extension system (gemini-extension.json format, ~/Work/AI/gemini_mcps/),
  mandatory env var block for stdio MCPs, KG proactivity rules, token finesse, installed
  extensions table. Load when installing or configuring MCPs for Gemini.
license: private
metadata:
  author: KpihX
  version: "2.0.0"
  scope: agent-runtime
  target-agent: gemini
allowed-tools: Bash, Read, Write, Edit
---

# Agent Runtime — Gemini CLI

## Runtime Context

- **Agent home:** `~/.gemini/`
- **Global kernel:** `~/.gemini/GEMINI.md` → `~/.agents/KERNEL.md`
- **Runtime shortcut:** `~/GEMINI.md` → this file
- **Skills path:** `~/.gemini/skills/` → `~/.agents/skills/` (symlink)
- **Settings:** `~/.gemini/settings.json`
- **Temp data:** `~/.gemini/tmp/kpihx/`

## Extension System (Gemini-specific)

Gemini CLI installs MCPs as **Extensions** — NOT via a JSON config file.

**Install procedure for any MCP:**
1. Create `~/Work/AI/gemini_mcps/<name>_mcp/` (for ALL extensions, KpihX-owned or external)
2. Create `gemini-extension.json`:
   ```json
   {
     "name": "<name>",
     "version": "1.0.0",
     "description": "...",
     "mcpServers": {
       "<server>": {
         "command": "/path/to/binary",
         "args": ["serve"]
       }
     }
   }
   ```
   **CRITICAL:** `"version"` field is mandatory — its absence silently blocks installation.
3. Mirror directory to `~/.gemini/extensions/<name>/`
4. Register in `extension-enablement.json`

**Env var mandate (mandatory for stdio MCPs needing secrets):**
Gemini's extension runner is restricted — `bw-env` secrets are NOT auto-inherited from the shell.
Must explicitly declare in `gemini-extension.json`:
```json
"env": { "MY_TOKEN": "$MY_TOKEN", "MY_API_KEY": "$MY_API_KEY" }
```

## Installed Extensions

| Extension | Transport | Source | Notes |
|-----------|-----------|--------|-------|
| `bw-mcp` | stdio | `~/Work/AI/gemini_mcps/bw_mcp/` | v1.7.1 |
| `tick-mcp` | HTTP | `~/Work/AI/gemini_mcps/tick_mcp/` | Primary |
| `tick-mcp-fallback` | stdio | `~/Work/AI/gemini_mcps/tick_mcp_fallback/` | login-shell + explicit env |
| `whats-mcp` | HTTP | `~/Work/AI/gemini_mcps/whats_mcp/` | Primary |
| `whats-mcp-fallback` | stdio | `~/Work/AI/gemini_mcps/whats_mcp_fallback/` | direct binary |
| `desk-mcp` | stdio | `~/Work/AI/gemini_mcps/desk_mcp/` | XDG screenshot + xdotool |
| `seq-mcp` | stdio | `~/Work/AI/gemini_mcps/seq_mcp/` | Sequential reasoning |
| `puppeteer-mcp` | stdio | `~/Work/AI/gemini_mcps/puppeteer_mcp/` | Edge-compatible |
| `graph-mcp` | stdio | `~/Work/AI/gemini_mcps/graph_mcp/` | Knowledge Graph |
| `rag-mcp` | stdio | `~/Work/AI/gemini_mcps/rag_mcp/` | Hybrid local RAG |
| `mail-mcp` | HTTP | `~/Work/AI/gemini_mcps/mail_mcp/` | Primary |
| `mail-mcp-fallback` | stdio | `~/Work/AI/gemini_mcps/mail_mcp_fallback/` | zsh -l -c + explicit env |

## Key Rules

- **MCP reload:** Ask KπX to run `/mcp refresh` after any install. Full restart if still fails.
- **Secrets failures:** "Token not available" → restart Gemini from a fresh hot terminal where secrets are confirmed present.
- **KG proactivity:** Query Knowledge Graph (`read_graph`, `search_nodes`) at start of complex tasks.
- **Token finesse:** Avoid `full_sync` on TickTick. Prefer scoped tools. Avoid massive directory tree dumps.
- **File targeting:** "Ajuste AGENT" → `~/.agents/KERNEL.md` · "Ajuste gemini" → this file.
- **Sudo:** Authorized when strictly necessary (outside `/home/kpihx`). Never sudo within home dir.
- **HTTP resilience:** If HTTP MCP fails → ask KπX to reactivate the `-fallback` extension.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-03-25 | [CLAUDE] | v2.0.0 — refonte: migrated to skills/agents/gemini/, symlinks updated |
| [SUMMARY] | — | Prior: GEMINI.md creation, 12 extensions installed, KG + RAG indexed on Homelab docs |
