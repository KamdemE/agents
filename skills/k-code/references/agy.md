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
- `bootstrap_open_cloud.sh`: One-shot **Antigravity + Continue** bootstrap for the “Open Cloud” workflow:
  - Runs `sync_agy.sh` (shared VS Code settings/keybindings/profile/extensions).
  - Ensures `$HOME/.continue/rules/00-kpihx-AGENTS.md` symlink → `$HOME/.agents/AGENTS.md`.
  - Creates `$HOME/.continue/.env` **once** (template) so Continue can resolve `${{ secrets.MISTRAL_API_KEY }}` per [Continue secrets](https://docs.continue.dev/guides/configuring-models-rules-tools) (global `~/.continue/.env`).
  - Optional: `--install-desktop` writes `~/.local/share/applications/kpihx-antigravity-open-cloud.desktop` (`Exec=…/bootstrap_open_cloud.sh --launch %F`) so the IDE starts after loading `~/.continue/.env` then `$HOME/.kshrc` (Bitwarden / `bw-env` injection when configured there).
  - `--launch`: run setup then `exec /usr/bin/antigravity` with forwarded args (use after secrets are available).

**Model source of truth (Continue):** `$HOME/.continue/config.yaml` — default row uses `provider: mistral` and `model: mistral-large-latest` with `apiKey: ${{ secrets.MISTRAL_API_KEY }}`. Swap `model:` to `codestral-latest` or another Mistral id if you prefer a code-first default.

**Skills in Continue:** global rule stub `$HOME/.continue/rules/01-kpihx-skills-lookup.md` + symlinked kernel `00-kpihx-AGENTS.md` (skills table lives in `AGENTS.md`).

## Purging Caches

If AGY experiences visual bugs, freezing, or state errors, it shares the same Electron caching structure as VSCode.
- The `clean_agy.sh` script located in `$HOME/Work/sh/clean/` is designed specifically for this purpose.
- Use `$HOME/Work/sh/clean/clean_agy.sh -p` to perform a deep purge of its rendering and compiled JavaScript caches.

## UI & Interaction (v1.23.2+)

In recent versions, the Antigravity interface has transitioned to a unified selector for both models and interaction modes.

### Toggling Planning Mode
- **Keyboard Shortcut**: `Ctrl + .` (period) is the universal toggle between **Fast Mode** and **Planning Mode**.
- **Unified Selector**: Click on the **Model Name** (e.g., "Gemini 3 Flash") in the lower-left corner of the chat input box. This opens a menu where you can switch both the model and the execution mode (Fast vs. Planning).
- **Context Button (`+`)**: Used for adding specific files, folders, or symbols to the conversation context, not for switching modes.

### Mode Selection Logic
- **Fast Mode**: Default for quick edits and single-file tasks. Recommended with **Flash** models.
- **Planning Mode**: Mandatory for complex architectural changes. Recommended with **Pro** models for better reasoning and artifact generation.
- **Settings**: Check `Settings > Agent` if the Planning Mode toggle is missing or to configure the "Artifact Review Policy".

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
