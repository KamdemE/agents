# Trash System — FreeDesktop Integration

`dd`, `D`, `cc`, `C` send deleted text to the FreeDesktop trash (`~/.local/share/Trash/`).
Visible in trash-cli, GNOME trash, Ubuntu trash. Survives `:w` and nvim restart.

## How it works

Each delete operation writes two files to `~/.local/share/Trash/`:
- `files/nvim-dd-<timestamp>-<id>` — the deleted line(s)
- `info/nvim-dd-<timestamp>-<id>.trashinfo` — FreeDesktop metadata

The `.trashinfo` uses path prefix `.nvim-dd/` to distinguish nvim trash entries and prevent accidental `trash-restore` collisions.

## What is covered

| Key | Operation | Trashed |
|-----|-----------|---------|
| `dd` | Delete line (with count: `3dd`) | ✅ |
| `D` | Delete to end of line | ✅ |
| `cc` | Change line (delete + insert) | ✅ |
| `C` | Change to end of line | ✅ |

Not covered: `x` (too granular), `s`, visual `d` (complex — planned).

## What survives

| After this... | Trash content? | `u` undo? | Register `""`? |
|---------------|----------------|-----------|-----------------|
| `:w` | ✅ still there | ✅ (undofile) | ❌ cleared |
| `:q` then reopen | ✅ still there | ✅ (undofile) | ❌ cleared |
| `trash-empty` | ❌ wiped | depends | ❌ |
| GNOME trash GUI delete | ❌ wiped | depends | ❌ |

## CLI reference

```bash
trash-list | grep nvim-dd    # show nvim trash entries
trash-empty                  # empty ALL trash (nvim + system)
```

## Source

`lua/kpihx/trash.lua` — 80 lines, zero dependencies. No plugin needed.
