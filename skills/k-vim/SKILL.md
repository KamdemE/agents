---
name: k-vim
description: KπX Vim & Neovim hub — config, plugins, LSP, opencode integration, and daily workflow map.
agent: [OPCODE]
created: "2026-05-28"
updated: "2026-05-28"
metadata:
  version: 1.0.0
---

# KπX — Vim & Neovim

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

## Install Location

| Layer | Path |
|-------|------|
| Neovim config | `$HOME/.config/nvim/` |
| Vim config | `$HOME/.vimrc` |
| Vim autoload | `$HOME/.vim/autoload/plug.vim` (vim-plug) |
| Plugin data | `$HOME/.local/share/nvim/lazy/` |
| Undo history | `$HOME/.local/share/nvim/undo/` |

### File structure

```
~/.config/nvim/
├── init.lua                   # Entrypoint — Lazy.nvim bootstrap
└── lua/kpihx/
    ├── plugins.lua            # Full Lazy plugin spec (28 plugins)
    ├── lsp.lua                # LSP: pyright, ts_ls, ruff, jsonls, yamlls, marksman, bashls, texlab
    ├── opencode.lua           # opencode.nvim keymaps (nickjvandyke/opencode.nvim)
    ├── keymaps.lua            # Custom keybindings
    └── tmux-navigator.lua     # Seamless Ctrl+h/j/k/l nvim ↔ tmux
```

## Installed Plugins

### Neovim (31 total via Lazy.nvim)

| Category | Plugins |
|----------|---------|
| **Core/UI** | catppuccin (mocha, transparent), lualine.nvim, which-key.nvim, indent-blankline.nvim |
| **LSP** | nvim-lspconfig, mason.nvim, mason-lspconfig.nvim |
| **Completion** | nvim-cmp, cmp-nvim-lsp, cmp-buffer, cmp-path, LuaSnip |
| **Fuzzy/Search** | telescope.nvim, harpoon |
| **Git** | neogit, gitsigns.nvim, octo.nvim |
| **Editing** | conform.nvim, Comment.nvim, vim-surround |
| **AI** | opencode.nvim, ollama.nvim |
| **Navigation** | oil.nvim, vim-tmux-navigator, toggleterm.nvim |
| **Quality** | trouble.nvim, todo-comments.nvim |
| **Other** | markdown-preview.nvim, snacks.nvim |
| **Dep** | plenary.nvim (for telescope/neogit) |

### Vim (fallback, 4 via vim-plug)

| Plugin | Role |
|--------|------|
| tpope/vim-surround | Delimiter manipulation |
| tpope/vim-commentary | Toggle comments |
| tpope/vim-fugitive | Git integration |
| tpope/vim-repeat | Dot-repeat for plugins |

## OpenCode Integration (opencode.nvim)

**Repository:** `nickjvandyke/opencode.nvim` (active fork)
**Dep:** `folke/snacks.nvim` (input + picker)
**Config:** `$HOME/.config/nvim/lua/kpihx/opencode.lua`

| Key | Action |
|-----|--------|
| `<C-a>` (visual) | `opencode.ask("@this: ", { submit = true })` |
| `<C-x>` (visual) | `opencode.select()` |
| `<C-.>` (n/t) | `opencode.toggle()` |

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
| `<leader>ff` | Telescope find files |
| `<leader>fg` | Telescope live grep |
| `<leader>fb` | Telescope buffers |
| `<leader>gs` | Neogit status |
| `<leader>e` | Oil file explorer |
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

## Philosophy

- **Neovim = daily driver.** Vim = universal fallback (SSH, containers, visudo, crontab -e). Both installed.
- **LSP-first editorship:** autocompletion, diagnostics, goto-definition, rename — no heavy IDE.
- **OpenCode as copilot:** editor sends context, agent proposes, KπX validates.
- **tmux as glue:** persistent sessions, split-pane editor + agent + shell, detachable.

### Workflow (tmux + nvim + opencode)

```
tmux session → window "dev":
  Pane 1 (75%) → nvim .
  Pane 2 (25%) → opencode --port 6174
Navigation: Ctrl+h (pane 1) / Ctrl+l (pane 2)
```

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-28 | [OPCODE] | v1.0.0 — Initial skill: nvim config, 31 plugins, LSP (8 servers), opencode.nvim, tmux-navigator, Vim fallback. |
| [SUMMARY] | — | Initial release. |
