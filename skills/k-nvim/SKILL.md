---
name: k-nvim
description: KπX Neovim hub — config, plugins, LSP, and daily workflow map.
agent: [OPCODE]
created: "2026-05-28"
updated: "2026-06-05"
formatters: |
  Mason packages: prettierd, stylua, shfmt
metadata:
  version: 2.0.0
---

# KπX — Neovim

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Quick Reference

| Command | Action |
|---------|--------|
| `nvim` | Launch Neovim (daily driver) |
| `vim` | Launch Vim (SSH/container/visudo fallback) |
| `nvim +Lazy` | Open Lazy.nvim plugin manager |
| `:Lazy update` | Update all plugins |
| `:Mason` | Manage LSP servers, formatters, linters |
| `:checkhealth` | Full Neovim health check |

## Architecture — Centralized Config

The canonical source for all KπX Neovim config is `k-nvim/config/`.  
`~/.config/nvim/` is a **symlink tree** pointing into it — edit either path, the file is the same.

```
k-nvim/config/                        ← SOURCE OF TRUTH (edit here)
├── init.lua                          ← Entrypoint — Lazy.nvim bootstrap
├── lazy-lock.json                    ← Lazy plugin lockfile (versioned)
└── lua/kpihx/
    ├── plugins.lua                   ← Full Lazy plugin spec (28 plugins)
    ├── lsp.lua                       ← LSP: basedpyright, ruff, lua_ls, jsonls, yamlls, marksman, bashls, texlab
    ├── keymaps.lua                   ← Custom keybindings
    └── tmux-navigator.lua            ← Seamless Ctrl+h/j/k/l nvim ↔ tmux

~/.config/nvim/                       ← SYMLINKS (read by nvim)
├── init.lua           → k-nvim/config/init.lua
├── lazy-lock.json     → k-nvim/config/lazy-lock.json
└── lua/kpihx/         → k-nvim/config/lua/kpihx/
```

### Install Location

| Layer | Path |
|-------|------|
| Neovim config (canonical) | `$HOME/.config/opencode/skills/k-nvim/config/` |
| Neovim config (runtime) | `$HOME/.config/nvim/` (symlinks to canonical) |
| Vim config | `$HOME/.vimrc` |
| Vim autoload | `$HOME/.vim/autoload/plug.vim` (vim-plug) |
| Plugin data | `$HOME/.local/share/nvim/lazy/` (Lazy-managed, read-only) |
| Undo history | `$HOME/.local/share/nvim/undo/` |

> **Rule:** `~/.local/share/nvim/lazy/` contains plugin code managed by Lazy.nvim.  
> Do NOT modify files there — all changes get wiped on `:Lazy update`.  
> KπX only owns `k-nvim/config/`. Plugin healthcheck false positives are ignored.

### Bundled references

| File | Content |
|------|---------|
| `references/telescope.md` | Telescope usage and keybind reference |
| `references/healthcheck-audit-2026-05-30.md` | Historical healthcheck audit log |

## Installed Plugins

### Neovim (26 total via Lazy.nvim)

| Category | Plugins |
|----------|---------|
| **Core/UI** | catppuccin (mocha, transparent), lualine.nvim, which-key.nvim, indent-blankline.nvim |
| **LSP** | nvim-lspconfig, mason.nvim, mason-lspconfig.nvim |
| **Completion** | nvim-cmp, cmp-nvim-lsp, cmp-buffer, cmp-path, LuaSnip |
| **Fuzzy/Search** | telescope.nvim (backend: fd), harpoon |
| **Git** | neogit, gitsigns.nvim |
| **Editing** | conform.nvim, Comment.nvim, vim-surround |
| **AI** | ollama.nvim |
| **Navigation** | oil.nvim, vim-tmux-navigator |
| **Quality** | trouble.nvim, todo-comments.nvim |
| **Dep** | plenary.nvim (for telescope/neogit) |

### Vim (fallback, 4 via vim-plug)

| Plugin | Role |
|--------|------|
| tpope/vim-surround | Delimiter manipulation |
| tpope/vim-commentary | Toggle comments |
| tpope/vim-fugitive | Git integration |
| tpope/vim-repeat | Dot-repeat for plugins |

## LSP — Language Servers

| Language | Server | Formatter | Analyzer | Mason name |
|----------|--------|-----------|----------|------------|
| Python | pyright | ruff | ruff | `pyright`, `ruff-lsp` |
| TypeScript/JS | ts_ls | prettier | eslint | `typescript-language-server` |
| Lua | lua_ls | stylua | — | `lua-language-server` |
| JSON | jsonls | — | — | `json-lsp` |
| YAML | yamlls | — | — | `yaml-language-server` |
| Markdown | marksman | — | — | `marksman` |
| Bash | bashls | shfmt | — | `bash-language-server` |
| LaTeX | texlab | — | — | `texlab` |

