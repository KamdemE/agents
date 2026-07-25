# k-node Insights

## 2026-07-25

- Skill created after comprehensive audit of all Node/npm/bun packages across the KpihX ecosystem.
- npm global (13 packages, 20 binaires) dominates the global tool landscape; bun global is empty (server-filesystem purged).
- fnm is installed with v24.18.0, but nvm v22.22.1 is still the active Node provider. Full migration pending.
- The `~/.npmrc prefix=` pattern is critical for auto-updating tools (Codex, Gemini) — prevents EACCES.
- `whats-mcp` is linked to `~/Work/AI/MCPs/whats_mcp` — dev mode, not a published package.
- Bun is the sovereign choice for KpihX-owned projects; npm global serves third-party CLIs.
- PATH resolution: `~/.bun/bin` → `~/.npm-global/bin` → fnm multishell.
