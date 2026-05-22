# Google Antigravity (AGY)

> **Source of truth** for the four-product Antigravity stack on KπX workstations (2026 I/O split). Install: `scripts/agy/install_agy_components.sh`.

## Ecosystem — four pillars

| Pillar | Role | Install path | **KπX command** | Google binary / compat |
|--------|------|--------------|-----------------|-------------------------|
| **Hub 2.0** | Agent-first desktop orchestrator | `$HOME/.local/share/antigravity-hub/` | **`agy-hub`** · `agy-hub.desktop` | `antigravity` · `antigravity-hub` |
| **IDE** | VS Code-fork pair programmer | `$HOME/.local/share/antigravity-ide/` | **`agy-ide`** · `agy-ide.desktop` · Open Cloud | `antigravity-ide` |
| **CLI** | Terminal agent | `$HOME/.local/bin/agy` | **`agy`** | curl installer |
| **SDK** | Python library | `pip3 install --user google-antigravity` | `import google.antigravity` | PyPI `google-antigravity` |

**Pattern A (like `code` / `cursor`):** one short command per surface — `agy`, `agy-ide`, `agy-hub`. Repair: `wire_short_launchers.sh`.

**Four distinct builds** — do not assume one launcher covers Hub, IDE, CLI, or legacy apt `/usr/bin/antigravity`.

## Config & agent state

| Component | User config | Extensions | Agent / MCP |
|-----------|-------------|------------|-------------|
| Hub | May overlap `~/.config/Antigravity` if deb was installed | `$HOME/.antigravity/` → VS Code | `$HOME/.gemini/antigravity/` |
| IDE | `$HOME/.config/Antigravity IDE/` | `$HOME/.antigravity-ide/` → VS Code | `$HOME/.gemini/antigravity-ide/` |
| CLI | CLI session store | — | export to GUI possible |
| SDK | — | — | in-process only |

`sync_agy.sh` symlinks both `Antigravity` and `Antigravity IDE` user dirs to `$HOME/.config/Code/User/*`.

## Install

Archives: `$HOME/Downloads/Antigravity.tar.gz`, `$HOME/Downloads/Antigravity IDE.tar.gz`.

```bash
$HOME/.agents/skills/k-code/scripts/agy/install_agy_components.sh
$HOME/.agents/skills/k-code/scripts/agy/wire_short_launchers.sh   # repair symlinks only
$HOME/.agents/skills/k-code/scripts/agy/sync_agy.sh
$HOME/.agents/skills/k-code/scripts/agy/bootstrap_open_cloud.sh --install-desktop
$HOME/Work/sh/clean/clean_agy.sh -i
```

**Legacy apt:** installer removes `apt install antigravity` by default (`--skip-apt-remove` to keep deb).

**Linux sandbox (once per extract):**

```bash
sudo chown root:root "$HOME/.local/share/antigravity-ide/chrome-sandbox" \
  "$HOME/.local/share/antigravity-hub/chrome-sandbox"
sudo chmod 4755 "$HOME/.local/share/antigravity-ide/chrome-sandbox" \
  "$HOME/.local/share/antigravity-hub/chrome-sandbox"
```

## Scripts (`scripts/agy/`)

| Script | Purpose |
|--------|---------|
| `install_agy_components.sh` | Hub + IDE tar, curl CLI, pip SDK, icons, desktops, sync, optional apt remove |
| `install_agy_icons.sh` | Light Hub + dark IDE menu icons |
| `fix_agy_sandbox.sh` | `chmod 4755` chrome-sandbox (sudo once) if GUI exits silently |
| `agy-hub.sh` / `launch_agy_hub.sh` / `launch_agy_ide.sh` | Hub shell launcher + menu wrappers (`--no-sandbox`, `--ozone-platform=x11` on Wayland; IDE skips `.kshrc` trap) |
| `refresh_agy_menu.sh` | Regenerate desktops + icon cache; removes legacy Open Cloud `.desktop` |
| `wire_short_launchers.sh` | `agy-hub` → `agy-hub.sh`; `agy-ide` → binary; `antigravity-*` compat |
| `sync_agy.sh` | VS Code settings, profiles, extensions parity |
| `bootstrap_open_cloud.sh` | `agy-ide` + Continue Mistral + `AGENTS.md` rules + optional desktop |

