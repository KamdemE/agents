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

**Speech-to-text (whisper-ctranslate2):**
- Installed CLI: `whisper-ctranslate2` (0.5.7)
- Intel Arc note: exposes `cpu`/`cuda`; no Arc backend flag yet — use optimized CPU settings
- Default model: `distil-large-v3` with `--device cpu --compute_type int8 --vad_filter true`

Full CLI registry with routing to dedicated k-* skills: **`k-clis`**

## WaveTerm widgets

Config: `$HOME/.config/waveterm/widgets.json` — all widgets load their own environment.

## npm-global prefix

`$HOME/.npmrc` → `prefix=$HOME/.npm-global` — no EACCES, no sudo needed for global installs.
