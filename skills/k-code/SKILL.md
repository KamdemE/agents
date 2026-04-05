---
name: "k-code"
description: "KπX VSCode ecosystem — profiles, settings, extension registry, cleanup, and profile-maintenance scripts. Load when auditing VSCode config, managing profiles, reviewing extensions, or updating VSCode state programmatically."
license: "private"
metadata:
  author: "KpihX"
  version: "4.1.1"
allowed-tools: "Bash(*), *"
---

# KπX — VSCode Ecosystem

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Key Paths

| Resource | Path |
|----------|------|
| VSCode user root | `$HOME/.config/Code/User/` |
| Base settings | `$HOME/.config/Code/User/settings.json` |
| Base keybindings | `$HOME/.config/Code/User/keybindings.json` |
| Base MCP config | `$HOME/.config/Code/User/mcp.json` |
| Base chat model config | `$HOME/.config/Code/User/chatLanguageModels.json` |
| Profile registry | `$HOME/.config/Code/User/globalStorage/storage.json` |
| Profile hash directories | `$HOME/.config/Code/User/profiles/<hash>/` |
| Exported profile files | `$HOME/.config/Code/User/profiles/*.code-profile` |
| Global extension registry | `$HOME/.vscode/extensions/extensions.json` |
| Installed extension payloads | `$HOME/.vscode/extensions/` |
| Cleanup wrapper | `$HOME/Work/sh/clean/clean_editors.sh` |
| Code cleanup script | `$HOME/Work/sh/clean/clean_vscode.sh` |
| Cursor cleanup script | `$HOME/Work/sh/clean/clean_cursor.sh` |
| AGY cleanup script | `$HOME/Work/sh/clean/clean_agy.sh` |
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
| Cleanup behavior | `$HOME/Work/sh/clean/clean_vscode.sh` |
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
- `cursor/install_cursor.sh`: Advanced installer downloading Cursor AppImage with system integrations.
- `cursor/sync_cursor.sh`: Hard-links `cursor`'s internal storage parameters directly back to `k-code`.
- `agy/sync_agy.sh`: Hard-links `antigravity`'s internal storage parameters directly back to `k-code`.

## References

The `references/` directory is the source of truth for snapshots and forks configuration procedures:
- `references/general.code-profile`
- `references/java.code-profile`
- `references/cpp.code-profile`
- `references/latex.code-profile`

For specific forks implementation and maintenance details, refer to:
- `$HOME/.agents/skills/k-code/references/agy.md`
- `$HOME/.agents/skills/k-code/references/cursor.md`

Regarding editor cleanup and cache purging, all scripts reside centrally in your `Work` space and not as symlinks defined in the skill memory itself. The generic wrapper `clean_editors.sh` calls the individual scripts:
- `$HOME/Work/sh/clean/clean_editors.sh`
- `$HOME/Work/sh/clean/clean_vscode.sh`
- `$HOME/Work/sh/clean/clean_cursor.sh`
- `$HOME/Work/sh/clean/clean_agy.sh`

## Operational Rules

- **Close VSCode before editing `storage.json`** — the running app rewrites it from memory
- Never handcraft profile `extensions.json` from scratch; derive it from `$HOME/.vscode/extensions/extensions.json`
- Prefer changing profile ownership through the helper script instead of ad hoc edits
- keep exported `.code-profile` snapshots owned by `$HOME/.agents/skills/k-code/references/`; external VSCode profile files should symlink back to them
- When documenting VSCode state here, avoid enumerating volatile inventories; point to the file that holds the truth
- Keep the custom main profile named `General` to avoid confusion with VSCode's built-in `__default__profile__`

## Current Conformity Notes

- No broken symlinks were found under `$HOME/.agents/skills/*/references/` during the 2026-04-03 audit
- the `.code-profile` link direction was corrected: `$HOME/.agents/skills/k-code/references/` now owns the snapshots and `$HOME/.config/Code/User/profiles/*.code-profile` points back to them
- The stray `%24HOME`-escaped workspace association was removed from `storage.json`
- At the time of audit, no custom profile had its own `settings.json`, `mcp.json`, or `keybindings.json`; verify live files directly before assuming this is still true later

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-05 | [CLAUDE] | v4.1.1 — `scripts/cursor/install_cursor.sh`: extract AppImage to `$HOME/Applications/cursor-app`, wrapper calls `AppRun --no-sandbox`, remove raw AppImage after extract (AppArmor userns bypass) |
| 2026-04-05 | [GEMINI] | v4.1.0 — added `clean_editors.sh` wrapper script orchestrating overall editor caches; updated SKILL.md paths and references |
| [SUMMARY] | — | v4.0.0–v1.0.0: k-code folder split (`profiles/`, `agy/`, `cursor/`), clean scripts in `Work/sh/clean/`, Antigravity/Cursor sync, rename from k-vscode, profile source-of-truth, conformity notes, registry bootstrap |