Install: `:Mason` (UI) or `:MasonInstall pyright ruff-lsp lua-language-server ...`

## Quick Keys (Normal mode)

| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `<leader>ff` | Telescope find files (incl. hidden) |
| `<leader>fF` | Telescope find files (no hidden) |
| `<leader>fg` | Telescope live grep (search file contents) |
| `<leader>fb` | Telescope buffers |
| `<leader>gs` | Neogit status |
| `<leader>e` | Oil file explorer |
| `..` | Oil: go to parent directory |
| `<C-r>` (oil) | Oil: refresh directory |
| `gx` (oil) | Oil: open file with system handler |
| `:%O` | Oil: open all files with system handler |
| `:2,4O` | Oil: open files line 2-4 with system handler |
| `:^,$O` | Oil: open all files with system handler |
| `K` | LSP hover |
| `gd` | LSP go to definition |
| `gr` | LSP references |
| `[d` / `]d` | Diagnostic prev/next |
| `<leader>xx` | Trouble diagnostics |
| `gcc` | Comment toggle line |
| `Ctrl+h/j/k/l` | Navigate splits/panes (tmux-aware) |
| `<leader>ha` | Harpoon add |
| `<leader>hl` | Harpoon quick menu |
| `<leader>u` | Undotree toggle |

## Telescope Navigation

| Key | Action |
|-----|--------|
| `<CR>` | Open file in current buffer |
| `<C-v>` | Open in vertical split |
| `<C-s>` | Open in horizontal split |
| `<C-t>` | Open in new tab |
| `<C-d>` | Scroll results down |
| `<C-u>` | Scroll results up |
| `?` | Show all Telescope keybinds |
| `<M-h>` | Toggle hidden files filter |
| `<C-_>` | Open selected file but keep Telescope open |

> **Dependency:** `fd` (npm i -g fd-find) — Telescope uses it for faster file searches.
> **Tip:** Use `<leader>e` (Oil) for directory browsing, Telescope for fuzzy search.

## Telescope Exclusion Map

`<leader>ff` uses `fd --hidden --follow --no-ignore-vcs` with native `--exclude` filters. These run at the OS level before any results reach Telescope.

### Excluded by fd `--exclude` (both `<leader>ff` and `<leader>fF`)

| Category | Directories |
|----------|-------------|
| **VCS** | `.git` |
| **Language runtimes** | `node_modules`, `target`, `build`, `dist`, `.next`, `go/pkg`, `__pycache__`, `.venv`, `.env`, `.pytest_cache`, `.mypy_cache`, `.ruff_cache` |
| **Package managers** | `.npm`, `.npm-global`, `.bun`, `.cargo`, `.rustup`, `.nvm`, `.dotnet` |
| **Editors** | `.vscode`, `.cursor`, `.cursor-server`, `.vscode-server`, `.vscode-shared`, `.windsurf`, `.idea` |
| **AI agents (runtimes)** | `.claude` (Claude Code), `.cline` (Cline CLI), `.codex` (Codex CLI), `.codeium` (Codeium/Windsurf), `.colab` (OpenColab), `.copilot` (GitHub Copilot), `.continue` (Continue.dev), `.gemini` (Gemini CLI), `.k-ai` (KπX AI kernel), `.mistralcode` (Mistral Code), `.qwen` (Qwen CLI), `.roo` (Roo Code), `.securecoder` (Secure Coder), `.vibe` (VIBE CLI), `.flow` (Flow AI), `.sui` (Sui AI) |
| **AI agents (misc)** | `.antigravity` (Antigravity) |
| **OS/Desktop** | `.cache`, `.local`, `.config`, `.ssh`, `.docker`, `.snap`, `snap`, `.var` (Flatpak), `.mozilla`, `.gnome`, `.gnupg`, `.pki`, `.zoom`, `.oh-my-zsh`, `.tmux`, `.java`, `.android`, `.ipython`, `.jupyter` |
| **Activity** | `.n8n` (n8n), `.gitlab` (GitLab Runner) |

### NOT excluded (visible in Telescope)

