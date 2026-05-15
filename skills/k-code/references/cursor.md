# Cursor (Fork) Configuration

Cursor relies on the same architecture as VSCode. To maintain absolute parity and avoid duplicate environments, follow this guide for synchronization with the `k-code` ecosystem.

## Install (Ubuntu — `.deb` only)

On Ubuntu, use the official **`.deb`** package. Do not use AppImage or a custom `~/.local/bin/cursor` wrapper.

```bash
# Download latest .deb from https://cursor.com/download (linux-x64 deb)
sudo dpkg -i cursor_*_amd64.deb
sudo apt -f install -y   # if dependencies are missing

cursor --version           # should resolve to /usr/bin/cursor → /usr/share/cursor/bin/cursor
```

- **Binary:** `/usr/share/cursor/cursor` (symlinked as `/usr/bin/cursor`)
- **Desktop entry:** `/usr/share/applications/cursor.desktop` (use this; do not override with `~/.local/share/applications/cursor.desktop`)
- **Profile data (keep):** `~/.config/Cursor`, `~/.cursor`

### Upgrade

```bash
sudo dpkg -i cursor_*_amd64.deb
```

### Remove legacy AppImage layout

If an old AppImage extract exists, remove it so only the `.deb` runs:

```bash
rm -f ~/.local/bin/cursor ~/.local/share/applications/cursor.desktop ~/.local/share/icons/cursor.png
rm -rf ~/Applications/cursor-app ~/Applications/cursor.AppImage
```

## Scripts & Operation

The Cursor-specific script in `$HOME/.agents/skills/k-code/scripts/cursor/`:

- `sync_cursor.sh`: Modifies the `.config/Cursor` and `.cursor` directories to use relative symlinks pointing back to `$HOME/.config/Code` and `$HOME/.vscode/extensions`.

## Purging Caches

If Cursor experiences visual bugs, freezing, or state errors, it shares the same Electron caching structure as VSCode.

- The `clean_cursor.sh` script located in `$HOME/Work/sh/clean/` is designed specifically for this purpose.
- Use `$HOME/Work/sh/clean/clean_cursor.sh -p` to perform a deep purge of its rendering and compiled JavaScript caches.
