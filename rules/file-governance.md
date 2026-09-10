# File Governance

> Non-negotiable rules for ALL file operations.

## Language (CRITICAL — ABSOLUTE)
**English is the default language for all file operations and chat responses, unless context dictates otherwise.**

- **First write = English.** Always. Every new file starts in English.
- **Editing an existing file = stay in the file's language.** Read the file first. If it's in English, edit in English. If it's in another language (e.g., legacy or localized files), edit in that same language. **Never, ever mix languages in the same file.**
- **Response language** (chat with ): **Respond in the language of the user's last message in the chat.** If there is no clear language context or it is ambiguous, default to English.
- **Exception:** Editing a legacy file that was written in another language — match that language for the edit. No mixing.
- **Hard rule:** If you haven't read the file, you don't know its language → you CANNOT edit it. Read first, always.

## Path Rules (MANDATORY)
- NEVER hardcode `/home/<user>` or `~` in `.agents/` files
- ALWAYS use `$HOME` and `$USER`

## Naming Convention — `_` vs `-` (MANDATORY)

The name follows **what the file IS** (how it is consumed), never local
majority or taste:

| Kind (consumption) | Style | Examples |
|--------------------|-------|----------|
| Executable shell script (bash / make / hook / cron) | `kebab-case` `-` | `check-links.sh`, `install-hooks.sh`, `post-commit.sh` |
| Sourced shell lib/guard (`source`, defines functions) | `snake_case` `_` | `lib.sh`, `link_basic_guard.sh`, `service_asset_guard.sh` |
| Python module/package (any `import`) | `snake_case` `_` — **language constraint** | `env_lib.py`, `check_skills/` |
| JS/TS shared lib twin | keep the `_` base name of its sh/py twins | `env_lib.js` |
| Project / repo / CLI binary name | `kebab-case` `-` | `tick-proxy` |
| Importable package inside a project | `snake_case` `_` | `tick_proxy` |

### Why the split

Filesystem paths accept any character, but an importable name is parsed as a
language identifier: `import foo-bar` parses as subtraction → Python
`SyntaxError`. So anything ever `import`ed or `source`d MUST use `_`; pure
executables live only in the pathname namespace and follow the Unix CLI
convention `-`.

### Rules

1. **One canonical name per file.** NEVER both `foo-bar.sh` and `foo_bar.sh`
   in the same tree.
2. **Rename = atomic sweep.** A rename MUST update every `source` /
   `shellcheck source=` / `import` reference in the same change.
3. **Directories follow their content type:** executable groups may be kebab
   (`scripts/tailscale/`); imported packages are snake (`scripts/check_skills/`);
   single-word names (`env/`, `libs/`) are neutral.
4. Canonical in-repo examples: `scripts/check-links.sh` (executable, `-`) vs
   `scripts/link_basic_guard.sh` (sourced, `_`) vs `libs/env/env_lib.py`
   (imported, `_`).

## Single Source of Truth
- Never duplicate content across files. Every duplication = future desync.
- No live-queryable lists — name the source to inspect instead
- Source-of-truth-first: name the file/dir to inspect, don't enumerate its contents
- Concise writing: tables/bullets over prose

## File Routing
"ajuste/update/suit <X>" → `skills/k-<x>/SKILL.md` by default.
| Example | Resolves to |
|---------|-------------|
| "ajuste AGENTS" | `AGENTS.md` |
| "ajuste VIBE" | `skills/k-vibe/SKILL.md` |
| "ajuste GIT" | `skills/k-git/SKILL.md` |
| "ajuste WORKSPACE" | `skills/k-context/SKILL.md` (workspace context) or `skills/<github-user>/SKILL.md` (kernel) |

## Home Directory Routes
| Path | Scope |
|------|-------|
| `$HOME/Gdrive/` | Pro/Academic Google Drive (rclone: `gdrive-x:`) |
| `$HOME/Gdrive/` | Personal Google Drive (rclone: `gdrive:`) |
| `$HOME/Work/` | Dev & prod code, infra, scripts |
| `$HOME/Pictures/` | Generated visuals, screenshots |
| `$HOME/Documents/` | Docs, PDFs, notes |
| `$HOME/Downloads/` | Temporary downloads |
| `$HOME/Videos/` | Recordings, screencasts |

## Pre-edit `.bak` Backup Rule (MANDATORY)

**Before ANY file modification** (edit, rename, move, delete):
1. Create a backup with `.bak` extension in `/tmp/` — **never** next to the original file
2. Never delete `.bak` files from `/tmp/` — they are a permanent safety net
3. Pattern: `cp <file> /tmp/<file>.bak` or `mv <file> /tmp/<file>.bak`
4. Exception: if the file already has a `.bak` backup in `/tmp/`, skip

### Rationale
- Prevents littering project dirs with `.bak~`, `.bak.1`, `original.md.bak` artifacts
- `/tmp/` is reboot-persistent for the current uptime → safety net if an edit goes wrong
- Never deleting `.bak` files = zero information loss (GRAVÉ)
- Exception: sensitive files (tokens, secrets) → delete `.bak` after successful edit

### Examples
```bash
# ✅ GOOD — backup in /tmp/
cp ~/.config/opencode/opencode.jsonc /tmp/opencode.jsonc.bak

# ❌ BAD — backup next to original
mv ~/.config/opencode/opencode.jsonc ~/.config/opencode/opencode.jsonc.bak
```

