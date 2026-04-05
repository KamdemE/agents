# Cursor (Fork) Configuration

Cursor relies on the same architecture as VSCode. To maintain absolute parity and avoid duplicate environments, follow this guide for synchronization with the `k-code` ecosystem.

## Scripts & Operation

The Cursor-specific scripts are located at `$HOME/.agents/skills/k-code/scripts/cursor/`:
- `install_cursor.sh`: Downloads the AppImage, applies the Ubuntu `no-sandbox` wrapper, extracts the icon, and links the desktop entry.
- `sync_cursor.sh`: Modifies the `.config/Cursor` and `.cursor` directories to use relative symlinks pointing back to `$HOME/.config/Code` and `$HOME/.vscode/extensions`.

## Purging Caches

If Cursor experiences visual bugs, freezing, or state errors, it shares the same Electron caching structure as VSCode.
- The `clean_cursor.sh` script located in `$HOME/Work/sh/clean/` is designed specifically for this purpose.
- Use `$HOME/Work/sh/clean/clean_cursor.sh -p` to perform a deep purge of its rendering and compiled JavaScript caches.