# MCP + CLI unification (Google) — pointer

## Reference implementations ()

| Project | Path | Pattern |
|---------|------|---------|
| **ts-proxy** | `$HOME/Work/Labs/Fluid/ts_proxy/` | Payload-driven CLI (`do` + JSON), introspection, HITL, future MCP parity |
| **whats_proxy** | `$HOME/Work/Labs/Fluid/whats_proxy/` | Same API via **CLI + HTTP** (port 1140) — zero logic drift |

Read `ts_proxy/CONTRACT.md` and `whats_proxy/CONTRACT.md` for the **0% hardcode · 100% transparency** contract.

## Target end state (Google)

1. **`gws`** remains the **content** escape hatch (Discovery-wide).
2. Optional **Workspace MCP** exposes a **stable tool surface** for agents (subset of APIs).
3. Long-term: a -owned bridge (or hardened fork) where **CLI commands and MCP tools share one schema** — like `whats_proxy`’s unified `/do` namespace.

## Brainstorm (full scope)

`$HOME/.agents/skills/k-context/references/google-workspace-full-mcp-vision.md`

## Until built

- Agents: **shell `gws`** for content, **`gcloud`** for container.
- Do not block on MCP install for Google Workspace automation.
