---
name: "k-code"
description: "KπX VS Code-family hub: Code user dir (settings, keybindings, MCP, chat models), storage.json registry, profile extensions, workspaceStorage + GitHub Copilot Chat JSONL, references/profiles snapshots, profile_update.py / profile_build.py, Cursor & Antigravity sync scripts + references/cursor.md & agy.md, .agents/skills/k-ubuntu/scripts/clean. Load for Code, Cursor, or AGY audits, profiles, forks, extensions, or Copilot history recovery."
license: "private"
metadata:
  author: "KpihX"
  version: "4.3.8"
allowed-tools: "Bash(*), *"
---

# KπX — VSCode Ecosystem

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **OS references:** `references/windows.md` (Windows/WSL paths for VS Code, Cursor, AGY, Continue.dev, winget install)

## Key Paths

| Resource | Path |
|----------|------|
| VSCode user root | `$HOME/.config/Code/User/` |
| Base settings | `$HOME/.config/Code/User/settings.json` |
| Base keybindings | `$HOME/.config/Code/User/keybindings.json` |
| Base MCP config | `$HOME/.config/Code/User/mcp.json` |
| Base chat model config | `$HOME/.config/Code/User/chatLanguageModels.json` |
| Profile registry | `$HOME/.config/Code/User/globalStorage/storage.json` |
| Per-workspace storage (folder name = hash of workspace URI) | `$HOME/.config/Code/User/workspaceStorage/<hash>/` |
| GitHub Copilot Chat sessions (one JSONL file per chat) | `$HOME/.config/Code/User/workspaceStorage/<hash>/chatSessions/*.jsonl` |
| Copilot Chat tool/attachment artifacts | `$HOME/.config/Code/User/workspaceStorage/<hash>/GitHub.copilot-chat/chat-session-resources/<session-id>/` |
| Cursor agent transcripts (one JSONL per thread) | `$HOME/.cursor/projects/<workspace-slug>/agent-transcripts/<session-id>/<session-id>.jsonl` |
| Continue.dev global config (models/rules/MCP YAML) | `$HOME/.continue/config.yaml` |
| Continue global rules (IDE-wide) | `$HOME/.continue/rules/` |
| Continue local secrets for `${{ secrets.* }}` | `$HOME/.continue/.env` |
| Antigravity “Open Cloud” launcher (optional) | `$HOME/.local/share/applications/kpihx-antigravity-open-cloud.desktop` |
| Profile hash directories | `$HOME/.config/Code/User/profiles/<hash>/` |
| Exported profile files | `$HOME/.config/Code/User/profiles/*.code-profile` |
| Global extension registry | `$HOME/.vscode/extensions/extensions.json` |
| Installed extension payloads | `$HOME/.vscode/extensions/` |
| Cleanup wrapper | `$HOME/.agents/skills/k-ubuntu/scripts/clean/clean_editors.sh` |
| Code cleanup script | `$HOME/.agents/skills/k-ubuntu/scripts/clean/clean_vscode.sh` |
| Cursor cleanup script | `$HOME/.agents/skills/k-ubuntu/scripts/clean/clean_cursor.sh` |
| AGY cleanup script | `$HOME/.agents/skills/k-ubuntu/scripts/clean/clean_agy.sh` |
| Skill references | `$HOME/.agents/skills/k-code/references/` |
| Registry helper | `$HOME/.agents/skills/k-code/scripts/profiles/profile_update.py` |
| Extensions helper | `$HOME/.agents/skills/k-code/scripts/profiles/profile_build.py` |

## Current Profiles

| Profile | Hash | Primary files to inspect |
|---------|------|--------------------------|
| `General` | `6c61ca05` | `profiles/6c61ca05/`, `profiles/general.code-profile` |
| `Java` | `-4fafa846` | `profiles/-4fafa846/`, `profiles/java.code-profile` |
| `LaTeX` | `-3b9d8381` | `profiles/-3b9d8381/`, `profiles/latex.code-profile` |
| `C-Cpp` | `52133472` | `profiles/52133472/`, `profiles/cpp.code-profile` |

**Built-in `__default__profile__`:**
- VSCode internal fallback profile
- Not KπX's main working profile
- Avoid assigning workspaces to it when a custom profile should own them

## Where To Read What

| Need | Source of truth |
|------|-----------------|
| Base editor behavior | `$HOME/.config/Code/User/settings.json` |
| Base terminal/editor shortcuts | `$HOME/.config/Code/User/keybindings.json` |
| Which profile owns each workspace | `$HOME/.config/Code/User/globalStorage/storage.json` |
| Which custom profiles exist | `$HOME/.config/Code/User/globalStorage/storage.json` → `userDataProfiles` |
| Which extensions a profile enables | `$HOME/.config/Code/User/profiles/<hash>/extensions.json` |
| Full installed extension metadata | `$HOME/.vscode/extensions/extensions.json` |
| Human-readable exported profile snapshot | `$HOME/.config/Code/User/profiles/*.code-profile` |
| Recover or search a GitHub Copilot Chat transcript | `$HOME/.config/Code/User/workspaceStorage/<hash>/chatSessions/` — each `*.jsonl` is one session (often very long lines); locate `<hash>` via `globalStorage/storage.json` (`backupWorkspaces`, `profileAssociations.workspaces`) or by searching JSONL with `rg`/a small script |
| Recover or search a Cursor agent conversation | `$HOME/.cursor/projects/<workspace-slug>/agent-transcripts/` — each `<session-id>.jsonl` is one Cursor thread; tool fetch artifacts typically sit in sibling `agent-tools/` files under the same workspace slug |
| Cleanup behavior | `$HOME/.agents/skills/k-ubuntu/scripts/clean/clean_vscode.sh` |
| Ready-made local references | `$HOME/.agents/skills/k-code/references/` |

