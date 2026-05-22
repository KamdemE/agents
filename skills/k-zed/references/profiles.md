# Zed — Native Agent Profiles

Profiles configure the **built-in Zed agent** only. External ACP agents ignore them.

**Source of truth:** `$HOME/.config/zed/settings.json` → `agent.profiles`, `agent.default_profile`, `agent.default_model`, `agent.tool_permissions`.

## Profile Object

```json
{
  "agent": {
    "default_profile": "colab",
    "default_model": {
      "provider": "openai-subscribed",
      "model": "gpt-5.4",
      "enable_thinking": true,
      "effort": "medium"
    },
    "profiles": {
      "colab": {
        "name": "Colab",
        "default_model": {
          "provider": "Venice",
          "model": "gemma-4-uncensored",
          "enable_thinking": false
        },
        "tools": {
          "read_file": true,
          "grep": true,
          "thinking": true,
          "edit_file": true,
          "terminal": true,
          "spawn_agent": false
        },
        "enable_all_context_servers": false,
        "context_servers": { }
      }
    },
    "tool_permissions": {
      "default": "confirm"
    }
  }
}
```

## Built-In Profile Ideas (product defaults)

Zed ships concepts like Write / Ask / Minimal in UI — custom profiles in `settings.json` override or extend behavior via explicit `tools` maps.

| Intent | Tool pattern |
|--------|----------------|
| Read-only exploration | `read_file`, `grep`, `list_directory`, `diagnostics`, `thinking`; deny `edit_file`, `terminal` |
| Full agent | Most tools `true`; `spawn_agent: false` if avoiding opaque delegation |
| Colab (KπX) | **Single** profile: read + write tools ON, behavior controlled by **rules + confirm** |

## Colab Profile (KπX — one profile, not two)

**Anti-pattern:** `colab` (read) + `colab-write` (execute) → recreates Plan then Execute.

**Pattern:**

1. One `colab` profile with read and write tools enabled.
2. `agent.tool_permissions.default: "confirm"` (and per-tool `always_deny` for destructive shell).
3. Colab protocol in `$HOME/.config/zed/AGENTS.md` or skill `k-colab` (iceberg descent, STOP on ambiguity).
4. Override Zed default autonomy lines in rules explicitly (“do not keep going when uncertain”).

### Minimum tools for real work

A profile with only `diagnostics`, `create_directory`, `copy_path`, `apply_code_action` cannot run an agent loop — include at least:

- `thinking`, `read_file`, `grep`, `list_directory`, `find_path`, `diagnostics`
- For execution after user GO: `edit_file`, `terminal` (with confirmations)

## Model Selection

| Field | Meaning |
|-------|---------|
| `agent.default_model` | Fallback for profiles without `default_model` |
| `profiles.<id>.default_model.provider` | Provider id (`openai-subscribed`, `Venice`, …) |
| `profiles.<id>.default_model.model` | Model id string |
| `enable_thinking` | Reasoning mode when provider supports it |

Custom OpenAI-compatible providers: `language_models.openai_compatible.<Provider>` — profiles reference `<Provider>` as `provider`.

## Tool Permissions (interactive gate)

```json
{
  "agent": {
    "tool_permissions": {
      "default": "confirm",
      "tools": {
        "terminal": {
          "default": "confirm",
          "always_deny": [
            { "pattern": "rm\\s+-rf" },
            { "pattern": "sudo\\s" }
          ]
        },
        "edit_file": { "default": "confirm" },
        "delete_path": { "default": "confirm" }
      }
    }
  }
}
```

Precedence: built-in security → `always_deny` → `always_confirm` → `always_allow` → tool `default` → global `default`.

This is the practical “pause before act” layer when Zed has no blocking `ask_user` tool.

## Feature-Specific Models

Optional keys under `agent` (fallback to `default_model`):

- `inline_assistant_model`
- `commit_message_model`
- `thread_summary_model`

See [Agent Settings](https://zed.dev/docs/ai/agent-settings.html).

## UI Access

- Agent panel → profile selector (top).
- Command Palette → `agent: open settings`.

After editing `settings.json`, prefer a **new thread** to pick up profile/tool changes.
