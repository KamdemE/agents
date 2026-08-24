# Audit Commands

> Mandatory commands before closing any work.

## Kernel Validation (after ANY `~/.agents/` change)
```bash
make -C $HOME/.agents check     # Full validation (Ruff, Pyright, Shellcheck, Audit)
```
This approval rule applies **only to `$HOME/.agents`**: after a relevant kernel change, **propose** `make check` and explain its scope. **Never run the kernel check unless KπX has explicitly requested it or explicitly validated its execution in the current conversation.** Once approved, run `make check` exactly and fix all findings before proposing commit + push. Project repositories run their project checks according to their own workflow.

## Python & System (GRAVÉ)
**NEVER** `pip install` on system Python.

| DO | DON'T |
|----|-------|
| `uv init` + `uv add` + `uv run` | `pip install <pkg>` globally |
| `uv tool install <pkg>` | `python3 -m pip install` outside venv |
| `uv run --with <dep> script.py` | Reproduce locally what was asked on a remote service |

## Makefile Standards
- Every project: `make push` pushes to ALL remotes simultaneously
- `make check`: full lint, type check, shell script analysis, and structural validation
- Never `git push origin` — breaks multi-remote invariant
- Check `make help` first

## Post-Work Checklist
1. For `$HOME/.agents`: propose `make check`; run it only with KπX's explicit approval — green
2. Tests pass
3. k-context updated: session log, active projects
5. Touched skills: version bumped, changelog updated
6. `make push` to all remotes