## Temp Rule — `/tmp/` for non-project artifacts

Every file that is NOT versioned project code goes into `/tmp/` — not `$HOME/`, not `$HOME/Work/`, not the workspace root.

### What belongs in `/tmp/`

| Category | Examples |
|----------|----------|
| **Diagnostic/check scripts** | `check-gpu.sh`, `test-conn.sh`, `dump-env.sh`, `probe-ports.sh` |
| **Out-of-scope scripts** | a one-liner to sort logs, a throwaway Python script to cross CSV data once |
| **Downloaded installers** | `miniconda.sh`, `rustup-init`, temp `.deb`, `ollama_install.sh` |
| **Temp binaries/tools** | a binary fetched for a single task, never installed |
| **Exploration/debug artifacts** | `tmux capture-pane -S -` outputs, diagnostic logs, JSON dumps |
| **Ephemeral token/secret exports** | before import into Vaultwarden — then DELETE |
| **Intermediate generation files** | temp renders, conversions, extractions |
| **Throwaway tests/experiments** | `test-idea.py`, `scratch.ipynb` imported nowhere |

### Organization (subdirectories recommended)

```
/tmp/
├── check-<topic>/       # verification scripts
├── install-<tool>/      # installers
├── export-<tool>/       # exports/dumps
├── explore-<topic>/     # throwaway exploration code
└── <project>/           # project-related but not versionable
```

### Rules

- **Default: `/tmp/`** — not `~/Downloads/`, not `$PWD`, not `~/Work/`
- **Use `mktemp -d` or explicit subdirectory** — no loose files at `/tmp/` root
- **`/tmp/` is shared by all agents** — name directories to avoid collisions
- **Cleanup: not mandatory** (reboot = clean), but if sensitive (token, secret) → delete after use
- **Exception:** if the user explicitly requests a path, follow 
- **Exception:** Vaultwarden exports follow their own rule (`/tmp/*.env` → import + delete)

### Exception — Explore/lab (scientific scripts)

Scripts that need scientific libraries (numpy, matplotlib, scipy, etc.) go to **`$HOME/Labs/Explore/lab/scripts/`** — not `/tmp/`. This is a shared `uv` project pre-loaded with common scientific libs. Consult `pyproject.toml` before adding. New lib → `uv add <package>`. **100% uv in this lab — NEVER pip, NEVER python, NEVER `uv pip`.** Run with `uv run scripts/your_script.py`.

### What does NOT go in `/tmp/`

- Business/project code, scripts that belong to a codebase → **in the repo**
- System configuration files → **`/etc/` or `~/.config/`**
- Long-term data → **`$HOME/Work/`, `$HOME/Gdrive/`, etc.**
- Educational/tutorial assets → **`$HOME/Work/techskills/`**

## Binaries over Aliases

**Prefer creating real binaries in `$HOME/.local/bin/` over shell aliases.**

| Mechanism | Scope | Problem |
|-----------|-------|---------|
| `alias rm='trash-put'` | Interactive shells only | Fails in scripts, subshells, tmux `!`, `sh -c` |
| `~/.local/bin/rm` wrapper | **All** — scripts, subshells, crons, tmux | PATH priority, works everywhere |

**Rules:**
- To override a system command → create a binary in `~/.local/bin/`
- **Alias is last resort** — only for shell-specific things (prompt, colors, `alias -g`)
- The binary must be an asset in the relevant skill, symlinked to `~/.local/bin/`
- Example: `k-clis/assets/rm` → `~/.local/bin/rm`

## `.agents/` Centralization — First Reflex

**Every config file, service, asset, wrapper, system script that belongs to the  infrastructure must live in `.agents/` under the appropriate skill.**

### Principle

```
1. Identify the skill covering the domain (k-*)
2. Place the asset in skills/k-<x>/assets/
3. Symlink to the system location (or copy for local files)
```

### What goes in `.agents/`

| Category | Example | Skill |
|----------|---------|-------|
| Binary wrapper | `rm` → `~/.local/bin/rm` | `k-clis` |
| Shell config | `.zshrc`, `.bashrc` (frozen) | `k-zsh` |
| Systemd service | drop-in, unit files | `k-ubuntu`, `k-tailscale` |
| Firewall ruleset | `nftables.conf` → `/etc/nftables.conf` | `k-nftables` |
| Tool scripts | `k_phones_sshd_autostart.sh`, gws-profiles.sh | `k-phones`, `k-google` |

### What does NOT go in `.agents/`

- Application code (projects) → `$HOME/Work/` or the repo
- Personal data → `$HOME/Gdrive*/` or `$HOME/Documents/`
- Temporary files → `/tmp/`

### Why

- **Single source of truth**: the asset is canonical, not a loose file
- **Versioned**: auditable, traceable (via `make check`)
- **Deployable**: symlink on a new machine = everything portable
- **No duplication**: one asset, N symlinks

### Conditioned reflex

> **Before creating any config file, wrapper, systemd service, or system script → ask yourself: does a skill for this domain exist in `.agents/` ? If yes, the asset goes there. If no skill exists, is the domain broad enough to warrant a new one ? If not, place it in the closest parent skill.**

## Knowledge Base (k-qmd)
Load `k-qmd` before querying. Main collections: `techskills`, `presentation`, `agents`, `codex`, `gemini`, `copilot`, `vibe`. Always check `$HOME/Work/techskills/templates/` before creating new files from scratch.
