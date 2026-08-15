# MCP Config Format (OpenCode — JSONC)

OpenCode MCP servers are configured under the top-level `mcp` key in `opencode.jsonc`.

Local (stdio-equivalent) server:

```json
{
  "mcp": {
    "browser": {
      "type": "local",
      "command": ["browser-mcp"],
      "enabled": true,
      "timeout": 60000
    }
  }
}
```

> **Note (2026-08-14):** the former `mail_fallback` / `mail-mcp` example was removed with the MCP purge. `*-proxy` CLIs (mail-proxy, tick-proxy, tg-proxy, ts-proxy, bw-proxy, whats-proxy) are real CLIs and are configured here as `local` servers if a proxy exposes an MCP endpoint; otherwise they are invoked directly. See `k-uv/references/purged.md` and `k-node/references/purged.md`.

Remote HTTP server:

```json
{
  "mcp": {
    "exa": {
      "type": "remote",
      "url": "https://mcp.exa.ai/mcp",
      "oauth": false,
      "enabled": true
    }
  }
}
```

Remote bearer token via env variable:

```json
{
  "mcp": {
    "n8n_homelab": {
      "type": "remote",
      "url": "https://n8n.kpihx-labs.com/mcp",
      "headers": {
        "Authorization": "Bearer {env:N8N_HOMELAB_API_KEY}"
      },
      "enabled": false
    }
  }
}
```
