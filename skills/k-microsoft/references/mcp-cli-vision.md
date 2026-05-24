# MCP + CLI unification (Microsoft) — pointer

## Reference implementations (KπX)

| Project | Path | Pattern |
|---------|------|---------|
| **ts-proxy** | `$HOME/Work/KpihX-Labs/Fluid/ts_proxy/` | JSON payload CLI + HITL + documented MCP direction |
| **whats_proxy** | `$HOME/Work/KpihX-Labs/Fluid/whats_proxy/` | CLI and HTTP share one API surface |

## Target end state (Microsoft)

1. **`m365`** stays the **content** source of truth (+ `m365 request` for full Graph).
2. **`az`** stays the **Azure container** source of truth.
3. Optional **ms-365-mcp-server** only if Cursor needs typed MCP tools without shell.
4. Long-term: KπX bridge with **one schema** for CLI + MCP (approve sends/shares via HITL like ts-proxy).

## Until built

- Agents invoke **`m365`** / **`az`** in shell — no mandatory M365 MCP.
