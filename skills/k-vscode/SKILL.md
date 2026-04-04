---
name: "k-vscode"
description: "KπX VSCode ecosystem — profiles, settings, extension registry, cleanup, and profile-maintenance scripts. Load when auditing VSCode config, managing profiles, reviewing extensions, or updating VSCode state programmatically."
license: "private"
metadata:
  author: "KpihX"
  version: "3.1.0"
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
| Cleanup script | `$HOME/Work/sh/clean/clean_vscode.sh` |
| Skill references | `$HOME/.agents/skills/k-vscode/references/` |
| Registry helper | `$HOME/.agents/skills/k-vscode/scripts/update_profile_registry.py` |
| Extensions helper | `$HOME/.agents/skills/k-vscode/scripts/build_profile_extensions.py` |

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
| Cleanup behavior | `$HOME/Work/sh/clean/clean_vscode.sh` and `references/clean_vscode.sh` |
| Ready-made local references | `$HOME/.agents/skills/k-vscode/references/` |

## Runtime Model

- Base `settings.json` applies globally
- A profile-specific `settings.json` only exists if that profile overrides the base
- Base `keybindings.json` is shared unless a profile defines its own
- Workspace-to-profile mapping lives in `storage.json`
- Profile extension subsets live in `profiles/<hash>/extensions.json`
- Exported `.code-profile` files are convenient snapshots, not the live registry

## Scripts

### `update_profile_registry.py`

Use when VSCode is closed and you need to:
- register or rename a custom profile
- move workspaces off `__default__profile__`
- bind a workspace path to a specific profile hash

Example:
```bash
$HOME/.agents/skills/k-vscode/scripts/update_profile_registry.py \
  --register 6c61ca05:General \
  --promote-default-to 6c61ca05 \
  --assign "$HOME/Gdrive_X/CV_ATF:-3b9d8381"
```

### `build_profile_extensions.py`

Use when you want to rebuild one profile's `extensions.json` from the global registry instead of editing JSON by hand.

Example:
```bash
$HOME/.agents/skills/k-vscode/scripts/build_profile_extensions.py \
  --profile-hash 6c61ca05 \
  --extension-file /abs/path/to/extensions.txt
```

## References

The `references/` directory is the source of truth for the exported `.code-profile` snapshots:
- `references/general.code-profile`
- `references/java.code-profile`
- `references/latex.code-profile`
- `references/cpp.code-profile`

The runtime files under `$HOME/.config/Code/User/profiles/*.code-profile` should point back to these files via symlink.

`references/clean_vscode.sh` is different:
- it points to the live cleanup script in `$HOME/Work/sh/clean/clean_vscode.sh`
- the source of truth for that script remains the cleanup workspace, not this skill

## Operational Rules

- **Close VSCode before editing `storage.json`** — the running app rewrites it from memory
- Never handcraft profile `extensions.json` from scratch; derive it from `$HOME/.vscode/extensions/extensions.json`
- Prefer changing profile ownership through the helper script instead of ad hoc edits
- keep exported `.code-profile` snapshots owned by `$HOME/.agents/skills/k-vscode/references/`; external VSCode profile files should symlink back to them
- When documenting VSCode state here, avoid enumerating volatile inventories; point to the file that holds the truth
- Keep the custom main profile named `General` to avoid confusion with VSCode's built-in `__default__profile__`

## Current Conformity Notes

- No broken symlinks were found under `$HOME/.agents/skills/*/references/` during the 2026-04-03 audit
- the `.code-profile` link direction was corrected: `$HOME/.agents/skills/k-vscode/references/` now owns the snapshots and `$HOME/.config/Code/User/profiles/*.code-profile` points back to them
- The stray `%24HOME`-escaped workspace association was removed from `storage.json`
- At the time of audit, no custom profile had its own `settings.json`, `mcp.json`, or `keybindings.json`; verify live files directly before assuming this is still true later

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-04 | [CODEX] | v3.1.0 — fixed the `.code-profile` source-of-truth direction: snapshots now live in `k-vscode/references/` and runtime files under `$HOME/.config/Code/User/profiles/` should symlink back to them |
| 2026-04-03 | [CODEX] | v3.0.1 — removed the last hardcoded home-path wording from the conformity notes by describing the cleaned `%24HOME`-escaped workspace entry generically |
| [SUMMARY] | — | v3.0.1–v1.0.0 covered the full rewrite, profile-registry scripts, `General` profile rename, post-migration verification, YAML repair, and the original VSCode skill bootstrap |
