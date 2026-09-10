# Package Management

| Language | Toolchain | Install pattern |
|----------|-----------|-----------------|
| Python | `uv` (`$HOME/.local/bin/uv`) | CLIs: `uv tool install --editable .` · Scripts: `uv run --with` |
| JS/TS (owned projects / MCP servers) | **Bun** when runtime-compatible | `bun add/run/build/test/publish` · `bun link / bun install -g` |
| JS tools (3rd party) | npm-global (`$HOME/.npm-global/`) | `npm install -g` for daily-driver CLIs |
| Node.js | fnm v24.18.0 | via `fnm install 24` — dynamic multishell, `--use-on-cd` |

**Never:** `pip install` globally · `npm install -g <local-path>` · hatchling/poetry/setuptools

npm global prefix: `$HOME/.npmrc → prefix=$HOME/.npm-global` (no EACCES, no sudo needed).

## System CLIs installed on this machine

**npm-global:**
| CLI | Install | Purpose |
|-----|---------|---------|
| `fd` | `npm i -g fd-find` | Telescope file-search backend |

**uv tool:**
| CLI | Install | Purpose |
|-----|---------|---------|
| `asciinema` | `uv tool install asciinema` | Terminal session recorder |

**Voice & Audio (k-whisper / k-piper):**
- Referenced in: **`k-ai`** (central AI inventory skill).
- Execution commands: `k-whisper` (Whisper.cpp Vulkan) and `k-piper` (Piper TTS C++).
- Reference guides: `references/whisper.md` and `references/piper.md` under `k-ai`.

Full CLI registry with routing to dedicated k-* skills: **`k-clis`**

## Alternative AI Shells (Purged / Historical)

In the past, alternative AI-native terminals were evaluated:
- **WaveTerm**: Evaluated and completely purged in August 2026. Configuration was originally at `$HOME/.config/waveterm/` with custom widgets.
- **Warp Terminal**: Evaluated as an alternative AI shell.

**Current Status**: Purged.  no longer uses these dedicated AI shells because the combination of **`tmux` + `opencode` + `nvim`** is much more flexible, lightweight, and offers superior developer control.

## npm-global prefix

`$HOME/.npmrc` → `prefix=$HOME/.npm-global` — no EACCES, no sudo needed for global installs.
