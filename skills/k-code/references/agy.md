# Antigravity (agy) — Maintenance & Debug

## Issue: Infinite Edit Loops (ENOSPC)

**Observed:** On Linux (Ubuntu), high-level edit tools (`replace_file_content`, `write_to_file`) would hang or loop indefinitely with `+0 -0` changes in the UI. 
**Cause:** `fs.inotify.max_user_watches` system limit reached due to large workspace surveillance. VS Code fails to monitor changes, breaking the synchronization between the agent's filesystem write and the IDE's internal state.

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
    "**/.cache/**": true
}
```

### Note
This fix restores immediate responsiveness to all agentic editing tools.
**Standard**: Load this reference whenever an agent experiences "edit hanging" or "sync loops".
