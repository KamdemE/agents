---
name: k-openclaw
description: >
  Archived OpenClaw retrospective — deactivated runtime notes, failure modes, and KπX-specific
  return of experience after full local purge on 2026-04-04.
license: private
metadata:
  author: KpihX
  version: "3.0.0"
  scope: agent-runtime
  target-agent: openclaw
allowed-tools: Bash, Read, Write, Edit
---

# Archived Runtime — OpenClaw

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Status

- **State:** deactivated and fully purged from the workstation on 2026-04-04
- **Only allowed trace:** this archived skill under `$HOME/.agents/skills/deactive/k-openclaw/`
- **Do not recreate lightly:** any future reintroduction must start as a fresh evaluation, not from old local assumptions

## Why It Was Retired

- the runtime added too much orchestration fragility on top of otherwise-usable local Ollama models
- short local interactions regularly degraded into hallucination, false tool JSON, or polluted system-message loops
- compaction safeguards and system metadata leaked into the user-visible conversation too often to be acceptable
- the only promising free external fallback tested here (`mistral-small-latest`) reached the provider but failed through the runtime with `422 status code (no body)`
- the maintenance cost became higher than the value compared with direct `ollama run` and the planned `k-ai` path

## KπX Return Of Experience

- local model quality must be judged inside the target runtime, not in isolation; a decent model can become poor inside an unstable orchestrator
- hidden system prompts, compaction messages, and advisory-only tool surfaces are enough to ruin a CLI agent UX even when the base model is acceptable
- external-provider compatibility through a generic OpenAI-style adapter is not guaranteed; a reachable API key does not mean the runtime/provider pair is usable
- for KπX on this Ubuntu machine, the pragmatic split is: `ollama run` for direct/simple work, `k-ai` for the sovereign agent stack, no OpenClaw in the active toolchain
- OpenClaw is not just the main binary — it ships a full ecosystem: `clawhub`/`clawdhub` (pnpm, package registry at `clawhub.ai`), `mcporter` (pnpm, MCP config manager), and `nanoclaw` (MCP filesystem server with `mount-allowlist.json`); all four must be purged together
- pnpm interdependency trap: removing `clawhub` caused pnpm to auto-install `mcporter 0.7.3` — always verify `pnpm list -g` after partial uninstall, then explicitly `pnpm remove -g mcporter`

## Config Restored 2026-05-31

After a session that partially broke the gateway, the config was restored to a clean state:

### Current Config
| Field | Value |
|-------|-------|
| **Default model** | `opencode-go/deepseek-v4-flash` |
| **Fallback** | `opencode-go/deepseek-v4-pro` |
| **OpenRouter** | `openrouter/auto` |

### Key Config Files
| File | Role |
|------|------|
| `~/.config/openclaw/gateway.env` | Systemd-loaded env vars: API keys for Mistral, OpenAI, OpenCode, OpenRouter, Venice, Exa, Google |
| `~/.openclaw/.env` | Secondary env file (not loaded by systemd, but read by OpenClaw) |
| `~/.openclaw/openclaw.json` | Main config - providers, models, agents, permissions |

### Config Details
| Field | Value |
|-------|-------|
| **Default model** | `opencode-go/mimo-v2.5` |
| **Total models** | 22 (12 Go + 3 Zen Free + 7 OpenRouter) |

### Model Catalog (22 models)

**OpenCode Go (12):**
`opencode-go/deepseek-v4-flash`, `opencode-go/deepseek-v4-pro`, `opencode-go/glm-5`, `opencode-go/glm-5.1`, `opencode-go/kimi-k2.5`, `opencode-go/kimi-k2.6`, `opencode-go/mimo-v2.5`, `opencode-go/mimo-v2.5-pro`, `opencode-go/minimax-m2.5`, `opencode-go/minimax-m2.7`, `opencode-go/qwen3.6-plus`, `opencode-go/qwen3.7-max`

**OpenCode Zen Free (3):**
`opencode/deepseek-v4-flash-free`, `opencode/mimo-v2.5-free`, `opencode/nemotron-3-super-free`

