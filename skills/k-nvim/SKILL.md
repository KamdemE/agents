---
name: k-nvim
description:  Neovim hub — config, plugins, LSP, and daily workflow map.
agent: [OPCODE]
created: "2026-05-28"
updated: "2026-09-10"
formatters: |
  Mason packages: prettierd, stylua, shfmt
metadata:
  version: 1.0.0
---

#  — Neovim

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

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

The canonical source for all  Neovim config is `k-nvim/assets/`.
`~/.config/nvim/` is a **symlink tree** pointing into it — edit either path, the file is the same.

```
k-nvim/assets/                        ← SOURCE OF TRUTH (edit here)
├── init.lua                          ← Entrypoint — Lazy.nvim bootstrap
├── lazy-lock.json                    ← Lazy plugin lockfile (versioned)
└── lua/kpihx/
    ├── plugins.lua                   ← Full Lazy plugin spec (28 plugins)
    ├── lsp.lua                       ← LSP: basedpyright, ruff, lua_ls, jsonls, yamlls, marksman, bashls, texlab
    ├── keymaps.lua                   ← Custom keybindings
    ├── tmux-navigator.lua            ← Seamless Ctrl+h/j/k/l nvim ↔ tmux
    └── trash.lua                     ← FreeDesktop trash for dd/D/cc/C

k-nvim/assets/                        ← Config + supporting assets (edit here)
├── uv-nvim/
│   └── pyproject.toml                ← Python host venv definition (see Python Provider reference)
└── vimrc                             ← Vim fallback config (see Vim fallback section)

~/.config/nvim/                       ← SYMLINKS (read by nvim)
├── init.lua           → k-nvim/assets/init.lua
├── lazy-lock.json     → k-nvim/assets/lazy-lock.json
└── lua/kpihx/         → k-nvim/assets/lua/kpihx/

~/.vimrc               → k-nvim/assets/vimrc  (Vim fallback config)

~/.local/share/nvim/uv-nvim/          ← RUNTIME (venv created by uv)
├── pyproject.toml    → k-nvim/assets/uv-nvim/pyproject.toml  (symlink)
└── .venv/            ← uv-managed virtualenv (generated, never edit)
```

### Install Location

| Layer | Path |
|-------|------|
| Neovim config (canonical) | `$HOME/.agents/skills/k-nvim/assets/` |
| Neovim config (runtime) | `$HOME/.config/nvim/` (symlinks to canonical) |
| Vim config | `$HOME/.vimrc` → `k-nvim/assets/vimrc` (symlink) |
| Vim autoload | `$HOME/.vim/autoload/plug.vim` (vim-plug) |
| Plugin data | `$HOME/.local/share/nvim/lazy/` (Lazy-managed, read-only) |
| Undo history | `$HOME/.local/share/nvim/undo/` |
| Python host venv | `$HOME/.local/share/nvim/uv-nvim/.venv/` (uv-managed) — full detail: `references/python-provider.md` |

> **Rule:** `~/.local/share/nvim/lazy/` contains plugin code managed by Lazy.nvim.
> Do NOT modify files there — all changes get wiped on `:Lazy update`.
>  only owns `k-nvim/assets/`. Plugin healthcheck false positives are ignored.

## Installed Plugins

### Neovim (26 total via Lazy.nvim)

| Category | Plugins |
|----------|---------|
| **Core/UI** | catppuccin (mocha, transparent), lualine.nvim, which-key.nvim, indent-blankline.nvim |
| **LSP** | nvim-lspconfig, mason.nvim, mason-lspconfig.nvim |
| **Completion** | nvim-cmp, cmp-nvim-lsp, cmp-buffer, cmp-path, LuaSnip |
| **Fuzzy/Search** | telescope.nvim (backends: `fd` for `find_files` + `rg` for `live_grep` — both mandatory, see `references/telescope.md` → Dependency), harpoon |
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

