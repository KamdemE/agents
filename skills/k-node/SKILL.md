---
name: k-node
description: >
  KπX Node.js/TypeScript ecosystem — comprehensive inventory of Node versions,
  npm global packages, bun runtime, fnm version management, and the governance
  patterns governing JS/TS operations. Load before any Node install, npm global
  management, bun usage, or JS/TS environment debugging.
metadata:
  author: KpihX
  version: "1.0.0"
  scope: operations
---

# KπX — Node/JS/TS Ecosystem

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Related rules:**
> - `rules/audit-commands.md` — `uv` not `pip`, `bun` over `npm` for KpihX-owned projects.
> - `rules/file-governance.md` — Single source of truth, `.agents/` centralization.

> **Related skills:** `k-clis` (CLI registry routing) · `k-project` (project init with bun) · `k-ubuntu` (fnm/node paths per machine) · `k-nvim` (nvim TS LSP) · `k-final` (bun build/publish in closure) · `k-git-pages` (docsify Node-based site) · `k-hermes` (hermes-agent Node MCPs)

---

## Philosophy

| Context | Rule |
|---------|------|
| **Own projects** | Bun — single binary for runtime, test, build, publish |
| **Third-party CLIs** | npm global (`~/.npm-global`) — version-agnostic, always reachable |
| **Node version management** | fnm (Rust, ~15ms init) — dynamic multishell PATH, `--use-on-cd` |
| **nvm** | Legacy — installé mais plus sourcé dans `.kshrc`. Conservé pour compatibilité avec quelques outils. |
| **System Node** | NEVER — managed by fnm only |

### PATH resolution order

```
~/.bun/bin                     ← Bun runtime (own projects, priority)
~/.npm-global/bin              ← Global CLI tools (gemini, codex, copilot…)
/run/user/.../fnm_multishells/ ← Active Node version (fnm dynamic multishell)
```

---

## Runtimes — Version & Configuration

| Runtime | Binary | Version | Active via | Install method |
|---------|--------|---------|-----------|----------------|
| **Node.js** | fnm multishell → v24.18.0 | `24.18.0` | fnm (`.kshrc` eval) | `fnm install 24` |
| **npm** | fnm multishell → v24.18.0 | `10.9.4` | bundled with fnm's Node | `fnm install 24` (bundled) |
| **Bun** | `~/.bun/bin/bun` | `1.3.11` | direct PATH | `curl -fsSL https://bun.sh/install \| bash` |
| **fnm** | `~/.local/share/fnm/fnm` | latest | direct PATH | `curl -fsSL https://fnm.vercel.app/install` |
| **pnpm** | `~/.npm-global/bin/pnpm` | `10.32.1` | npm global | `npm install -g pnpm` |

Legacy nvm paths still on disk but NOT in PATH: `~/.nvm/versions/node/v22.22.1/` (v22.22.1) and `~/.nvm/versions/node/v24.18.0/` (v24.18.0).

### npm prefix

```bash
# ~/.npmrc
prefix=/home/kpihx/.npm-global

# ~/.kshrc (belt-and-suspenders)
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"
```

The `.npmrc` prefix is read by **every** npm invocation — shell, subprocess, systemd, MCP. This prevents EACCES errors when tools auto-update (see `npm-prefix.md` ref).

---

## Node Versions

### fnm (ACTIVE — via `.kshrc`)

| Version | Path | Default |
|---------|------|---------|
| **v24.18.0** | `~/.local/share/fnm/node-versions/v24.18.0/` | ✅ via `fnm default 24` |

fnm est sourcé dans `.kshrc` avec `--use-on-cd`. Le multishell gère dynamiquement `node`, `npm`, `npx` en PATH.

### nvm (LEGACY — installé mais PAS sourcé)

| Version | Path | Status |
|---------|------|--------|
| **v22.22.1** | `~/.nvm/versions/node/v22.22.1/` | Sur disque, PLUS dans PATH |
| **v24.18.0** | `~/.nvm/versions/node/v24.18.0/` | Sur disque, PLUS dans PATH |

nvm n'est plus sourcé dans `.kshrc` (remplacé par fnm). Les binaires existent encore sur disque mais ne sont pas en PATH — ils ne gênent pas.

### Cleanup restant

1. **Mettre à jour les paths systemd** qui référencent encore `~/.nvm/` (ex: OpenClaw Gateway drop-in)
2. **Supprimer nvm** (`rm -rf ~/.nvm`) — libère ~500Mo (pas urgent, peut attendre une session clean)

---

## npm Global — Complete Inventory

All installed in `~/.npm-global/lib/node_modules/`. Binaires in `~/.npm-global/bin/`.

### Agent Runtimes

| Package | Version | Binaries | Purpose |
|---------|---------|----------|---------|
| `@openai/codex` | `0.144.6` | `codex` | Codex CLI — sandboxed agent runtime |
| `@github/copilot` | `1.0.73` | `copilot` | GitHub Copilot CLI |
| `@google/gemini-cli` | `0.51.0` | `gemini` | Gemini CLI — Google agent runtime |
| `cline` | `3.0.46` | `cline` | Cline CLI — VS Code agent headless |

### MCP Servers

