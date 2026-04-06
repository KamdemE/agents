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

---

## Technical Post-Mortem — Issue: Infinite Edit Loops (ENOSPC)

**Observed:** On Linux (Ubuntu), high-level edit tools (`replace_file_content`, `write_to_file`) would hang or loop indefinitely with `+0 -0` changes in the UI. 
**Cause:** `fs.inotify.max_user_watches` system limit reached due to large workspace surveillance. VS Code/AGY fails to monitor changes properly, breaking the synchronization between the agent's filesystem write and the IDE's internal state.

### Diagnosis
1.  **System Check**: `cat /proc/sys/fs/inotify/max_user_watches` (Often defaults to 8192 on older setups or restricted environments).
2.  **IDE Symptom**: Red notification: "Unable to watch for file changes. Please follow the instructions...".
3.  **Agent Symptom**: `replace_file_content` repeats the same operation without error but without success.

### Definitive Fix
Instead of pushing kernel limits (which might not persist or be restricted), **reduce consumption** by excluding heavy/irrelevant directories from the watcher.

**Update `~/.config/Code/User/settings.json`**:
```json
"files.watcherExclude": {
    "**/.git/objects/**": true,
    "**/.git/subtree-cache/**": true,
    "**/node_modules/**": true,
    "**/Downloads/**": true,
    "**/Documents/**": true,
    "**/Pictures/**": true,
    "**/Videos/**": true,
    "**/Gdrive/**": true,
    "**/Gdrive_X/**": true,
    "**/.cache/**": true,
    "**/Work/Homelab/data/**": true
}
```

### Result
This fix restores immediate responsiveness to all agentic editing tools. Load this reference whenever an agent experiences "edit hanging" or "sync loops".