**OpenRouter (7):**
`openrouter/auto`, `openrouter/deepseek/deepseek-v4-flash:free`, `openrouter/moonshotai/kimi-k2.5`, `openrouter/moonshotai/kimi-k2.6`, `openrouter/qwen/qwen3-coder:free`, `openrouter/meta-llama/llama-3.3-70b-instruct:free`, `openrouter/nousresearch/hermes-3-llama-3.1-405b:free`

### Tested Models (2026-05-31)
| Model | Status | Notes |
|-------|--------|-------|
| `opencode-go/deepseek-v4-flash` | ✅ | |
| `opencode-go/deepseek-v4-pro` | ✅ | |
| `opencode-go/glm-5` | ✅ | |
| `opencode-go/glm-5.1` | ✅ | |
| `opencode-go/kimi-k2.5` | ✅ | |
| `opencode-go/kimi-k2.6` | ✅ | |
| `opencode-go/mimo-v2.5` | ✅ | Default model |
| `opencode-go/mimo-v2.5-pro` | ✅ | |
| `opencode-go/minimax-m2.5` | ✅ | |
| `opencode-go/minimax-m2.7` | ✅ | |
| `opencode-go/qwen3.6-plus` | ✅ | |
| `opencode-go/qwen3.7-max` | ❌ | Empty response — model name confirmed correct by OpenCode docs, likely server-side availability issue |
| `opencode/deepseek-v4-flash-free` | ❌ | Zen catalog returns empty response in OpenClaw 2026.5.28 |
| `opencode/mimo-v2.5-free` | ❌ | Same Zen catalog issue |
| `opencode/nemotron-3-super-free` | ❌ | Same Zen catalog issue |
| `openrouter/auto` | ✅ | |
| `openrouter/deepseek/deepseek-v4-flash:free` | ⚠️ | Rate limited at test time |
| `openrouter/qwen/qwen3-coder:free` | ⚠️ | Rate limited at test time |

### Test Script
`references/test-all-models.sh` — automated Telegram-based model tester:
```bash
~/.config/opencode/skills/deactive/k-openclaw/references/test-all-models.sh      # all
~/.config/opencode/skills/deactive/k-openclaw/references/test-all-models.sh go    # go only
~/.config/opencode/skills/deactive/k-openclaw/references/test-all-models.sh free  # zen free only
```

### Critical Rules (learned)
- **Never add a custom provider** that overrides a built-in OpenClaw provider (opencode, opencode-go, etc.)
- Gateway reads `gateway.env` via systemd `EnvironmentFile` - **not** `.openclaw/.env`
- `OPENCODE_API_KEY` and `OPENCODE_ZEN_API_KEY` are the same env var for both Zen and Go catalogs
- The Go catalog (`opencode-go/...`) has 12 models but OpenClaw built-in only shows 2; all 12 must be explicitly added to `agents.defaults.models`
- Config version mismatch (2026.5.28 vs older binary) requires `OPENCLAW_ALLOW_OLDER_BINARY_DESTRUCTIVE_ACTIONS=1`
- Mistral API key expired → all Mistral models return 401
- OpenRouter free tier has rate limits

## References

- `references/retrospective-2026-04-04.md` — detailed benchmark and failure-mode notes captured at retirement time

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-31 | [OPENCODE] | v3.0.0 — Reactivated runtime: fixed broken gateway (custom providers overriding built-in), restored API keys to gateway.env, configured OpenCode Go providers as default, removed non-working Zen/Free models, documented working config |
| 2026-04-04 | [CLAUDE] | v2.1.0 — completed full purge: clawhub/clawdhub + mcporter (pnpm) + nanoclaw config dirs; documented pnpm interdependency trap and full ecosystem map |
| [SUMMARY] | — | v1.12.2–v1.0.0: active-runtime era (external-secret loading, exa-only MCP posture, lean local defaults, CLI-only QMD, compact hook guidance, history pointers, hook discovery, workspace-root, provider, approvals) |