| Language | Server | Formatter | Analyzer | Install method |
|----------|--------|-----------|----------|----------------|
| Python | basedpyright | ruff | ruff | `uv tool install basedpyright` (via uv, not Mason) |
| TypeScript/JS | ts_ls | prettier | eslint | `:MasonInstall typescript-language-server` |
| Lua | lua_ls | stylua | — | `:MasonInstall lua-language-server` |
| JSON | jsonls | — | — | `:MasonInstall json-lsp` |
| YAML | yamlls | — | — | `:MasonInstall yaml-language-server` |
| Markdown | marksman | — | — | `:MasonInstall marksman` |
| Bash | bashls | shfmt | — | `:MasonInstall bash-language-server` |
| LaTeX | texlab | — | — | `:MasonInstall texlab` |

Install:
- **Mason packages:** `:MasonInstall lua-language-server json-lsp yaml-language-server marksman bash-language-server texlab typescript-language-server`
- **basedpyright:** `uv tool install basedpyright` (not via Mason — uses its own bundled Node.js)
- **ruff:** `:MasonInstall ruff`

## Python Provider

All Python dependencies required by nvim plugins live in a single uv-managed virtualenv — zero system Python, zero pip. Full architecture, dependency list, management commands, and rationale → **`references/python-provider.md`**.

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
| `gc` | Open current **file** in VS Code at cursor position (`-g line:col`) |
| `gC` | Open current **directory** in VS Code (Oil dir first, then buffer dir) |
| `gx` (oil) | Oil: open file with system handler |
| `:%O` | Oil: open all files with system handler |
| `:2,4O` | Oil: open files line 2-4 with system handler |
| `:^,$O` | Oil: open all files with system handler |
| `K` | LSP hover |
| `gd` | LSP go to definition |
| `gr` | LSP references |
| `[d` / `]d` | Diagnostic prev/next |
| `<leader>xx` | Trouble diagnostics |
| `<leader>cc` | Comment toggle line |
| `<leader>c` (visual) | Comment toggle selection |
| `Ctrl+h/j/k/l` | Navigate splits/panes (tmux-aware) |
| `<leader>ha` | Harpoon add |
| `<leader>hl` | Harpoon quick menu |
| `dd` | Delete line (trashed) |
| `D` | Delete to end of line (trashed) |
| `cc` | Change line (trashed) |
| `C` | Change to end of line (trashed) |
| `<leader>u` | Undotree toggle |

## Telescope

Interactive keys, `find_files`/`live_grep` internals, dependency (`fd`), RAM impact, and the full exclusion map (VCS, language runtimes, package managers, editors, AI agent runtime dirs) → **`references/telescope.md`**.

> **Tip:** Use `<leader>e` (Oil) for directory browsing, Telescope for fuzzy search.

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

After ANY modification to Neovim config files, the agent MUST run `:checkhealth` live in tmux, fix errors from the user config only (ignore plugin-side false positives), reload nvim autonomously, and update this SKILL.md. Full governance rules, agent-autonomy mandate, the exact post-modification verification command, and the known-false-positives list → **`references/healthcheck-protocol.md`**.

## Post-Install Shell Wiring

After installing Neovim, add to `~/.kshrc` (central shell hub — already present on this workstation):

```bash
export EDITOR=nvim
```

This ensures `git commit`, `crontab -e`, `visudo`, and all env-respecting tools use Neovim.
Verify: `echo $EDITOR` → `nvim`.

> **Source of truth:** `~/.kshrc` line 45 on -Ubuntu. For new machines, add to `kshrc.base` template.

## Trash System — FreeDesktop Integration

`dd`, `D`, `cc`, `C` send deleted text to the FreeDesktop trash (`~/.local/share/Trash/`) — visible in trash-cli/GNOME/Ubuntu trash, survives `:w` and nvim restart. Full mechanism, coverage table, survival matrix, and CLI reference → **`references/trash-system.md`**.

## Bundled references

| File | Content |
|------|---------|
| `references/telescope.md` | Telescope usage, keybind reference, and full fd exclusion map |
| `references/python-provider.md` | UV-Nvim Venv: architecture, dependencies, management commands |
| `references/healthcheck-protocol.md` | Healthcheck governance, agent autonomy, post-modification protocol, known false positives |
| `references/trash-system.md` | FreeDesktop trash integration mechanism, coverage, and CLI reference |
| `references/healthcheck-audit-2026-05-30.md` | Historical healthcheck audit log |

