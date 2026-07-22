# Audit Commands

> Mandatory commands before closing any work.

## Kernel Audit (after ANY `~/.agents/` change)
```bash
make -C $HOME/.agents audit     # Structural + hook validation
make -C $HOME/.agents check     # Full check if available
```
Run `make audit` and fix errors BEFORE proposing commit + push.

## Python & System (GRAVÉ)
**NEVER** `pip install` on system Python.

| DO | DON'T |
|----|-------|
| `uv init` + `uv add` + `uv run` | `pip install <pkg>` globally |
| `uv tool install <pkg>` | `python3 -m pip install` outside venv |
| `uv run --with <dep> script.py` | Reproduce locally what was asked on a remote service |

## Makefile Standards
- Every project: `make push` pushes to ALL remotes simultaneously
- `make check`: lint + type-check
- `make audit`: structure validation (`.agents/` specific)
- Never `git push origin` — breaks multi-remote invariant
- Check `make help` first

## Post-Work Checklist
1. `make audit` — green
2. `make check` (lint + type check) — green
3. Tests pass
4. k-context updated: session log, active projects
5. Touched skills: version bumped, changelog updated
6. `make push` to all remotes

## MCP Protocol
- Source: `$HOME/Work/AI/MCPs/`
- Transport: prefer HTTP (shared homelab). stdio fallback (mail-mcp)
- Load `k-*` skill BEFORE any MCP tool call
- After meaningful MCP outcome → update matching skill
- JS/TS MCPs → Bun; Python → uv; npm-global → third-party CLIs only
