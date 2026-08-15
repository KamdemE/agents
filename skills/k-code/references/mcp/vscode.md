# VS Code MCP Setup (Global and Profile)

This note defines a generic setup for MCP servers in VS Code.

## Config Files

- Global user config: `$HOME/.config/Code/User/mcp.json` (symlinked to `$HOME/.agents/skills/k-code/assets/mcp.json`)
- Profile-specific config: `$HOME/.config/Code/User/profiles/<profile-hash>/mcp.json`

If the active workspace is attached to a profile, VS Code reads that profile config. A server present only in the global file may not appear in the profile UI.

## Recommended Pattern

Use one source of truth:

1. Keep the canonical config in `$HOME/.agents/skills/k-code/assets/mcp.json` (symlinked to `$HOME/.config/Code/User/mcp.json`).
2. For profiles that must share exactly the same servers, make profile `mcp.json` a symlink to the global file.
3. If a profile needs custom servers, keep a dedicated profile file and document why.

## JSON Schema

Top-level key is `servers`.

```json
{
  "servers": {
    "example-http": {
      "type": "http",
      "url": "https://example.kpihx-labs.com/mcp"
    },
    "example-stdio--fallback": {
      "type": "stdio",
      "command": "zsh",
      "args": [
        "-l",
        "-c",
        "$HOME/.local/bin/example-mcp serve --fallback"
      ]
    }
  }
}
```

## HTTP Server Entry

Use when the MCP has an HTTPS endpoint.

```json
"name-mcp": {
  "type": "http",
  "url": "https://name.kpihx-labs.com/mcp"
}
```

## STDIO Server Entry (Fallback)

Use for local execution fallback.

Before using STDIO, install the MCP package with the manager that owns the binary.
For this workspace, owned JS/TS MCPs are Bun-first when runtime-compatible; Python MCPs are uv-first.
Package naming can vary by ecosystem, so check the package registry and the MCP's own docs.

```bash
uv tool install <pypi-package-name>
uv tool install --upgrade <pypi-package-name>

bun install -g <bun-package-name>
```

```json
"name-mcp--fallback": {
  "type": "stdio",
  "command": "zsh",
  "args": [
    "-l",
    "-c",
    "$HOME/.local/bin/name-mcp serve --fallback"
  ]
}
```

## Validation Checklist

1. Confirm active profile in `$HOME/.config/Code/User/globalStorage/storage.json`.
2. Confirm active `mcp.json` path (global vs profile).
3. Reload VS Code window.
4. In MCP UI, ensure each server is enabled and trusted.
5. If missing, inspect MCP output logs for startup errors.