| Package | Version | Binaries | Purpose |
|---------|---------|----------|---------|
| `@agent360/browser-mcp` | `1.21.0` | `browser-mcp` | Browser automation MCP |
| `chrome-agent-mcp` | `1.0.0` | `chrome-agent-mcp` | Chrome DevTools MCP |
| `@playwright/mcp` | `0.0.75` | `playwright-mcp` | Playwright MCP server |
| `whats-mcp` | `0.2.0` | `whats-mcp`, `whats-admin` | WhatsApp MCP (linked: `~/Work/AI/MCPs/whats_mcp`) |

### Cloud & Productivity

| Package | Version | Binaries | Purpose |
|---------|---------|----------|---------|
| `@googleworkspace/cli` | `0.22.5` | `gws` | Google Workspace CLI |
| `@pnp/cli-microsoft365` | `11.7.0` | `m365`, `m365_chili`, `m365_comp`, `microsoft365` | Microsoft 365 CLI |
| `@tobilu/qmd` | `2.5.3` | `qmd` | BM25+vector hybrid search |

### Tools

| Package | Version | Binaries | Purpose |
|---------|---------|----------|---------|
| `pnpm` | `10.32.1` | `pnpm`, `pnpx` | Package manager (alternative) |
| `fd-find` | `1.2.0` | `fd` | Rust-based file search |

**Total: 13 packages, 20 binaires**

---

## Bun Global — Inventory

| Package | Status |
|---------|--------|
| *(empty)* | All global packages purged. `@modelcontextprotocol/server-filesystem` removed 2026-07-25. |

Bun is used as a **project-level runtime** for KpihX-owned projects, not for global tools.

---

## Project Node/TS Configs

### `.nvmrc` / `.node-version` files

Aucun fichier `.nvmrc` ou `.node-version` trouvé dans `KpihX-Labs`. Tous les projets utilisent la version Node par défaut (fnm v24.18.0 / nvm v22.22.1).

### Projects using Node/TS (package.json)

| Project | Runtime | TypeScript | Key deps |
|---------|---------|-----------|----------|
| `O/surface` | Bun + Vite | ✅ `~5.8.0` | Playwright, Vite |
| `𝛱/live/web` | Bun + Vite | ✅ `~5.8.0` | Vite |
| `Fluid/whats_proxy` | Bun | ✅ `^6.0.3` | Baileys, Fastify, Pino |
| `AI/oriyama/opencode-plugin` | Node | ❌ | *(minimal, main: index.js)* |
| `.opencode/plugin` | Node | ❌ | `@opencode-ai/plugin` |

---

## Key Commands Reference

### Node version management (fnm)

```bash
fnm install 24            # install latest v24.x
fnm default 24            # set default for new shells
fnm use 24                # switch current shell
fnm current               # show active version
fnm list                  # list installed
fnm uninstall 22          # remove old version
```

### npm global

```bash
npm install -g <pkg>      # install globally → ~/.npm-global
npm uninstall -g <pkg>    # remove
npm list -g --depth=0     # list all globals
npm prefix -g             # verify prefix
npm update -g <pkg>       # update a global tool
```

### Bun

```bash
bun --version             # 1.3.11
bun install               # install deps from package.json
bun add <pkg>             # add dependency
bun add -d <pkg>          # add dev dependency
bun remove <pkg>          # remove
bun remove -g <pkg>       # remove global (rarely used)
bun run <script>          # run package.json script
bun run src/index.ts      # run TS file directly
bun test                  # run tests
bunx <pkg>                # execute without install (like npx)
```

### Health checks

```bash
# Versions
node --version            # v22.22.1
npm --version             # 10.9.4
bun --version             # 1.3.11
fnm current               # v24.18.0

# npm prefix (should be user-owned, not system)
npm config get prefix     # ~/.npm-global

# Verify global tools
npm list -g --depth=0

# Verify fnm multishell
echo $FNM_MULTISHELL_PATH

# Disk usage
du -sh ~/.nvm             # nvm overhead
du -sh ~/.local/share/fnm  # fnm overhead
du -sh ~/.npm-global      # global tools
du -sh ~/.bun             # bun
```

---

## References

- `Work/techskills/fnm.md` — fnm setup, shell config, `--use-on-cd`, known issues
- `Work/techskills/npm-prefix.md` — npm prefix, EACCES trap, `.npmrc` vs env var
- `Work/techskills/bun.md` — Bun as sovereign JS runtime, comparison table, Docker

## Insights Discipline (mandatory)

- Read `references/insights.md` before non-trivial work in this skill domain.
- Update insights at task end with durable lessons.

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-25 | [OPENCODE] | v1.1.0 — **CORRECTION :** fnm est actif, nvm est legacy inactif. La V1 disait à tort "nvm v22.22.1 currently active" car testée dans un shell agent sans `.kshrc`. Fixé : table runtimes rewritée, section Node Versions corrigée, PATH resolution corrigé. Aussi : `.npmrc` `prefix=` décommenté (était commenté "for nvm compatibility" mais nvm n'est plus sourcé). Insights.md mis à jour. |
| 2026-07-25 | [OPENCODE] | v1.0.0 — Created k-node skill. Comprehensive inventory of Node versions (fnm + nvm), npm global packages (13), bun runtime, and JS/TS project configs. Documents PATH resolution order, prefix governance, and migration status nvm→fnm. |
| [SUMMARY] | — | v1.0.0 — Created on 2026-07-25. |
