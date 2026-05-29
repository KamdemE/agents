# Audit Commands — Quality & Deployment

> Mandatory commands to run before closing work. Enforced by session_guard hook.

## Kernel Audit

After any `$HOME/.agents/` change:
```bash
make -C $HOME/.agents audit     # Run structural + hook validation
make -C $HOME/.agents check     # Full check if available
```

ALWAYS run `make audit` and fix errors BEFORE proposing `git commit` + `make push`.

## Python & System Installs (GRAVÉ)

**NEVER** `pip install` / `pip uninstall` on system Python or global interpreter.

| DO | DON'T |
|---|---|
| Project: `uv init` + `uv add` + `uv run` | `pip install matplotlib numpy …` globally |
| CLI isolation: `uv tool install <pkg>` | `python3 -m pip install` outside venv |
| Quick script: `uv run --with <dep> script.py` | Reproduce locally what user requested in a web service |
| Dependency already documented: read `managing-python-dependencies` skill | Assume "not installed" authorizes global install |

## Makefile Standards

- Every project: `make push` pushes to ALL remotes simultaneously
- `make check`: lint + type-check
- `make audit`: structure validation (`.agents/` specific)
- Never use raw `git push origin` — breaks multi-remote invariant
- Always check `make help` first

## Browser Forms (GRAVÉ)

- Pre-fill: non-secret fields from `kpihx/references/identity.md` + `kpihx/references/legal.md`
- Never fill: passwords, access codes, OTP, CAPTCHA
- Wait: loop ~8–12s if KπX fills in; if nothing after ~3min → stop and ask
- Learning: KπX corrections on non-secret fields → update `kpihx`, not `k-browser`

## Post-Work Checklist

Before finalizing any project work:
1. `make audit` (or equivalent) — green
2. `make check` (lint + type check) — green
3. Tests must pass
4. `k-context/SKILL.md` updated: session log, active projects
5. Any touched `k-*` skills: version bumped, changelog updated
6. `make push` to all remotes

## MCP Protocol

- KπX MCPs: source in `$HOME/Work/AI/MCPs/`
- Transport: prefer HTTP (shared homelab endpoint). stdio as fallback only.
- Exception — mail-mcp: prefer stdio (attachments, full fidelity)
- Load `k-*` skill BEFORE any MCP tool call
- After any meaningful MCP outcome: update the matching skill immediately
- Cross-MCP: if you detect actionable info in mail → propose TickTick item
- Ownership: JS/TS MCPs → Bun-first; Python MCPs → uv-first; npm-global → third-party CLIs only
