# Telescope —  Quick Guide

## Keymaps

| Leader | Action | Hidden | Follow symlinks |
|--------|--------|--------|-----------------|
| `<leader>ff` | Find files | Yes | Yes |
| `<leader>fF` | Find files | No | No |
| `<leader>fg` | Live grep (content) | — | — |
| `<leader>fb` | Buffers | — | — |
| `<leader>fh` | Help tags | — | — |
| `<leader>fs` | LSP document symbols | — | — |
| `<leader>fd` | Diagnostics | — | — |
| `<leader>fc` | Git commits | — | — |

## Interactive keys (inside Telescope)

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

## How `<leader>ff` works under the hood

```lua
require("telescope.builtin").find_files({
  hidden = true,
  follow = true,
  find_command = {
    "fd", "--type", "f", "--hidden", "--follow", "--no-ignore-vcs",
    "--exclude", ".git",
    "--exclude", "node_modules",
    -- ... ~50 more --exclude patterns (see plugins.lua for full list)
  },
})
```

- `--hidden` : includes dotfiles
- `--follow` : follows symlinks (needed for `.agents/` → `~/Labs/.agents/`)
- `--no-ignore-vcs` : ignores `.gitignore` (we want to see everything)
- `--exclude` : fd filters at OS level before any results reach Telescope — prevents ballooning

## `<leader>fF` (no hidden)

Same `find_command` as `ff` but without `--hidden` and `--follow`. Good when you know the file isn't hidden and don't want symlink noise.

## `<leader>fg` (live grep)

Uses `file_ignore_patterns` (Lua post-filter) instead of `find_command` because `rg`/`grep` don't accept `--exclude` the same way fd does. The `ignore` table in `plugins.lua` mirrors the `--exclude` list.

## RAM

Before lazy-loading: 2.3 GB idle (Lua heap 2003 MB)
After lazy-loading heavy plugins (VeryLazy) + harpoon (keys): **21 MB idle** (Lua heap 35 MB)

## Dependency (GRAVÉ — both backends mandatory)

- `fd` for `find_files` (`<leader>ff`/`<leader>fF`): `find_command = {"fd", …}` in `plugins.lua:85`. On Debian/Ubuntu the `fd-find` apt package ships as `fdfind` → **symlink required**: `ln -sf $(which fdfind) ~/.local/bin/fd` (`~/.local/bin` in `$PATH` via `.kshrc`).
- `rg` (`ripgrep`) for `live_grep` (`<leader>fg`): `sudo apt install ripgrep`.

Install (laptop-wsl, 2026-08-25, forgotten at initial setup → `ff` showed 0 results): `sudo apt install fd-find ripgrep && ln -sf $(which fdfind) ~/.local/bin/fd`. Verify: `which fd && which rg && fd --version && rg --version`. Without both, Telescope is silent (filed 2026-08-25).

## File

Config source: `~/.config/nvim/lua/kpihx/plugins.lua` (lines 85–177 for find_commands).

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
| `.agents/` | Symlink to `~/Labs/.agents/` — core agent kernel: `AGENTS.md`, rules, skills, profiles. Followed via `--follow`. |
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
