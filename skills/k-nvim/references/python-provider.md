# Python Provider — UV-Nvim Venv

All Python dependencies required by nvim plugins live in a single uv-managed virtualenv.
No system Python is ever touched. No pip is ever used. Everything goes through uv.

## Architecture

```
k-nvim/assets/uv-nvim/pyproject.toml     ← Source of truth (list of Python packages)
    │ symlink
    ▼
~/.local/share/nvim/uv-nvim/pyproject.toml
    │
    ▼ uv venv + uv sync
~/.local/share/nvim/uv-nvim/.venv/bin/python3  ← Python binary used by nvim
    │ g:python3_host_prog (init.lua)
    ▼
nvim Python provider (all plugins)
```

## Dependencies (from pyproject.toml)

| Package | Required by | Role |
|---------|-------------|------|
| `pynvim` | All nvim Python plugins | Neovim Python host provider. Every plugin that uses Python communicates via pynvim. Essential. |
| `jupyter-client` | molten-nvim | Jupyter kernel for running Python code inside nvim cells. Without it: Molten ERROR "Required python module jupyter-client not found". |

## Management commands

```bash
# Create or recreate the venv from scratch
cd ~/.local/share/nvim/uv-nvim && uv venv && uv sync

# Add a new dependency
cd ~/.local/share/nvim/uv-nvim && uv add <package> && uv sync

# Upgrade all dependencies
cd ~/.local/share/nvim/uv-nvim && uv sync --upgrade

# List installed packages
cd ~/.local/share/nvim/uv-nvim && uv pip list
```

## How init.lua connects to this venv

```lua
vim.g.python3_host_prog = vim.fn.expand("$HOME")
  .. "/.local/share/nvim/uv-nvim/.venv/bin/python3"
```

This tells nvim to use the Python interpreter from the uv venv as its Python provider. Every Python-based nvim plugin (molten, jupytext, telescope extensions, etc.) will use this Python and find all installed packages.

## Why this approach

- **Zero system Python touch.** `/usr/bin/python3` is never modified, never called by nvim.
- **Zero pip.** `pyproject.toml` + `uv sync` replaces `pip install` entirely.
- **Zero python3-venv dependency.** uv creates its own virtualenvs without needing the Ubuntu system package.
- **Single source of truth.** All Python packages for nvim are declared in one file, in version control.
- **Reproducible.** `uv sync` guarantees the same package versions across machines.
- **Trivially deleteable.** `rm -rf ~/.local/share/nvim/uv-nvim` removes everything, no system residue.
