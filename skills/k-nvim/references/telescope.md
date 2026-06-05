# Telescope — KπX Quick Guide

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
- `--follow` : follows symlinks (needed for `.agents/` → `~/KpihX-Labs/.agents/`)
- `--no-ignore-vcs` : ignores `.gitignore` (we want to see everything)
- `--exclude` : fd filters at OS level before any results reach Telescope — prevents ballooning

## `<leader>fF` (no hidden)

Same `find_command` as `ff` but without `--hidden` and `--follow`. Good when you know the file isn't hidden and don't want symlink noise.

## `<leader>fg` (live grep)

Uses `file_ignore_patterns` (Lua post-filter) instead of `find_command` because `rg`/`grep` don't accept `--exclude` the same way fd does. The `ignore` table in `plugins.lua` mirrors the `--exclude` list.

## RAM

Before lazy-loading: 2.3 GB idle (Lua heap 2003 MB)
After lazy-loading heavy plugins (VeryLazy) + harpoon (keys): **21 MB idle** (Lua heap 35 MB)

## Dependency

`fd` via `npm i -g fd-find` — way faster than vim's internal `find` on large trees.

## File

Config source: `~/.config/nvim/lua/kpihx/plugins.lua` (lines 85–177 for find_commands).
