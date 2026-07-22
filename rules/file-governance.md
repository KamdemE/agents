# File Governance

> Non-negotiable rules for ALL file operations.

## Language (CRITICAL — ABSOLUTE)
**ALL FILES: CODE, COMMENTS, DOCS, SKILLS, SCRIPTS, CONFIGS, COMMITS, READMEs, MARKDOWN: ENGLISH ONLY.** Non-negotiable.

- **First write = English.** Always. Every new file starts in English.
- **Editing an existing file = stay in the file's language.** Read the file first. If it's in English, edit in English. If it's in another language (legacy), edit in that same language. **Never, ever mix languages in the same file.**
- **Response language** (chat with KπX): match KπX's conversation language. This NEVER bleeds into files.
- **Exception:** Editing a legacy file that was written in another language — match that language for the edit. No mixing.
- **Hard rule:** If you haven't read the file, you don't know its language → you CANNOT edit it. Read first, always.

## Path Rules (MANDATORY)
- NEVER hardcode `/home/<user>` or `~` in `.agents/` files
- ALWAYS use `$HOME` and `$USER`

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
| "ajuste WORKSPACE" | `skills/k-context/SKILL.md` (workspace context) or `skills/kpihx-labs/SKILL.md` (kernel) |

## Home Directory Routes
| Path | Scope |
|------|-------|
| `$HOME/Gdrive_X/` | Pro/Academic Google Drive (rclone: `gdrive-x:`) |
| `$HOME/Gdrive/` | Personal Google Drive (rclone: `gdrive:`) |
| `$HOME/Work/` | Dev & prod code, infra, scripts |
| `$HOME/Pictures/` | Generated visuals, screenshots |
| `$HOME/Documents/` | Docs, PDFs, notes |
| `$HOME/Downloads/` | Temporary downloads |
| `$HOME/Videos/` | Recordings, screencasts |

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
| **Ephemeral token/secret exports** | before import into Vaultwarden/bw-env — then DELETE |
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
- **Exception:** if KπX explicitly requests a path, follow KπX
- **Exception:** `bw-env`/Vaultwarden exports follow their own rule (`/tmp/*.env` → import + delete)

### What does NOT go in `/tmp/`

- Business/project code, scripts that belong to a codebase → **in the repo**
- System configuration files → **`/etc/` or `~/.config/`**
- Long-term data → **`$HOME/Work/`, `$HOME/Gdrive_X/`, etc.**
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

**Every config file, service, asset, wrapper, system script that belongs to the KπX infrastructure must live in `.agents/` under the appropriate skill.**

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
| Tool scripts | phones.ksh, gws-profiles.zsh | `k-phones`, `k-google` |

### What does NOT go in `.agents/`

- Application code (projects) → `$HOME/Work/` or the repo
- Personal data → `$HOME/Gdrive*/` or `$HOME/Documents/`
- Temporary files → `/tmp/`

### Why

- **Single source of truth**: the asset is canonical, not a loose file
- **Versioned**: auditable, traceable (via `make audit`)
- **Deployable**: symlink on a new machine = everything portable
- **No duplication**: one asset, N symlinks

### Conditioned reflex

> **Before creating any config file, wrapper, systemd service, or system script → ask yourself: does a skill for this domain exist in `.agents/` ? If yes, the asset goes there. If no skill exists, is the domain broad enough to warrant a new one ? If not, place it in the closest parent skill.**

## Knowledge Base (k-qmd)
Load `k-qmd` before querying. Main collections: `techskills`, `presentation`, `agents`, `codex`, `gemini`, `copilot`, `vibe`. Always check `$HOME/Work/techskills/templates/` before creating new files from scratch.
