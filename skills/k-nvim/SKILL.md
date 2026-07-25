---
name: k-nvim
description: KπX Neovim hub — config, plugins, LSP, and daily workflow map.
agent: [OPCODE]
created: "2026-05-28"
updated: "2026-07-24"
formatters: |
  Mason packages: prettierd, stylua, shfmt
metadata:
  version: 3.5.0
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
    ├── tmux-navigator.lua            ← Seamless Ctrl+h/j/k/l nvim ↔ tmux
    └── trash.lua                     ← FreeDesktop trash for dd/D/cc/C

k-nvim/assets/                        ← Non-code assets (venv configs, service overrides)
└── uv-nvim/
    └── pyproject.toml                ← Python host venv definition (see Python Provider section)

~/.config/nvim/                       ← SYMLINKS (read by nvim)
├── init.lua           → k-nvim/config/init.lua
├── lazy-lock.json     → k-nvim/config/lazy-lock.json
└── lua/kpihx/         → k-nvim/config/lua/kpihx/

~/.local/share/nvim/uv-nvim/          ← RUNTIME (venv created by uv)
├── pyproject.toml    → k-nvim/assets/uv-nvim/pyproject.toml  (symlink)
└── .venv/            ← uv-managed virtualenv (generated, never edit)
```

### Install Location

| Layer | Path |
|-------|------|
| Neovim config (canonical) | `$HOME/.agents/skills/k-nvim/config/` |
| Neovim config (runtime) | `$HOME/.config/nvim/` (symlinks to canonical) |
| Vim config | `$HOME/.vimrc` |
| Vim autoload | `$HOME/.vim/autoload/plug.vim` (vim-plug) |
| Plugin data | `$HOME/.local/share/nvim/lazy/` (Lazy-managed, read-only) |
| Undo history | `$HOME/.local/share/nvim/undo/` |
| Python host venv | `$HOME/.local/share/nvim/uv-nvim/.venv/` (uv-managed) |

> **Rule:** `~/.local/share/nvim/lazy/` contains plugin code managed by Lazy.nvim.  
> Do NOT modify files there — all changes get wiped on `:Lazy update`.  
> KπX only owns `k-nvim/config/` and `k-nvim/assets/`. Plugin healthcheck false positives are ignored.

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

## Python Provider — UV-Nvim Venv

All Python dependencies required by nvim plugins live in a single uv-managed virtualenv.
No system Python is ever touched. No pip is ever used. Everything goes through uv.

### Architecture

```
k-nvim/assets/uv-nvim/pyproject.toml     ← Source of truth (list of Python packages)
    │ symlink
    ▼
~/.local/share/nvim/uv-nvim/pyproject.toml
    │
    ▼ uv venv + uv sync
~/.local/share/nvim/uv-nvim/.venv/bin/python3  ← Python binary used by nvim
    │ g:python3_host_prog (init.lua)
    ▼
nvim Python provider (all plugins)
```

### Dependencies (from pyproject.toml)

| Package | Required by | Role |
|---------|-------------|------|
| `pynvim` | All nvim Python plugins | Neovim Python host provider. Every plugin that uses Python communicates via pynvim. Essential. |
| `jupyter-client` | molten-nvim | Jupyter kernel for running Python code inside nvim cells. Without it: Molten ERROR "Required python module jupyter-client not found". |

### Management commands

```bash
# Create or recreate the venv from scratch
cd ~/.local/share/nvim/uv-nvim && uv venv && uv sync

# Add a new dependency
cd ~/.local/share/nvim/uv-nvim && uv add <package> && uv sync

# Upgrade all dependencies
cd ~/.local/share/nvim/uv-nvim && uv sync --upgrade

# List installed packages
cd ~/.local/share/nvim/uv-nvim && uv pip list
```

### How init.lua connects to this venv

```lua
vim.g.python3_host_prog = vim.fn.expand("$HOME")
  .. "/.local/share/nvim/uv-nvim/.venv/bin/python3"