| Directory | Why visible |
|-----------|-------------|
| `.agents/` | Symlink to `~/KpihX-Labs/.agents/` — core agent kernel: `AGENTS.md`, rules, skills, profiles. Followed via `--follow`. |
| `.ts_proxy/`, `.ts-proxy/` | Tailscale proxy — VPN/service mesh state |
| `.mcp-auth/` | MCP auth tokens/sessions |
| `.mcps/` | MCP server data |
| `.playwright-mcp/` | Playwright MCP cache |
| `.whats_proxy/` | WhatsApp proxy state |
| `.browser-mcp/` | Browser MCP state |
| `.grip/` | Grip (GitHub README preview) cache |
| `X_Remote/` | X/Twitter remote config |
| `.ollama/`, `.ollama-ipex/` | Ollama LLM models, sessions, conversations |

### Performance note

With `--follow` + `--no-ignore-vcs`, fd follows symlinks and ignores `.gitignore`. The `--exclude` list must be comprehensive to avoid fd ballooning (e.g., descending into `node_modules` or `target` when those dirs are symlinked). The agent AI dirs are excluded because most contain hundreds/thousands of tiny JSON/log/session files that garbage-collect.

### RAM impact

Before optimization: nvim idle = **2.3 GB** RAM (Lua heap 2003 MB).  
After lazy-loading (`event = "VeryLazy"` for heavy plugins, `keys` for harpoon): nvim idle = **21 MB** (Lua heap 35 MB).

## Philosophy

- **Neovim = daily driver.** Vim = universal fallback (SSH, containers, visudo, crontab -e). Both installed.
- **LSP-first editorship:** autocompletion, diagnostics, goto-definition, rename — no heavy IDE.
- **OpenCode as copilot (external CLI):** editor ↔ opencode CLI (separate tmux pane), no nvim plugin (opencode.nvim was purged).
- **tmux as glue:** persistent sessions, split-pane editor + agent + shell, detachable. `Ctrl+A r` to reload any blocking process.

### Workflow (tmux + nvim + opencode)

```
tmux session → window "dev":
  Pane 1 (75%) → nvim .
  Pane 2 (25%) → opencode
Navigation: Ctrl+h (pane 1) / Ctrl+l (pane 2)
Reload: Ctrl+A r (kills process, relaunches from shell history)
```

## Healthcheck Governance (MANDATORY)

After ANY modification to Neovim config files (`init.lua`, `plugins.lua`, `lsp.lua`, `keymaps.lua`, or any `lua/kpihx/*.lua`):

1. **Run `:checkhealth`** live in tmux (not headless).
2. **Identify the source** of each ❌ or ⚠️:
   - If it comes from `lua/kpihx/` or cites KπX config → fix it.
   - If it comes from a plugin's `health.lua` (`lua/<plugin>/health.lua`) → it's a plugin-side false positive. **Do NOT patch plugins in `lazy/`** — those get wiped on update. Just explain to KπX that it's a known upstream issue with no functional impact.
3. **Notify KπX** with a summary of what was fixed and what plugin-level noise was identified.
4. **Update k-nvim SKILL.md** if config changed.

> **Policy:** KπX only owns `k-nvim/config/`. Plugin healthcheck noise is ignored.  
> Never modify files inside `~/.local/share/nvim/lazy/`.

### Agent autonomy (MANDATORY)

When the user asks you to fix nvim errors, you MUST:
1. Reload nvim yourself (send `:qa!` then `nvim` to the tmux pane), never wait for the user.
2. Run `:checkhealth` **live in tmux** — NEVER headless.
3. Scroll through EVERY section using `G` / `gg` / `:N`. Capture all sections.
4. Fix ❌ errors from **KπX config only**. Ignore plugin noise.
5. Report detailed results before asking for further instructions.
6. Do NOT ask the user for permission at each step — execute autonomously.

### Known false positives (plugin-level, ignore)

These `:checkhealth` items come from plugin health files, not KπX config. They have **zero impact on daily use**:
- `nvim-treesitter: installdir not in runtimepath` → symlink normalization issue upstream, not fixed yet
- `which-key` keymap overlaps (`<gc>`/`<gcc>`, `<ys>`/`<yss>`) → inherent to vim modal editing
- `tmux focus-events` → terminal limitation, fix in `.tmux.conf` needs `tmux source-file`
- Any `report_*` deprecation warnings in plugins → plugin needs update, no action needed

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-06-05 | [OPCODE] | v2.0.0 — Centralized config in `k-nvim/config/`, `~/.config/nvim/` now symlinks. Plugin health patches removed. Healthcheck: only KπX config errors fixed. |
| [SUMMARY] | — | v1.2.0–v1.7.0: RAM optimization (2.3GB→21MB), healthcheck governance, plugin count cleanup, rename k-vim→k-nvim, Agent autonomy rule, telescope exclusion map. |
