---
name: k-vscode
description: >
  KπX VSCode ecosystem — settings, profiles, extensions, telemetry, and clean suite integration.
  Load when auditing VSCode config, managing profiles, reviewing extensions, running VSCode cleanup,
  or creating/editing profiles programmatically.
license: private
metadata:
  author: KpihX
  version: "2.0.0"
allowed-tools: Bash(*), "*"
---

# KπX — VSCode Ecosystem

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Key Paths

| Resource | Path |
|----------|------|
| Main settings (global) | `$HOME/.config/Code/User/settings.json` |
| Main keybindings | `$HOME/.config/Code/User/keybindings.json` |
| Profile registry | `$HOME/.config/Code/User/globalStorage/storage.json` |
| Profile directories | `$HOME/.config/Code/User/profiles/<hash>/` |
| Global extension registry | `$HOME/.vscode/extensions/extensions.json` ← source of truth |
| Extensions installed | `$HOME/.vscode/extensions/` |
| VSCode data root | `$HOME/.config/Code/` |
| Clean script | `$HOME/Work/sh/clean/clean_vscode.sh` (→ `references/clean_vscode.sh`) |

## Profile Architecture — How It Really Works

```
~/.config/Code/User/
├── settings.json          ← BASE settings (always active, all profiles inherit)
├── keybindings.json       ← BASE keybindings (inherited by all profiles)
├── mcp.json               ← MCP config for __default__profile__ (empty)
├── globalStorage/
│   └── storage.json       ← Profile registry: userDataProfiles + profileAssociations
└── profiles/
    ├── 6c61ca05/          → "Default"  — 36 ext
    ├── -4fafa846/         → "Java"     — 26 ext
    ├── -3b9d8381/         → "LaTeX"    — 20 ext
    └── 52133472/          → "C-Cpp"    — 24 ext
```

**Inheritance model:**
- Profile `settings.json` = **overrides only** on top of `~/.config/Code/User/settings.json`
- If absent → full inheritance from base (LaTeX, Default)
- `keybindings.json` is inherited from base (only defined in base)
- `mcp.json` can be per-profile (currently only base has one, empty)

**Built-in `__default__profile__`:** VSCode special profile — always exists, activates ALL 49 installed extensions. Cannot be deleted or restricted. Use as emergency fallback.

## storage.json — Profile Registry

**File:** `$HOME/.config/Code/User/globalStorage/storage.json`

**`userDataProfiles`** — registers custom profiles:
```json
[
  {"location": "6c61ca05",  "name": "Default"},
  {"location": "52133472",  "name": "C-Cpp"},
  {"location": "-4fafa846", "name": "Java"},
  {"location": "-3b9d8381", "name": "LaTeX"}
]
```

**`profileAssociations.workspaces`** — maps workspace URI → profile hash:
```json
{
  "file:///home/kpihx/Work/AI/MCPs/mem_mcp": "6c61ca05",
  "file:///home/kpihx/Gdrive_X/CV_ATF":      "-3b9d8381",
  ...
}
```
> Special value `__default__profile__` = built-in Default (avoid using — use `6c61ca05` instead)

**To reassign a workspace to a profile:**
```python
import json
with open('~/.config/Code/User/globalStorage/storage.json') as f: s = json.load(f)
s['profileAssociations']['workspaces']['file:///path/to/ws'] = '6c61ca05'
with open('~/.config/Code/User/globalStorage/storage.json', 'w') as f: json.dump(s, f, indent=2)
```

## Profile `extensions.json` — How to Build

**Source of truth:** `$HOME/.vscode/extensions/extensions.json` — 49 extensions with full metadata (UUID, publisherId, installedTimestamp…).

**To create/update a profile's extensions:**
```python
import json
with open('$HOME/.vscode/extensions/extensions.json') as f: all_exts = json.load(f)
# Filter to desired subset
profile_exts = [e for e in all_exts if e['identifier']['id'] in WANTED_IDS]
with open('$HOME/.config/Code/User/profiles/<hash>/extensions.json', 'w') as f:
    json.dump(profile_exts, f, indent=4)
```
> Never manually craft extensions.json — always derive from `$HOME/.vscode/extensions/extensions.json` to get correct UUIDs and metadata.

## Settings — Base Config (`settings.json`)

```json
// Privacy & telemetry
"telemetry.telemetryLevel": "off"

// Security
"security.workspace.trust.untrustedFiles": "prompt"

// Performance
"python.analysis.diagnosticMode": "openFilesOnly"
"python.analysis.indexing": false
"terminal.integrated.scrollback": 50000

// Claude Code
"claudeCode.preferredLocation": "panel"

// All AI features explicitly disabled: Copilot, GitLens AI, GitLab Duo, GitHub PR
// → full disable block in settings.json directly
```

