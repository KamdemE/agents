# Zed — settings.json

Live file: `$HOME/.config/zed/settings.json` (JSONC: `//` comments and trailing commas allowed).

Skill mirror (symlink, not a copy): `$HOME/.agents/skills/k-zed/assets/settings.json` → same path.

## Bootstrap symlink

```bash
"$HOME/.agents/skills/k-zed/scripts/sync_zed_settings.sh"
```

Re-run after moving the skill tree or if the link breaks.

## Structure map

| Key | Purpose |
|-----|---------|
| `agent.default_model` | Native agent default provider + model |
| `agent.favorite_models` | Pinned models in agent model picker (`[{ "provider", "model" }]`) |
| `agent.profiles` | Named tool+MCP+model bundles |
| `language_models.openai_compatible.<Name>` | Custom OpenAI-compatible providers |
| `context_servers` | MCP servers for native agent |
| `agent_servers` | ACP external agents (registry) |

Official docs: [LLM providers](https://zed.dev/docs/ai/llm-providers), [Agent settings](https://zed.dev/docs/ai/agent-settings).

## Venice provider (KπX)

- Provider key in settings: `"Venice"` under `language_models.openai_compatible`
- API: `https://api.venice.ai/api/v1`
- API key: env `VENICE_API_KEY` (never commit in git-tracked copies)
- Model IDs: use Venice `/v1/models` `id` field as `name` in `available_models`

### Curated Venice text models (2026-05-22)

| Display | Venice `id` | Context | Max output | Tools | Reasoning |
|---------|-------------|---------|------------|-------|-----------|
| GLM 5 Turbo | `z-ai-glm-5-turbo` | 200K | 32768 | yes | effort configurable |
| Qwen 3.6 Plus Uncensored | `qwen-3-6-plus` | 1M | 65536 | yes | built-in |
| GLM 4.7 Flash Heretic | `olafangensan-glm-4.7-flash-heretic` | 200K | 24000 | yes | effort configurable |
| Venice Uncensored 1.2 | `venice-uncensored-1-2` | 128K | 8192 | yes | no |
| Aion 2.0 | `aion-labs-aion-2-0` | 128K | 32768 | **no** | effort configurable |
| Gemma 4 Uncensored | `gemma-4-uncensored` | 256K | 8192 | yes | no |

`agent.favorite_models` lists the five new models plus `gemma-4-uncensored` for quick picker access.

Zed capabilities notes:

- Set `interleaved_reasoning: true` when Venice reports `supportsReasoning: true` (except where chat format differs).
- Set `tools: false` when Venice reports `supportsFunctionCalling: false` (Aion 2.0).
- Set `images: true` when `supportsVision: true`.

## Editing discipline

- Prefer editing the live file; the skill asset symlink reflects it immediately.
- After provider/model changes: new native agent thread (or restart Zed) so the picker reloads.
- If models do not appear: confirm `VENICE_API_KEY` in login shell; Zed may require UI “Add Provider” once to seed keychain (see Zed issue #56887).

## Related

- `setup.md` — AGENTS.md + skills symlinks
- `profiles.md` — Colab profile model binding
- `mcp.md` — `context_servers` shape