## Runtime Model

- Base `settings.json` applies globally
- A profile-specific `settings.json` only exists if that profile overrides the base
- Base `keybindings.json` is shared unless a profile defines its own
- Workspace-to-profile mapping lives in `storage.json`
- Profile extension subsets live in `profiles/<hash>/extensions.json`
- Exported `.code-profile` files are convenient snapshots, not the live registry

## Scripts

### Scripts Architecture

The scripts managing your IDE profiles and forks reside in `$HOME/.agents/skills/k-code/scripts/`:

#### Profiles Generation & Updates
Located in `scripts/profiles/`:
- `profile_update.py`: Use when VSCode is closed to register a custom profile, move workspaces away from `__default__profile__`, or assign paths to hashes.
- `profile_build.py`: Use to rebuild a specific profile's `extensions.json` from text lists directly based on global payloads.

#### Forks Synchronization
Located in `scripts/cursor/` and `scripts/agy/`:
- **Cursor install:** official `.deb` on Ubuntu (`/usr/bin/cursor`); see `references/cursor.md`. No AppImage wrapper.
- `cursor/sync_cursor.sh`: Hard-links `cursor`'s internal storage parameters directly back to `k-code`.
- **Antigravity ecosystem (2026):** Hub + IDE + CLI + SDK — `agy` / `agy-ide` / `agy-hub`; see `references/agy.md`.
- `agy/install_agy_components.sh`: Extract Hub/IDE from `$HOME/Downloads/`, curl CLI, pip SDK, icons, desktops, sync, optional `apt remove antigravity`.
- `agy/install_agy_icons.sh`: Menu icons from Hub asar + IDE `astro.png` → `$HOME/.local/share/icons/kpihx/`.
- `agy/wire_short_launchers.sh`: **`agy-ide`**, **`agy-hub`** short commands (pattern A, like `code`/`cursor`); `antigravity-*` compat aliases.
- `agy/sync_agy.sh`: Symlinks `Antigravity` + `Antigravity IDE` user dirs and extensions to VS Code hub.
- `agy/bootstrap_open_cloud.sh`: **`agy-ide`** + Continue bootstrap (AGENTS rules, `~/.continue/.env`, optional desktop). See `references/agy.md`.

## References

The `references/` directory is the source of truth for snapshots and forks configuration procedures:
- `references/profiles/general.code-profile`
- `references/profiles/java.code-profile`
- `references/profiles/cpp.code-profile`
- `references/profiles/latex.code-profile`

For specific forks implementation and maintenance details, refer to:
- `$HOME/.agents/skills/k-code/references/agy.md` (ecosystem, install, launchers, Gemini vs agy, ENOSPC)
- `$HOME/.agents/skills/k-code/references/cursor.md`
- `$HOME/.agents/skills/k-code/references/mcp/vscode.md`

Regarding editor cleanup and cache purging, all scripts reside centrally in your `Work` space and not as symlinks defined in the skill memory itself. The generic wrapper `clean_editors.sh` calls the individual scripts:
- `$HOME/.agents/skills/k-ubuntu/scripts/clean/clean_editors.sh`
- `$HOME/.agents/skills/k-ubuntu/scripts/clean/clean_vscode.sh`
- `$HOME/.agents/skills/k-ubuntu/scripts/clean/clean_cursor.sh`
- `$HOME/.agents/skills/k-ubuntu/scripts/clean/clean_agy.sh`

## Operational Rules

- **Close VSCode before editing `storage.json`** — the running app rewrites it from memory
- Never handcraft profile `extensions.json` from scratch; derive it from `$HOME/.vscode/extensions/extensions.json`
- Prefer changing profile ownership through the helper script instead of ad hoc edits
- keep exported `.code-profile` snapshots owned by `$HOME/.agents/skills/k-code/references/profiles/`; live `$HOME/.config/Code/User/profiles/*.code-profile` should symlink back to them
- When documenting VSCode state here, avoid enumerating volatile inventories; point to the file that holds the truth
- Keep the custom main profile named `General` to avoid confusion with VSCode's built-in `__default__profile__`
- MCP profile safety rule: if a workspace is attached to a profile, MCP servers must be configured in that profile or linked from it (for example, symlink `profiles/<hash>/mcp.json` to `$HOME/.config/Code/User/mcp.json`)

## Current Conformity Notes

- No broken symlinks were found under `$HOME/.agents/skills/*/references/` during the 2026-04-03 audit
- the `.code-profile` link direction was corrected: `$HOME/.agents/skills/k-code/references/profiles/` owns the snapshots and `$HOME/.config/Code/User/profiles/*.code-profile` points back to them
- The stray `%24HOME`-escaped workspace association was removed from `storage.json`
- At the time of audit, no custom profile had its own `settings.json`, `mcp.json`, or `keybindings.json`; verify live files directly before assuming this is still true later

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-code/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-code/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-22 | [CURSOR] | v4.3.8 — `references/insights.md`: archived Cursor purge map (`isArchived` index + `cursorDiskKV` blobs, backup + `VACUUM` outside txn). |
| 2026-05-22 | [CURSOR] | v4.3.7 — `agy-hub.sh` wrapper (`--no-sandbox`, X11 on Wayland); `wire_short_launchers` no longer symlinks Hub to raw ELF. |
| [SUMMARY] | — | v4.3.6 launch/refresh AGY scripts; v4.2.5 Continue bootstrap; v4.3.0–v4.3.1 Hub/IDE; v4.2.x Cursor transcripts; older → file history |
