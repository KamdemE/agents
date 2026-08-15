# k-clis — Purged CLIs (Archive)

> **Purpose:** CLI tools that were installed and later **purged** (agent runtimes). Kept for the historical record — never deleted (GRAVÉ). Purge date: 2026-08-14, per KπX directive to remove agent CLI runtimes and keep only active CLIs.

## Purged 2026-08-14

| CLI | Skill | Also in | Notes |
|-----|-------|---------|-------|
| `cursor-agent` (CLI) | `k-code` | `k-ai` | Cursor CLI (agent) purgé 2026-08-14 — voir `k-ai/references/purged.md` ; l'IDE `/usr/bin/cursor` est conservé (dpkg `cursor` 3.14.7). |
| `codex` | `k-codex` (deactive) | `k-ai` | Codex — config.toml, sandbox, MCP TOML format. Purged; skill moved to `skills/deactive/`. |
| `cline` | `k-cline` (deactive) | `k-ai` | Cline — install/update, MCP settings. Purged; skill moved to `skills/deactive/`. |
| `gemini` | `k-gemini` (deactive) | `k-ai` | Gemini — extensions, MCP install, settings.json. Purged; skill moved to `skills/deactive/`. |
| `vibe` | `k-vibe` (deactive) | `k-ai` | VIBE — config.toml, TOML MCP, tool permissions. Purged; skill moved to `skills/deactive/`. |
| `copilot` | `k-copilot` (deactive) | `k-ai` | GitHub Copilot — mcp-config, instructions. Purged; skill moved to `skills/deactive/`. |
| `zed` | `k-zed` (deactive) | `k-ai` | Zed agent hub — profiles, MCP, ACP bridges. Purged; skill moved to `skills/deactive/`. |

## Purged 2026-08-14 (second wave)

| CLI | Skill | Notes |
|-----|-------|-------|
| `asciinema` | _(this skill)_ | Terminal recording (uv tool v2.4.0). Purged 2026-08-14 per KπX directive; removed from live `k-clis` Media/AI table. Archived here (GRAVÉ). |

> Related: `k-uv/references/purged.md` (uv tool purges) · `k-node/references/purged.md` (npm-global purges) · `k-ai` (purged runtimes note).
