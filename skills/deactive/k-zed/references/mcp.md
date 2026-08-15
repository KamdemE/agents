# Zed — MCP (`context_servers`)

MCP servers for the **native** agent and forwarded (with limits) to ACP agents.

**Source of truth:** `$HOME/.config/zed/settings.json` → top-level `context_servers`.

## Schema (settings.json)

```json
{
  "context_servers": {
    "<server-id>": {
      "enabled": true,
      "remote": false,
      "settings": {}
    }
  }
}
```

- **`enabled`:** master switch.
- **`remote`:** HTTP/streamable MCP vs local stdio (see Zed MCP docs).
- **`settings`:** server-specific options (prefer env-backed secrets over plaintext keys).

## Per-Profile MCP (native agent only)

Inside `agent.profiles.<name>`:

```json
{
  "agent": {
    "profiles": {
      "colab": {
        "enable_all_context_servers": false,
        "context_servers": {
          "mcp-server-exa-search": {
            "tools": {
              "web_search_exa": true,
              "web_fetch_exa": true
            }
          }
        }
      }
    }
  }
}
```

- `enable_all_context_servers: true` — expose all enabled global servers.
- `false` + explicit `context_servers` — least-privilege tool surface per profile.

## Tool Permissions for MCP

Under `agent.tool_permissions.tools`, MCP tools use keys like `mcp:<server>:<tool>`:

```json
{
  "agent": {
    "tool_permissions": {
      "default": "confirm",
      "tools": {
        "mcp:github:create_pull_request": {
          "default": "deny"
        }
      }
    }
  }
}
```

Pattern-based `always_allow` / `always_deny` are less useful for MCP (empty input); prefer per-tool `default`.

Docs: [Tool Permissions](https://zed.dev/docs/ai/tool-permissions.html).

## Secrets (KπX pattern)

**Avoid** storing API keys in `settings.json` (sync, backup, and chat leakage risk).

Preferred patterns:

1. **Env var** referenced by MCP extension if supported.
2. **Login-shell stdio (custom server — not extension `settings`):**

```json
{
  "context_servers": {
    "my-mcp": {
      "source": "custom",
      "command": "zsh",
      "args": ["-l", "-c", "$HOME/.local/bin/my-mcp serve"],
      "env": {}
    }
  }
}
```

⚠️ Nesting `command`/`args` under `settings` applies only to **Zed extension** entries (e.g. `mcp-server-exa-search`). Custom binaries without an extension **must** use top-level `command`/`args` or Zed silently skips them (no `Zed.log` line).

## ACP Forwarding

Zed forwards enabled `context_servers` to Claude Agent, Codex, Gemini CLI over ACP.

| Transport | Reliability |
|-----------|-------------|
| Local stdio MCP | Generally works |
| Remote OAuth MCP | Known issues ([#54410](https://github.com/zed-industries/zed/issues/54410)) |

ACP agents **also** read native MCP config:

- Codex → `$HOME/.codex/config.toml` `[mcp_servers.*]`
- Gemini → extensions under `$HOME/Work/AI/gemini_mcps/` (see `k-gemini`)
- Claude → `~/.claude/` MCP config

Keep **one canonical list** per agent where possible; use Zed `context_servers` for editor-panel parity only.

## QMD Policy

Do not register QMD as an MCP in Zed. Use local CLI (`qmd`, `qmdr`) per `k-qmd`.

## Debugging

1. Confirm `enabled: true` in `context_servers`.
2. New agent thread after settings change.
3. Command Palette → `dev: open acp logs` for external agent MCP traffic.
4. Native agent: check agent panel tool list for expected `mcp:*` tools.
