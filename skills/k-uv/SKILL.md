---
name: k-uv
description: >
  KπX UV/Python ecosystem — comprehensive inventory of uv tools, managed Python
  versions, virtual environments, and the uv-first philosophy governing all
  Python operations. Load before any Python install, uv tool management, venv
  audit, or Python environment debugging.
metadata:
  author: KpihX
  version: "1.6.2"
  scope: operations
---

# KπX — UV/Python Ecosystem

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Rules that enforce uv-first:**
> - `rules/uv-first.md` — All Python operations MUST use uv. Never pip. Never system Python.
> - `rules/audit-commands.md` — `uv` not `pip`. For standalone `.agents` work, propose `make check`; never run that kernel check without KπX's explicit request or validation. Project checks follow their own workflow.
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

### Code Intelligence (LOOM)

| Tool | Version | Binaries | Purpose |
|------|---------|----------|---------|
| `loom-tool` | v0.7.1 | `loom` (CLI only — `loom-mcp` binary exists but NOT used, no MCP since 2026-08-24) | Persistent code graph index — cross-session code search |

### Linting & Type Checking

| Tool | Version | Binaries | Purpose |
|------|---------|----------|---------|
| `ruff` | v0.16.0 | `ruff` | Fast Python linter + formatter (replaces flake8 + isort + black) |
| `pyright` | v1.1.411 | `pyright`, `pyright-langserver`, `pyright-python`, `pyright-python-langserver` | Python static type checker |

### MCP Servers (stdio)

| Tool | Version | Binaries | Purpose |
|------|---------|----------|---------|
| `hermes-agent` | v0.15.2 | `hermes`, `hermes-acp`, `hermes-agent` | Persistent memory daemon, cron-driven |
| `k-vpn` | v1.0.0 | `k-vpn` | VPN MCP server — KpihX-owned |
| `ts-proxy` | v1.1.0 | `ts-proxy` | Tailscale API + HITL proxy |

> **Purged tools** (`desk-mcp`, `k-mail-mcp`, `mail-mcp`, `mistral-vibe`, `tick-mcp`): see `references/purged.md` (kept for the record, never deleted).

### Language & Dev Tools

| Tool | Version | Binaries | Purpose |
|------|---------|----------|---------|
| `basedpyright` | v1.39.9 | `basedpyright`, `basedpyright-langserver` | Python type checker (fork of pyright) |
| `gnome-extensions-cli` | v0.11.0 | `gext`, `gnome-extensions-cli` | GNOME extensions manager CLI |
| `jupytext` | v1.19.3 | `jupytext`, `jupytext-config` | Jupyter notebook ↔ Markdown converter |
| `nbconvert` | v7.16.6 | `jupyter-dejavu`, `jupyter-nbconvert` | Jupyter nbconvert (notebook → PDF/HTML/slides) |
| `litellm` | v1.82.1 | `litellm`, `litellm-proxy` | Unified LLM proxy (100+ providers) |

### Media & AI

| Tool | Version | Binaries | Purpose |
|------|---------|----------|---------|
| `asciinema` | v2.4.0 | `asciinema` | Terminal session recorder (text-based `.cast`) |
| `ollama-ipex` | v0.2.2 | `ipex`, `ollama-ipex` | Ollama Intel Arc GPU extension |
| `tg` (deprecated) | v0.2.0 | `tg` | **Replaced by `tg-proxy`** — see `k-tg` skill. Deprecated, project directory removed. |
| `yt-dlp` | v2026.7.4 | `yt-dlp` | YouTube/video downloader |

---

## Virtual Environments

### Project venvs (all Python 3.12.12)

| Project | Path | Status |
|---------|------|--------|
| `O/engine` | `~/KpihX-Labs/O/engine/.venv` | Empty (no pip packages) |
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

### Package Publication (PyPI)

Python packages inside the KpihX-Labs workspace are published using `uv publish`.

*   **If a Makefile exists:** Run the publication command inside a secure subshell using the `with-env` helper:
    ```bash
    with-env make uv-publish
    ```
*   **If no Makefile exists:** Create the `uv-publish` target in the project's `Makefile`:
    ```makefile
    uv-build:
    	@rm -rf dist/
    	@$(UV) build

    uv-publish: uv-build
    	@if [ -z "$$UV_PUBLISH_TOKEN" ]; then \
    		echo "❌ Error: UV_PUBLISH_TOKEN is not set. Run with: with-env make uv-publish"; \
    		exit 1; \
    	fi \
    	@$(UV) publish
    ```

---

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-08-24 | [COLAB] | v1.6.2 — Scoped the explicit-approval policy to standalone `.agents` kernel work; project checks retain their own workflow. |
| 2026-08-14 | [COLAB] | v1.6.0 — **MCP Servers table cleanup**: removed `bw-proxy` row (bw-mcp/bw-admin purged 2026-08-14; secrets no longer injected via bw). |
| [SUMMARY] | — | v1.6.1 superseded broad approval-policy wording · v1.5.0 gnome-extensions-cli · v1.4.0 purged MCP tools · v1.3.0 legacy table removal (→ `references/log.md`) · v1.2.0 and older copied to `references/log.md` |
