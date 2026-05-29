# Edge CDP — Operational Reference

## Default (current)

Edge always launches with `--remote-debugging-port=9222`:
- Wrapper script: `/opt/microsoft/msedge/microsoft-edge` (patched)
- System .desktop: `/usr/share/applications/microsoft-edge.desktop` (patched)
- User .desktop: `~/.local/share/applications/microsoft-edge.desktop` (patched)

No separate agent profile needed. Uses default Edge profile (`~/.config/microsoft-edge/Default`).

## Verification

```bash
curl -s http://127.0.0.1:9222/json/version | jq '.Browser'
curl -s http://127.0.0.1:9222/json/list | jq '.[].title'
```

## MCP Config

```json
"chrome-agent": {
  "command": "zsh",
  "args": ["-l", "-c", "chrome-agent-mcp"]
}
```

## Deprecated (removed)

- `edge-agent.ksh` — removed
- `edge-agent.sh` — removed
- `kpihx-edge-automation` profile — deleted (1.1G)
- `scripts/bw-prelogin-check.sh` — removed
