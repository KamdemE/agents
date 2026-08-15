# Zed — External Agents (ACP / `agent_servers`)

Bridge CLI agents into the Zed Agent Panel via [Agent Client Protocol (ACP)](https://agentclientprotocol.com/).

**Source of truth:** `$HOME/.config/zed/settings.json` → `agent_servers`.

## Registry Entries (KπX example)

```json
{
  "agent_servers": {
    "codex-acp": { "type": "registry" },
    "gemini": { "type": "registry" },
    "cursor": { "type": "registry" },
    "github-copilot-cli": { "type": "registry" },
    "opencode": { "type": "registry" },
    "mistral-vibe": { "type": "registry" },
    "kimi": { "type": "registry" },
    "qwen-code": { "type": "registry" },
    "deepagents": { "type": "registry" }
  }
}
```

Install/update: Command Palette → `zed: acp registry` or Agent panel → **Add Agent**.

Registry build wins over legacy agent-server extensions when both exist.

## Custom Agent

```json
{
  "agent_servers": {
    "My Agent": {
      "type": "custom",
      "command": "node",
      "args": ["$HOME/projects/agent/index.js", "--acp"],
      "env": {}
    }
  }
}
```

## Registry Overrides (`env`, model)

```json
{
  "agent_servers": {
    "codex-acp": {
      "type": "registry",
      "env": {
        "CODEX_API_KEY": "use-env-not-file-when-possible"
      },
      "default_model": {
        "provider": "openai",
        "model": "gpt-5"
      }
    },
    "claude-acp": {
      "type": "registry",
      "env": {
        "CLAUDE_CODE_EXECUTABLE": "/optional/override/path"
      }
    }
  }
}
```

## Configuration Boundaries

| Setting | Native Zed agent | ACP external agent |
|---------|------------------|---------------------|
| `agent.profiles` | ✅ | ❌ |
| `agent.tool_permissions` | ✅ | ❌ (agent UI prompts) |
| Zed Rules Library / project `.rules` | ✅ | ❌ |
| `context_servers` MCP | ✅ | ✅ forwarded (stdio best) |
| `agent_servers.*.env` | N/A | ✅ |
| `agent_servers.*.default_model` | N/A | ✅ (where supported) |

### What each bridge reads natively

| Agent | Config home | Kernel file |
|-------|-------------|-------------|
| **codex-acp** | `$HOME/.codex/config.toml` | `AGENTS.md` via Codex |
| **gemini** | `$HOME/.gemini/` | `GEMINI.md` |
| **cursor** | `$HOME/.cursor/` | rules, `cli-config.json` |
| **github-copilot-cli** | `$HOME/.copilot/` | `copilot-instructions.md` |

Authentication in Zed is **separate** from Zed hosted models:

- Codex: prompt on first thread; `/logout` to switch
- Claude Agent: `/login` in thread (not Zed Anthropic key)
- Gemini: OAuth in CLI or `GEMINI_API_KEY` / Zed Google provider passthrough

## Keyboard Shortcut (new external thread)

`$HOME/.config/zed/keymap.json`:

```json
[
  {
    "bindings": {
      "ctrl-alt-g": [
        "agent::NewExternalAgentThread",
        { "agent": { "custom": { "name": "gemini" } } }
      ],
      "ctrl-alt-o": [
        "agent::NewExternalAgentThread",
        { "agent": { "custom": { "name": "codex-acp" } } }
      ]
    }
  }
]
```

Registry names must match `agent_servers` keys (`gemini`, `codex-acp`, `claude-acp`, `cursor`, …).

## Cursor via Zed

- Registry id: `cursor` (managed adapter).
- Cursor runtime config: `$HOME/.cursor/cli-config.json`, MCP in Cursor settings — see `k-code/references/cursor.md`.
- Zed does not inject KπX `AGENTS.md` into Cursor threads; Cursor reads its own rules/skills.

## Debugging

- Command Palette → `dev: open acp logs` — JSON-RPC traffic between Zed and agent.
- Attach log excerpts when filing Zed issues on ACP agents.

## Hub Usage (KπX)

| Task | Prefer |
|------|--------|
| Quick in-repo edit + Zed tools | Native agent + profile |
| Full Codex sandbox / hooks / MCP TOML | `codex-acp` thread |
| Gemini extensions / `GEMINI.md` | `gemini` thread |
| Cursor-specific subagents | `cursor` thread |

Keep one kernel in `$HOME/.agents/AGENTS.md`; each runtime symlink or imports it in its own format (`k-codex`, `k-gemini`, `k-zed`).
