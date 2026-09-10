# UV-First: Python Toolchain Rule

**All Python operations MUST use `uv`. System Python is read-only.**

## Allowed (uv-based)

| Command | Use case |
|---------|----------|
| `uv tool install <package>` | Install a CLI tool globally (e.g., basedpyright, jupyter-client) |
| `uv pip install <package>` | Install a package in the active venv |
| `uv run python3 <script>` | Run a script with uv-managed Python |
| `uv venv <path>` | Create a virtual environment (does NOT need python3-venv) |
| `uv tool upgrade --all` | Update all uv-installed tools |
| `uv python list` | List available Python versions managed by uv |

## Forbidden

| Action | Why |
|--------|-----|
| `pip install <package>` | Touches system Python or venv without uv. Use `uv pip install` instead. |
| `/usr/bin/python3 -m pip install` | Direct system Python modification. Never. |
| `sudo apt install python3-*` | System Python packages. Never. |
| `python3 -m venv` | Creates venv using system python3-venv which may be missing. Use `uv venv` instead. |

## Exception

Only if the user explicitly authorizes it. Never assume.
