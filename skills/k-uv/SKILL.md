---
name: k-uv
description: >
  KπX UV/Python ecosystem — comprehensive inventory of uv tools, managed Python
  versions, virtual environments, and the uv-first philosophy governing all
  Python operations. Load before any Python install, uv tool management, venv
  audit, or Python environment debugging.
metadata:
  author: KpihX
  version: "1.0.0"
  scope: operations
---

# KπX — UV/Python Ecosystem

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Rules that enforce uv-first:**
> - `rules/uv-first.md` — All Python operations MUST use uv. Never pip. Never system Python.
> - `rules/audit-commands.md` — `uv` not `pip`. `make audit` after `.agents/` changes.
> - `rules/file-governance.md` — Single source of truth, `.agents/` centralization.

> **Related skills:** `k-project` (project init with uv) · `k-ubuntu` (uv tool table per machine) · `k-nvim` (uv-nvim Python provider venv) · `k-clis` (CLI registry routing) · `k-hermes` (uv tool hermes-agent extra deps) · `k-final` (`uv tool install --editable .` in closure)

---

## Philosophy — UV-First

**No pip, no pyenv, no system Python modifications. Ever.**

| Context | Rule |
|---------|------|
| **CLI tools** | `uv tool install <pkg>` — each tool gets its own isolated venv |
| **Projects** | `uv init --package` + `uv add` + `uv sync` — project-local `.venv` |
| **Scripts** | `uv run --with <pkg>` or `uv run` from project root |
| **System Python** | NEVER touch `/usr/bin/python3` — it is read-only (PEP 668 enforced) |
| **pip** | NEVER — `pip3` is system-locked by PEP 668 |
| **pyenv** | PURGED — all tools migrated to uv |

**One exception:** `--break-system-packages` for cleaning up legacy pip-installed packages from user site (`~/.local/lib/`). This is a **migration tool only** — never for new installs.

---

## UV Version & Configuration

| Property | Value |
|----------|-------|
| **Binary** | `~/.local/bin/uv` |
| **Version** | `uv 0.10.3` |
| **Cache** | `~/.cache/uv/` |
| **Python downloads** | `~/.local/share/uv/python/` |
| **Tools** | `~/.local/share/uv/tools/` |
| **No config file** | `~/.config/uv/uv.toml` does not exist — pure defaults |

---

## Python Versions

### System (read-only)

| Version | Path | Installed via |
|---------|------|---------------|
| Python 3.14.4 | `/usr/bin/python3.14` → `/usr/bin/python3` | Ubuntu 26.04 apt |

### Managed by uv

| Version | Path |
|---------|------|
| Python 3.12.12 | `~/.local/share/uv/python/cpython-3.12.12-linux-x86_64-gnu/` |
| Python 3.11.14 | `~/.local/share/uv/python/cpython-3.11.14-linux-x86_64-gnu/` |

Python 3.12.12 is the default uv-managed Python (used by all project venvs and uv tools).

### Available for download

```bash
uv python install 3.10    # 3.10.19
uv python install 3.13    # 3.13.12
uv python install 3.15    # 3.15.0a6 (pre-release)
uv python install pypy     # PyPy 3.11, 3.10, 3.9, 3.8
uv python install graalpy  # GraalPy 3.12, 3.11, 3.10, 3.8
```

---

## UV Tools — Complete Inventory

All tools are installed via `uv tool install`. Each lives in `~/.local/share/uv/tools/<name>/` and exposes binaries in `~/.local/bin/`.

### MCP Servers (stdio)

| Tool | Version | Binaries | Purpose |
|------|---------|----------|---------|
| `bw-proxy` | v3.2.0 | `bw-proxy` | Bitwarden Vaultwarden proxy — AI-blind auth proxy |
| `desk-mcp` | v0.2.1 | `desk-mcp` | Desktop environment MCP server |
| `hermes-agent` | v0.15.2 | `hermes`, `hermes-acp`, `hermes-agent` | Persistent memory daemon, cron-driven |
| `k-mail-mcp` | v0.2.4 | `mail-admin`, `mail-mcp` | Mail MCP server (Zimbra) — KpihX-owned |
| `k-vpn` | v1.0.0 | `k-vpn` | VPN MCP server — KpihX-owned |
| `mail-mcp` | v0.2.0 | `mail-admin`, `mail-mcp` | Mail MCP server (older, keep for compatibility) |
| `mistral-vibe` | v2.21.0 | `vibe`, `vibe-acp` | VIBE agent runtime — Mistral model |
| `tick-mcp` | v0.2.0 | `tick-admin`, `tick-mcp` | TickTick MCP server |
| `ts-proxy` | v1.1.0 | `ts-proxy` | Tailscale API + HITL proxy |

### Language & Dev Tools

| Tool | Version | Binaries | Purpose |
|------|---------|----------|---------|
| `basedpyright` | v1.39.9 | `basedpyright`, `basedpyright-langserver` | Python type checker (fork of pyright) |
| `jupytext` | v1.19.3 | `jupytext`, `jupytext-config` | Jupyter notebook ↔ Markdown converter |
| `nbconvert` | v7.16.6 | `jupyter-dejavu`, `jupyter-nbconvert` | Jupyter nbconvert (notebook → PDF/HTML/slides) |
| `litellm` | v1.82.1 | `litellm`, `litellm-proxy` | Unified LLM proxy (100+ providers) |

