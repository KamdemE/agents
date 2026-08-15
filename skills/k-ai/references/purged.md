# k-ai — Purged AI Runtimes (Archive)

> **Purpose:** AI runtimes that were installed and later **purged** from the workstation. Kept for the historical record — never deleted (GRAVÉ). Purge date: 2026-08-14, per KπX directive (agent CLI purge; only `*-proxy` CLIs kept). This file keeps the purge details OUT of the compact `k-ai/SKILL.md`.

## Purged 2026-08-14

| Runtime | Config (supprimé) | Skill (déplacé) | Notes |
|---------|-------------------|-----------------|-------|
| **AGY (Antigravity)** | `~/.agy/`, `~/.config/Antigravity/`, `~/.antigravity*`, `~/.cache/antigravity`, `~/.local/share/antigravity-*`, `~/.local/bin/agy*` | `k-ai` (registre) | bins + dirs + caches + launchers purgés ; apt keyring/source désactivés |
| **Codex** | `~/.codex/` (config.toml, sessions, logs) | `deactive/k-codex` | npm `@openai/codex` purgé ; résidu `~/.codex` post-purge trouvé via plocate et purgé |
| **Gemini** | `~/.gemini/` (settings.json, sessions) | `deactive/k-gemini` | npm `@google/gemini-cli` purgé |
| **Copilot CLI** | `~/.copilot/`, `~/.config/github-copilot/` | `deactive/k-copilot` | npm `@github/copilot` purgé |
| **VIBE (Mistral)** | `~/.vibe/` (config.toml, logs) | `deactive/k-vibe` | uv tool `mistral-vibe` (vibe, vibe-acp) purgé |
| **Cline** | `~/.cline/` | `deactive/k-cline` | npm `cline` purgé |
| **Zed** | `~/.config/zed/`, `~/.local/zed.app`, `~/.local/share/zed`, `~/.local/bin/zed` | `deactive/k-zed` | éditeur purgé |
| **Cursor CLI (`cursor-agent`)** | `~/.local/bin/cursor-agent`, `~/.local/bin/agent`, `~/.local/bin/cursor` (shim), `~/.local/share/cursor-agent/`, `~/.config/Cursor/User/globalStorage/anysphere.cursor-agent-worker/agent-cli/` (1.3G) | `k-code` (ref) | **IDE `/usr/bin/cursor` (dpkg 3.14.7) CONSERVÉ** — seul le CLI est purgé |
| **Continue** | `~/.continue/` (config.yaml, config.ts, dev_data) + extension residuals (`~/.config/{Code,Cursor,Antigravity}/User/globalStorage/continue.continue` ×3, `~/.vscode/extensions/continue.continue-2.0.0-linux-x64`) | — | extension VS Code purgée totalement |

## MCP servers purgés 2026-08-14

| MCP | Install | Remplacé par |
|-----|---------|--------------|
| `desk-mcp` | uv tool | — |
| `mail-mcp` / `k-mail-mcp` | uv tools | `mail-proxy` |
| `tick-mcp` | uv tool | `tick-proxy` |
| `ticktick-mcp` | npx cache | `tick-proxy` |
| `whats-mcp` | npm | `whats-proxy` |
| `linkedin-mcp` | (remote HTTP retiré) | k-x / k-meta CLIs |

> Related: `k-uv/references/purged.md` (uv tool purges) · `k-node/references/purged.md` (npm purges) · `k-clis/references/purged.md` (CLI purges) · `k-code` (Zed/AGY/Cursor refs).
