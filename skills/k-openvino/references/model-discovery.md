# Dynamic Model Discovery — bifrost vs litellm

## Problem

OpenCode's collapsible "Thinking" UI (`+ Thought: Xs`) requires the model's `reasoning` capability flag to be `true`. For a **registered** provider (OpenAI, Anthropic, OpenCode Zen/subscription), OpenCode already knows this from `models.dev` — zero config needed. For a **custom** OpenAI-compatible provider (our `openvino` entry in `opencode.jsonc`), there is no such prior knowledge; the capability must come from somewhere.

**Never hand-list models with `reasoning: true` in `opencode.jsonc`** — that breaks dynamism (a new model added server-side would need a matching manual config edit every time). The correct fix is 100% dynamic: make the DISCOVERY mechanism itself carry the capability.

## The `opencode-models-discovery` plugin

Already installed (`"opencode-models-discovery@latest"` in `opencode.jsonc`'s `plugin` array). It re-discovers models from any configured provider's `/v1/models` at OpenCode startup/config load, and can optionally **enrich** each discovered model with extra capability metadata via `options.modelsDiscovery.modelInfoFormat`.

## `bifrost` format — does NOT map `reasoning`

The originally-configured format (`"modelInfoFormat": "bifrost"`) reads Bifrost AI Gateway's inline `/v1/models` metadata (context/output limits, modalities, pricing) — **verified by reading the actually-installed plugin source** (`~/.cache/opencode/packages/opencode-models-discovery@latest/node_modules/opencode-models-discovery/src/utils/model-info/bifrost.ts`): it only maps `limit`, `modalities`, `cost`. There is no `reasoning` mapping anywhere in this enricher, regardless of what our own server returns. This was silently wrong the whole time — bifrost format is fine for context%/pricing but structurally cannot deliver the reasoning flag.

## `litellm` format — maps `reasoning` correctly

Verified in the same real installed source (`.../src/utils/model-info/litellm.ts`):

```js
if (info.supports_reasoning === true) {
  modelConfig.reasoning = true
}
```

Fetched from `modelInfoEndpoint` (defaults to `/v1/model/info`), expecting a LiteLLM-shaped response:

```json
{
  "data": [
    {
      "model_name": "qwen3-0.6b",
      "model_info": {
        "key": "qwen3-0.6b",
        "mode": "chat",
        "max_input_tokens": 32768,
        "max_output_tokens": 8192,
        "supports_reasoning": true,
        "supports_function_calling": true
      }
    }
  ]
}
```

The `litellm.ts` enricher ALSO maps `limit.context`/`limit.output` from `max_input_tokens`/`max_output_tokens` — so switching from `bifrost` to `litellm` does not lose the context%/limit display; it gains `reasoning` on top.

## The fix

1. **`serve.py`** — new `GET /v1/model/info` endpoint, generated dynamically from `_discover_models()` (same source of truth as `/v1/models`). Every discovered Qwen3 model reports `supports_reasoning: true` unconditionally — no per-model hardcoding anywhere, any future model served by this process gets the flag automatically.
2. **`opencode.jsonc`** — one line changed: `"modelInfoFormat": "bifrost"` → `"litellm"`. No `models` block added to the `openvino` provider.

## Verification

- `/v1/model/info` returns the correct shape (curl-tested).
- `opencode run` triggers a fresh discovery pass and finds all 3 models (`modelCount=3` logged).
- Live in the interactive TUI: `+ Thought: 5.0s` collapsible block appears, AND the bottom status bar still shows `8.0K (24%)` — confirming both capabilities (reasoning + context%) work simultaneously with the `litellm` format.

## Note on `opencode run` vs interactive TUI

`opencode run` (one-shot CLI mode) never renders the collapsible thinking UI element regardless of whether `reasoning` capability is correctly detected — that visual affordance is exclusive to the interactive TUI. Server-side/data-level verification (`/v1/model/info` correctness, discovery logs) can be done via `opencode run`, but the actual UI behavior must be confirmed in a real interactive session.
</content>