### Media & AI

| Tool | Version | Binaries | Purpose |
|------|---------|----------|---------|
| `asciinema` | v2.4.0 | `asciinema` | Terminal session recorder (text-based `.cast`) |
| `ollama-ipex` | v0.2.2 | `ipex`, `ollama-ipex` | Ollama Intel Arc GPU extension |
| `piper-tts` | v1.4.2 | `piper` | Local neural text-to-speech (TTS) |
| `tg` | v0.2.0 | `tg` | Telegram CLI — Telethon-based |
| `whisper-ctranslate2` | v0.5.7 | `whisper-ctranslate2` | Local speech-to-text (Whisper + CTranslate2) |
| `yt-dlp` | v2026.7.4 | `yt-dlp` | YouTube/video downloader |

### Previously removed

| Tool | Reason | Date |
|------|--------|------|
| `colab` | KpihX-owned project, installed editable from `~/KpihX-Labs/colab/` | 2026-07-24 |
| `k-flow` | KpihX-owned project, source at `~/Work/AI/flow/` | 2026-07-24 |
| `powerpoint` | MCP server for PPTX generation | 2026-07-24 |
| `grip`, `huggingface-hub`, `ipynb-pdf`, `kpihx-ai`, `kpihx-todo`, `viperx`, `wayland-mcp` | Purged in k-optim pass | 2026-05-31 |

---

## Virtual Environments

### Project venvs (all Python 3.12.12)

| Project | Path | Status |
|---------|------|--------|
| `O/engine` | `~/KpihX-Labs/O/engine/.venv` | Empty (no pip packages) |
| `AI/oriyama` | `~/KpihX-Labs/AI/oriyama/.venv` | Empty |
| `Fluid/ts_proxy` | `~/KpihX-Labs/Fluid/ts_proxy/.venv` | Empty |
| `colab` | `~/KpihX-Labs/colab/.venv` | Has deps via `uv sync` |
| `test` | `~/KpihX-Labs/test/.venv` | Empty |

### Dedicated venvs

| Venv | Path | Python | Contents |
|------|------|--------|----------|
| **nvim** | `~/.local/share/nvim/uv-nvim/.venv` | 3.12.12 | 28 packages: pynvim, jupyter-client, cairosvg, pyzmq, etc. |
| **antigravity** | `~/.local/share/uv/antigravity-env` | 3.12.12 | 43 packages: google-antigravity, google-genai 2.14.0, google-auth, mcp, etc. |

### k-meta scripts venv

`~/KpihX-Labs/.agents/skills/k-meta/scripts/.venv` — Python 3.12.12 via uv.

---

## Migration History

> **Full operation log with detailed tables:** `k-ubuntu/references/log.md`

This skill is the **inventory** — what exists now. For the record of **what was removed, when, and why** (pip purges, tool migrations, apt removals), see the Ubuntu workstation's operation log at `k-ubuntu/references/log.md`.

Key migrations:
- **2026-07-24** — Global pip purge: manim, rich, google-antigravity/genai/auth, pynvim (apt), yt-dlp (→ uv tool). See `k-ubuntu/references/log.md` for full table.
- **2026-05-31** — UV tool purge: 7 unused tools removed (grip, huggingface-hub, etc.) in k-optim pass. See `k-context/references/log.md`.

---

## Key Commands Reference

### UV Tool management

```bash
uv tool list                    # List all tools
uv tool install <pkg>           # Install a new tool
uv tool install --force <pkg>   # Overwrite if binary exists
uv tool install --editable .    # Install local project in dev mode
uv tool install --reinstall <pkg>  # Reinstall
uv tool uninstall <pkg>         # Remove
uv tool list --show-paths       # Show with install paths
```

### UV Python management

```bash
uv python list                  # List all available Pythons
uv python list --only-installed  # Only installed ones
uv python install <version>     # Download + install a Python
uv python find                  # Show the Python uv resolves by default
```

### UV Venv management

```bash
uv venv                         # Create .venv in current dir
uv venv ~/.local/share/uv/<name>  # Create named venv elsewhere
uv pip list                     # List packages in current venv
uv pip list --python <path>     # List packages in specific venv
uv sync                         # Sync from pyproject.toml
uv add <pkg>                    # Add dependency + sync
```

### Health checks

```bash
uv tool list --show-paths       # Verify all tools
which <tool> && <tool> --version  # Check a specific tool
uv python list --only-installed  # Verify Pythons
# Check project venvs:
for d in ~/KpihX-Labs/*/; do [ -f "$d/.venv/bin/python" ] && echo "$d"; done
```

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-07-24 | [OPENCODE] | v1.0.0 — Created k-uv skill. Comprehensive inventory of uv tools (19), managed Pythons (2), project venvs (5), dedicated venvs (2). Documents uv-first philosophy, migration history (moved to `k-ubuntu/references/log.md`), and key commands. |
| [SUMMARY] | — | v1.0.0 — Created on 2026-07-24. |
