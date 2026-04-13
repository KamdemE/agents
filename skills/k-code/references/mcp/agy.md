# Antigravity (AGY) MCP Setup

MCPs for Antigravity are configured differently from Gemini CLI or other standard platforms. Antigravity uses a dedicated JSON file to register its MCP servers.

## Configuration File
**Path:** `$HOME/.gemini/antigravity/mcp_config.json`

## Installation Process

To install an MCP server for Antigravity, add an entry to the `mcpServers` object in the configuration JSON file.

### Required Format
The structure of an AGY MCP entry looks like this:

**For STDIO:**
```json
{
  "mcpServers": {
    "server-name-stdio": {
      "command": "/path/to/executable",
      "args": ["arg1", "arg2"],
      "env": {
        "ENV_VAR_NAME": "value"
      },
      "disabled": false
    }
  }
}
```

**For HTTP (SSE):**
```json
{
  "mcpServers": {
    "server-name-http": {
      "serverUrl": "https://example.com/mcp",
      "headers": {
        "Authorization": "Bearer <TOKEN>"
      },
      "disabled": false
    }
  }
}
```

### Steps to Add an MCP
1. **Open the Configuration File:** Read `$HOME/.gemini/antigravity/mcp_config.json`.
2. **Add the Definition:** Add a new key under `mcpServers` corresponding to the server name.
3. **Specify Transport & Target:**
    - For **STDIO**: Provide the absolute path to the executable as the `command`, and any required parameters as `args` (list of strings).
    - For **HTTP**: Provide the full address in `"serverUrl"`. Optionally add `"headers"` if authentication is required.
4. **Environment Variables (Optional):** If the MCP requires secrets or specific variables, add them to the `env` object.
5. **Disabled Flag (Optional):** You can set `"disabled": true` to temporarily disable the server without deleting the configuration.
6. **Save Changes:** Ensure the JSON remains perfectly formatted. AGY reads this file directly to load available tools.

**Rule:** Always write absolute paths for `command`. Do not rely on relative paths or implicitly inherited environment paths for the command executable.
