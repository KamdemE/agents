# Google Antigravity (AGY) Configuration

Antigravity (AGY) relies on the same architecture as VSCode. To maintain absolute parity and avoid duplicate environments, follow this guide for synchronization with the `k-code` ecosystem.

## Installation

```bash
sui -r "Refresh package metadata before installing Antigravity" apt update
sui -r "Install the Antigravity package" apt install antigravity
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

### Definitive Fix (Phoenix v3.1 Standard)

Instead of pushing kernel limits (which might not persist or be restricted), **reduce consumption** by excluding heavy/irrelevant directories from the watcher and explicitly defining hook locations for Copilot Chat.

**Update `$HOME/.config/Code/User/settings.json`**:
```json
{
    "workbench.colorTheme": "Dark Modern",
    "chat.hookFilesLocations": {
        ".github/hooks": true,
        "$HOME/.agents/hooks/copilot/hooks.json": true,
        ".claude/settings.json": false,
        ".claude/settings.local.json": false,
        "$HOME/.claude/settings.json": false
    },
    "chat.useCustomAgentHooks": true,
    "chat.useAgentsMdFile": true,
    "chat.useCustomizationsInParentRepositories": true,
    "github.copilot.chat.agentDebugLog.enabled": true,
    "files.watcherExclude": {
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/node_modules/**": true,
        "**/.hg/store/**": true,
        "**/Downloads/**": true,
        "**/Documents/**": true,
        "**/Pictures/**": true,
        "**/Videos/**": true,
        "**/Gdrive_X/**": true,
        "**/Gdrive/**": true,
        "**/.npm-global/**": true,
        "**/Work/Others/**": true,
        "**/Work/X/**": true,
        "**/Work/Homelab/presentation/**": true,
        "**/.venv/**": true,
        "**/.tox/**": true,
        "**/.cache/**": true,
        "**/Work/Homelab/data/**": true
    }
}
```

### Result
This configuration restores immediate responsiveness to all agentic editing tools and ensures that Copilot Chat correctly loads the specialized KπX agent hooks while ignoring legacy Claude settings. Load this reference whenever an agent experiences "edit hanging", "sync loops", or hook failures.