## Profile Settings Comparison

| Config file | `__default__` | Default `6c61ca05` | Java `-4fafa846` | LaTeX `-3b9d8381` | C-Cpp `52133472` |
|-------------|:---:|:---:|:---:|:---:|:---:|
| `settings.json` | ✅ (full base) | — (inherits) | ⚠️ (gitlens override) | — (inherits) | ⚠️ (gitlens override) |
| `keybindings.json` | ✅ (shift+enter) | — (inherits) | — | — | — |
| `mcp.json` | ✅ (empty) | — | — | — | — |
| `chatLanguageModels.json` | ✅ [] | ✅ [] | — | — | — |
| `snippets/` | ✅ (empty) | ✅ (empty) | ✅ (empty) | — | ✅ (empty) |

**Notes:**
- Java + C-Cpp `settings.json` contains redundant `gitlens.ai.model` keys — already disabled globally. Harmless but dead config.
- Per-profile `mcp.json` enables different MCP sets per language context (not yet used).
- `chatLanguageModels.json` stores custom AI model configs — currently empty on all profiles.

## Profile Map

| Profile | Hash | Ext count | Specific extensions | All workspaces |
|---------|------|-----------|--------------------|-|
| **Default** | `6c61ca05` | 36 | Python×4 + Jupyter×8 + Rust + Docker + JS/TS×3 | 35 ws |
| **Java** | `-4fafa846` | 26 | redhat.java + vscjava.×7 | — |
| **LaTeX** | `-3b9d8381` | 20 | james-yu.latex-workshop | — |
| **C-Cpp** | `52133472` | 24 | cpptools×4 + cmake | — |

### Common block — 19 extensions in ALL profiles

```
Git/AI:    anthropic.claude-code · eamodio.gitlens · gitlab.gitlab-workflow
           github.vscode-pull-request-github
Remote:    github.codespaces · github.remotehub · ms-vscode.remote-repositories
AI/Chat:   openai.chatgpt · google.gemini-cli-vscode-ide-companion · google.colab
           github.copilot-chat
Tools:     ms-vscode.vscode-speech · ms-vsliveshare.vsliveshare · lokad.lokad-envision
           mechatroner.rainbow-csv · yzhang.markdown-all-in-one · tamasfe.even-better-toml
           redhat.vscode-yaml · ms-vscode.makefile-tools
```

### Excluded from specialized profiles (in Default only)

```
Python:    ms-python.python · ms-python.vscode-pylance · ms-python.debugpy
           ms-python.vscode-python-envs
Jupyter:   ms-toolsai.jupyter · jupyter-hub · jupyter-keymap · jupyter-renderers
           jupyter-cell-tags · jupyter-powertoys · jupyter-slideshow · datawrangler
Rust:      rust-lang.rust-analyzer
Docker:    docker.docker
JS/TS:     dbaeumer.vscode-eslint · esbenp.prettier-vscode · ms-vscode.js-debug-nightly
```

## Storage & Cache

| Directory | Role | Size (audit 2026-04-03) | Safe to delete |
|-----------|------|-------------------------|----------------|
| `~/.vscode/extensions/` | Installed extensions | ~2.3 GB | ❌ Never |
| `CachedExtensionVSIXs/` | VSIX post-install rollback | ~995 MB | ✅ Always |
| `WebStorage/` | Electron webview / chat history | ~359 MB | ⚠️ Purge only |
| `Cache/` | Electron HTTP cache | ~310 MB | ✅ Safe |
| `CachedData/` | Compiled extension JS | ~115 MB | ⚠️ ~1min regen |
| `workspaceStorage/` | Per-workspace DB (35 ws) | ~130 MB | ⚠️ Manual |
| `globalStorage/` | Extension global state | ~52 MB | ❌ Never |
| `logs/` | Session logs | ~1.5 MB | ✅ Always |

## Clean Suite Integration

Module of `$HOME/Work/sh/clean/` — same `-i/-s/-p` API as all other clean scripts.

```bash
./clean_vscode.sh -i   # dry-run: show sizes
./clean_vscode.sh -s   # safe: CachedExtensionVSIXs + Cache + logs
./clean_vscode.sh -p   # purge: + CachedData + WebStorage (with warnings)
```

Runs automatically **every Saturday 10:00** via `auto_clean.sh -s` (safe targets only).
→ Source: `references/clean_vscode.sh`

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-03 | [CLAUDE] | v2.0.0 — full rewrite: real profile architecture, storage.json registry, programmatic profile build procedure, settings comparison table, workspace migrations |
| 2026-04-03 | [CLAUDE] | v1.0.0 — initial skill |