```

This tells nvim to use the Python interpreter from the uv venv as its Python provider. Every Python-based nvim plugin (molten, jupytext, telescope extensions, etc.) will use this Python and find all installed packages.

### Why this approach

- **Zero system Python touch.** `/usr/bin/python3` is never modified, never called by nvim.
- **Zero pip.** `pyproject.toml` + `uv sync` replaces `pip install` entirely.
- **Zero python3-venv dependency.** uv creates its own virtualenvs without needing the Ubuntu system package.
- **Single source of truth.** All Python packages for nvim are declared in one file, in version control.
- **Reproducible.** `uv sync` guarantees the same package versions across machines.
- **Trivially deleteable.** `rm -rf ~/.local/share/nvim/uv-nvim` removes everything, no system residue.

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
| `dd` | Delete line (trashed) |
| `D` | Delete to end of line (trashed) |
| `cc` | Change line (trashed) |
| `C` | Change to end of line (trashed) |
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
| **AI agents (runtimes)** | `.claude` (Claude Code), `.cline` (Cline CLI), `.codex` (Codex CLI), `.codeium` (Codeium/Windsurf), `.colab` (OpenColab), `.copilot` (GitHub Copilot), `.continue` (Continue.dev), `.gemini` (Gemini CLI), `.mistralcode` (Mistral Code), `.qwen` (Qwen CLI), `.roo` (Roo Code), `.securecoder` (Secure Coder), `.vibe` (VIBE CLI), `.flow` (Flow AI), `.sui` (Sui AI) |
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

### Post-modification healthcheck protocol (MANDATORY)

After ANY modification to Neovim config files (`init.lua`, `plugins.lua`, `lsp.lua`, `keymaps.lua`, `trash.lua`, or any `lua/kpihx/*.lua`), the agent MUST:

1. **Run the exact command, no variation allowed:**
   ```
   nvim --headless "+checkhealth" "+w! /tmp/nvim-health.md" "+qa" 2>/dev/null && cat /tmp/nvim-health.md | grep -E "❌|✗|FAIL|ERROR|WARNING|⚠️"
   ```

2. **Extract and present ONLY errors and warnings** — everything that is not ✅:
   - Lines containing `❌`, `✗`, `FAIL`, `ERROR`, `WARNING`, `⚠️`
   - Present them as-is, no truncation, no grep -v filtering, no head/tail

3. **For EACH issue, provide a COMPLETE analysis:**
   - **Exact error message** — verbatim from checkhealth
   - **Root cause** — trace the full dependency chain: what plugin requires what, which package provides it, why it is missing on this specific system.
   - **Why it happens NOW** — config change? removed dependency? version mismatch? missing system package? Never say "pre-existing" without explaining why it was pre-existing and what keeps it unfixed.
   - **Impact assessment** — what exactly breaks or degrades. Which nvim features stop working? Be specific.
   - **Fix proposal** — at least one concrete, executable fix with exact commands. If multiple fixes exist, list them with pros/cons. If there is a reason not to apply the fix (e.g., "would touch system python"), explain that reason and propose alternatives.
   - **Why the fix works** — the mechanism: what does the fix command actually do, where does it install what, why does that resolve the issue.

4. **Never hide, skip, truncate, or beautify any error or warning.** Every single one must appear in the report with its full analysis.

5. **Update SKILL.md** with the changelog before running the check — the check is the final verification.

### Known false positives (plugin-level, ignore)

These `:checkhealth` items come from plugin health files, not KπX config. They have **zero impact on daily use**:
- `nvim-treesitter: installdir not in runtimepath` → symlink normalization issue upstream, not fixed yet
- `which-key` keymap overlaps (`<gc>`/`<gcc>`, `<ys>`/`<yss>`) → inherent to vim modal editing
- `tmux focus-events` → terminal limitation, fix in `.tmux.conf` needs `tmux source-file`
- Any `report_*` deprecation warnings in plugins → plugin needs update, no action needed

## Post-Install Shell Wiring

After installing Neovim, add to `~/.kshrc` (central shell hub — already present on this workstation):

```bash
export EDITOR=nvim
```

This ensures `git commit`, `crontab -e`, `visudo`, and all env-respecting tools use Neovim.
Verify: `echo $EDITOR` → `nvim`.

> **Source of truth:** `~/.kshrc` line 45 on KπX-Ubuntu. For new machines, add to `kshrc.base` template.

## Trash System — FreeDesktop Integration

`dd`, `D`, `cc`, `C` send deleted text to the FreeDesktop trash (`~/.local/share/Trash/`).
Visible in trash-cli, GNOME trash, Ubuntu trash. Survives `:w` and nvim restart.

### How it works

Each delete operation writes two files to `~/.local/share/Trash/`:
- `files/nvim-dd-<timestamp>-<id>` — the deleted line(s)
- `info/nvim-dd-<timestamp>-<id>.trashinfo` — FreeDesktop metadata

The `.trashinfo` uses path prefix `.nvim-dd/` to distinguish nvim trash entries and prevent accidental `trash-restore` collisions.

### What is covered

| Key | Operation | Trashed |
|-----|-----------|---------|
| `dd` | Delete line (with count: `3dd`) | ✅ |
| `D` | Delete to end of line | ✅ |
| `cc` | Change line (delete + insert) | ✅ |
| `C` | Change to end of line | ✅ |

Not covered: `x` (too granular), `s`, visual `d` (complex — planned).

### What survives

| After this... | Trash content? | `u` undo? | Register `""`? |
|---------------|----------------|-----------|-----------------|
| `:w` | ✅ still there | ✅ (undofile) | ❌ cleared |
| `:q` then reopen | ✅ still there | ✅ (undofile) | ❌ cleared |
| `trash-empty` | ❌ wiped | depends | ❌ |
| GNOME trash GUI delete | ❌ wiped | depends | ❌ |

### CLI reference

```bash
trash-list | grep nvim-dd    # show nvim trash entries
trash-empty                  # empty ALL trash (nvim + system)
```

### Source

`lua/kpihx/trash.lua` — 80 lines, zero dependencies. No plugin needed.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-24 | [OPENCODE] | v3.5.0 — Python provider migrated to dedicated uv venv (`k-nvim/assets/uv-nvim/pyproject.toml`). Zero system Python, zero pip. Added "Python Provider — UV-Nvim Venv" section. Cleaned up `uv tool jupyter-client` (merged into venv). Trash section fully in English. SKILL.md fully rewritten in English. |
| 2026-07-24 | [OPENCODE] | v3.4.0 — Fixed molten ❌: installed jupyter-client via `uv tool install jupyter-client` (no system python, no pip). Molten now has its kernel. Warnings for optional modules (cairosvg, plotly, etc.) remain — they are optional. |
| [SUMMARY] | — | v3.3.0 expanded healthcheck protocol; v3.2.0 added healthcheck section; v3.1.0 basedpyright via uv; v3.0.0 FreeDesktop Trash; v2.1.0 Post-Install Shell Wiring; v2.0.0 centralized config; v1.2.0–v1.7.0 RAM optimization (2.3GB→21MB). |