## Desktop entries & icons

**App menu:** two launchers — **Antigravity Hub** (light icon) + **Antigravity IDE** (dark icon).

| Launcher | Icon source |
|----------|-------------|
| Hub | Light full-color — Hub `app.asar` `/icon.png` ([press](https://antigravity.google/press)) |
| IDE | Dark — `jetski-logo-white.svg` on `#202124` background |

Refresh icons/menu: **`refresh_agy_menu.sh`** (also removes stale gear launcher). **GUI:** menu uses `launch_agy_*.sh` — do **not** use `bootstrap --launch` from `.desktop` (`.kshrc` + `set -u` broke IDE). Terminal bootstrap still OK interactively.

| File | Visible in menu | Starts |
|------|-----------------|--------|
| `agy-hub.desktop` | yes | Hub 2.0 (`agy-hub`) |
| `agy-ide.desktop` | yes | IDE via `bootstrap_open_cloud.sh --launch` (Continue + shell env) |
| `kpihx-antigravity-open-cloud.desktop` | **no** (`NoDisplay=true`) | legacy duplicate — use `agy-ide.desktop` |

## When to use which

- **Daily coding + Continue Mistral** → **`agy-ide`** or Open Cloud desktop
- **Multi-agent orchestration** → **`agy-hub`**
- **SSH / terminal agent** → **`agy`**
- **Custom Python automation** → SDK
- **Legacy Gemini extensions** → `gemini` until ported (`k-gemini`)

## vs Gemini CLI

| | **Gemini CLI** (`gemini`) | **Antigravity CLI** (`agy`) |
|--|---------------------------|------------------------------|
| Status | Sunset ~June 2026 (many tiers) | Successor terminal surface |
| Config | `$HOME/.gemini/settings.json`, `$HOME/Work/AI/gemini_mcps/` | Official install; shared AGY settings |
| MCP | `gemini mcp add` + `gemini-extension.json` | GUI: `$HOME/.gemini/antigravity/mcp_config.json` — see `references/mcp/agy.md` |

**KπX:** keep `gemini` for existing MCP flows; prefer **`agy`** for new terminal work. Do not mix MCP install procedures.

## Cache cleanup

`$HOME/Work/sh/clean/clean_agy.sh` → `$HOME/.config/Antigravity/` — `-i` infos · `-s` safe · `-p` purge · `-l` live

## IDE UI (Planning / Fast)

- **`Ctrl + .`** — toggle Fast ↔ Planning
- **Model selector** (chat input) — model + mode
- **`+`** — context files/folders only
- **Fast** — quick edits, Flash · **Planning** — architecture, Pro, artifacts
- **Settings > Agent** — artifact review policy

## MCP (GUI)

`$HOME/.gemini/antigravity/mcp_config.json` (+ IDE tree under `antigravity-ide/`). Full procedure: **`references/mcp/agy.md`**.

## ENOSPC — infinite edit loops

**Symptom:** `replace_file_content` / `write_to_file` hang, `+0 -0`; red banner “Unable to watch for file changes”.

**Cause:** `fs.inotify.max_user_watches` exhausted.

**Fix:** extend `$HOME/.config/Code/User/settings.json` (synced into AGY):

```json
{
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
    },
    "chat.hookFilesLocations": {
        ".github/hooks": true,
        "$HOME/.agents/hooks/copilot/hooks.json": true
    },
    "chat.useCustomAgentHooks": true,
    "chat.useAgentsMdFile": true
}
```

Use `$HOME` literally in the live file per KπX path rules in synced settings.
