# Google Antigravity (AGY) Configuration

Antigravity (AGY) relies on the same architecture as VSCode. To maintain absolute parity and avoid duplicate environments, follow this guide for synchronization with the `k-code` ecosystem.

## Installation

```bash
sudo apt update
sudo apt install antigravity
```

## Scripts & Operation

The AGY-specific scripts are located at `$HOME/.agents/skills/k-code/scripts/agy/`:
- `sync_agy.sh`: Modifies the `.config/Antigravity` and `.antigravity` directories to use relative symlinks pointing back to `$HOME/.config/Code` and `$HOME/.vscode/extensions`. This encapsulates the symlink generation procedure cleanly.

## Purging Caches

If AGY experiences visual bugs, freezing, or state errors, it shares the same Electron caching structure as VSCode.
- The `clean_agy.sh` script located in `$HOME/Work/sh/clean/` is designed specifically for this purpose.
- Use `$HOME/Work/sh/clean/clean_agy.sh -p` to perform a deep purge of its rendering and compiled JavaScript caches.
