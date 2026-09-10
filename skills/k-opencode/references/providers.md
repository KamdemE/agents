# Providers — Ollama, OpenVINO, Cursor, Google AGY & OpenCode Labs

## Provider: Ollama (local)

```jsonc
"provider": {
  "ollama": {
    "npm": "@ai-sdk/openai-compatible",
    "name": "Ollama (local)",
    "options": { "baseURL": "http://localhost:11434/v1" },
    "models": {
      "qwen3", "qwen2.5", "qwen2.5-coder", "llama3.1", "phi4-mini"
    }
  }
}
```

Auto-synced by `scripts/opencode-ollama.sh` (sourced from `.kshrc`) after `ollama pull`/`rm`/`delete`. See the `Scripts` section in `SKILL.md`. Optional: add a second Ollama block (e.g. a remote server over an SSH tunnel) by duplicating this stanza with its own provider key and baseURL.

## Provider: OpenVINO (local, auto-discovered)

```jsonc
"provider": {
  "openvino": {
    "npm": "@ai-sdk/openai-compatible",
    "name": "OpenVINO (local)",
    "options": {
      "baseURL": "http://localhost:11437/v1",
      "modelsDiscovery": {
        "enabled": true
      }
    }
  }
}
```

Auto-discovered via `opencode-models-discovery` plugin (queries `GET /v1/models` at startup, parses `id`, `name`, `context_length` from `~/.local/share/openvino/models/<id>/config.json` `max_position_embeddings` → `40960` for `qwen3-0.6b`). **No manual `models` block** — `opencode ls` and `opencode run --agent Lite --model openvino/qwen3-0.6b` work without listing, like `anthropic` / `google-agy` via OAuth. Code side: `AI/openvino/src/k_openvino/serve.py` exposes `GET /v1/models` with `context_length` and `GET /v1/models/{id}` for the plugin to fetch.

## Provider: Cursor (subscription via official SDK, route B)

Cursor exposes **no public OpenAI-compatible endpoint** — the only supported paths are the `agent` CLI, the `@cursor/sdk`, and the Cloud Agents API (all run the Cursor agent harness, never raw models). The `@stablekernel/opencode-cursor` plugin (fork of `WayneSimpson/opencode-cursor`, npm `0.9.0`) wraps the **official SDK** and surfaces the subscription as a native `cursor/*` provider in the picker.

```jsonc
// assets/opencode.jsonc → "plugin"
"@stablekernel/opencode-cursor@latest",

// assets/opencode.jsonc → "provider" (minimal — the plugin auto-injects this block)
"cursor": {
  "npm": "@stablekernel/opencode-cursor",
  "name": "Cursor"
}
```

Requirements: opencode 1.17+, Node.js 22.13+ (`node --version` — Bun runs opencode itself; Node is only the sidecar fallback).

Auth (key names + flow only, never values): `opencode auth login` → choose Cursor → paste the key from the Cursor dashboard (user/service-account API key). Stored by opencode in its auth store. Resolution order is plugin default: **stored credential first, `CURSOR_API_KEY` env fallback**. Verify: `opencode auth list` (Cursor present) + `opencode models | grep cursor`.

⚠️ **Do NOT pin `"options": { "apiKey": "{env:CURSOR_API_KEY}" }` explicitly** (fixed 2026-09-09): the explicit override replaces the whole resolution chain with env-only, so a TUI launched from a shell without the export fails with `Cursor API key missing` even though the stored credential exists — while `opencode models` (different code path) still lists the live catalog, producing the paradox "catalog OK, chat KO". Minimal config = minimal bug surface. Same rule generalizes: never pin an option the plugin already resolves itself (sandbox/cwd/mode are the legitimate explicit exceptions).

Live catalog is account/team-specific (`Cursor.models.list()` — "discover, don't hard-code"). On Pro 2026-09-09: 39 entries (`composer-2.5`, `claude-opus-4-5…4-8` + `5`, `claude-sonnet-4…5`, `gpt-5.x`, `grok-4.5/4.6`, `gemini-3.x-flash`, `kimi-k2.7-code/k3`, `muse-spark-1.3`, `default` server router). Force refresh via the `cursor_refresh_models` tool or an opencode restart.

Billing (Pro $20/mo, two pools): **Cursor Models pool** (Grok 4.5/4.6, Composer 2.5 — generous included usage, no token-rate surcharge) vs **Other Models pool** (Claude/GPT/Gemini at raw API rates — $20 included, then on-demand). Daily driver: `cursor/composer-2.5` or router balanced; frontier Thinking models burn the $20 pool fast. Watch `cursor.com/dashboard/usage`.

Security: chatting with `cursor/*` runs Cursor's own tools (shell/write/edit/delete) in the working directory **outside opencode's permission system**. Mitigations: `"options": { "sandbox": true }`, or delegate via the permission-gated `cursor_delegate` tool instead of the provider path.

ToS note: Cursor staff treats subscription use outside official clients as a §1.5 violation risk (up to ban) — the SDK-backed route is the most defensible of the unofficial options, but start on a test key and monitor usage. Always **restart opencode after login/config change** — a running TUI keeps the old config/auth in memory.

Quota (Cursor subscription, not OpenCode-local): no official `cursor quota` on the IDE binary. Use https://cursor.com/dashboard/usage + https://cursor.com/dashboard/spending, or Cursor Settings → Chat → Usage summary = Always. Optional community CLI: `cursor-usage` (session-based). `opencode stats` only shows OpenCode session tokens/cost, not Cursor plan pools.

## Provider: Google AGY (Google One / AI Pro via Antigravity CLI)

Replaces **`opencode-antigravity-auth`** (2026-09-09). Old plugin talked Cloud Code OAuth with a thin Gemini-only surface and opaque errors (`403 SUBSCRIPTION_REQUIRED` / `#3501`) that looked like a permanent ban when the real failure was often **Gemini weekly quota = 0**. New plugin bridges OpenCode to the local **`agy` CLI** auth + model catalog (Gemini + Claude + GPT-OSS) and exposes real quota buckets.

Prerequisite: Antigravity CLI installed (`curl -fsSL https://antigravity.google/cli/install.sh | bash` → `~/.local/bin/agy`). Hub/IDE/SDK optional — CLI alone is enough for OpenCode. AGY product install details → **`k-code/references/agy.md`**.

```jsonc
// assets/opencode.jsonc → "plugin"
"@anthonyhaussman/opencode-agy-auth@latest",

// assets/opencode.jsonc → "provider"
// npm MUST be @ai-sdk/google — the auth plugin injects OAuth + models on top.
// Putting the auth package itself in npm → "Failed to initialize provider: google-agy".
"google-agy": {
  "npm": "@ai-sdk/google",
  "name": "Google AGY"
}
```

Auth (OAuth, **no Gemini API key** for the subscription path):

```bash
opencode auth login --provider google-agy
# choose Google OAuth (Antigravity CLI) — NOT "Manually enter API Key"
opencode auth list   # must show google-agy (separate from legacy google)
```

Optional: `OPENCODE_AGY_PROJECT_ID` or `provider.google-agy.options.projectId` if bind fails. Restart OpenCode after login.

### Quota (two families — GRAVÉ)

Google One AI Pro burns **shared buckets**, not cash API invoices. Families are separate:

| Family | Models | Windows |
|--------|--------|---------|
| **Gemini** | Flash + Pro (all gemini-*) | weekly + 5h (5h disabled while weekly = 0) |
| **Claude + GPT** | Opus, Sonnet, GPT-OSS | weekly + 5h |

Commands:

```bash
# AGY CLI (print mode — no interactive TTY needed)
agy -p '/quota' --output-format text --print-timeout 30s
agy models

# OpenCode TUI (provider google-agy session)
/agyquotasummary
/agyquota

# OpenCode local session cost (NOT Google One buckets)
opencode stats
opencode stats --days 7 --models
```

Cost ranking in the picker ≈ API list $/MTok = **quota burn rate** inside the family (Opus ≫ Sonnet ≫ Gemini Pro ≫ Flash ≫ GPT-OSS). Prefer Sonnet/GPT-OSS when Gemini weekly is empty.

### Pitfalls (live 2026-09-09)

1. **`provider.google-agy.npm` = auth plugin** → init failure. Keep `@ai-sdk/google`.
2. **Missing `opencode auth login --provider google-agy`** → `Google Generative AI API key is missing` (SDK fallback). Legacy `auth.json` key `google` ≠ `google-agy`.
3. **Old antigravity-auth** hid Gemini-only + false “subscription required”; check `/quota` before diagnosing license death.
4. Official Python SDK `google-antigravity` is **API-key / Vertex only** — it does **not** consume Google One OAuth. Do not confuse `agy_sdk` naming in forks with that PyPI package.

## Provider: OpenCode Labs (2nd account — Go + Zen twins)

Same split as principal `opencode` (Zen) / `opencode-go` (Go):

| Provider id | Display | baseURL | Free (`*-free`) |
|-------------|---------|---------|-----------------|
| `opencode-labs` | OpenCode Labs Go | `…/zen/go/v1` | No |
| `opencode-labs-zen` | OpenCode Labs Zen | `…/zen/v1` | Yes |

```jsonc
"opencode-labs": {
  "npm": "@ai-sdk/openai-compatible",
  "name": "OpenCode Labs Go",
  "options": {
    "baseURL": "https://opencode.ai/zen/go/v1",
    "opencodeAccountDiscovery": true
  }
},
"opencode-labs-zen": {
  "npm": "@ai-sdk/openai-compatible",
  "name": "OpenCode Labs Zen",
  "options": {
    "baseURL": "https://opencode.ai/zen/v1",
    "opencodeAccountDiscovery": true
  }
}
```

Plugin (any Nth OpenCode account): `scripts/plugins/opencode-account-discovery.js` in the `plugin` array.

- **Auth:** one Labs API key can fill both provider ids (endpoint picks catalog).
- **Models:** auto via plugin `GET /models` + exact models.dev npm — **no hardcoded list**. Free only under Labs Zen.
- **muse/luna:** `provider.npm=@ai-sdk/openai` (`/v1/responses`). Never reintroduce a path proxy / `models-discovery` on these providers.
- **Legacy purge:** `opencode-go-proxy` (:4999) removed 2026-09-09.

```bash
opencode models opencode-labs
opencode models opencode-labs-zen
opencode auth list
```

## Provider: GitHub Copilot

OAuth via `/connect` → GitHub Copilot. On OpenCode **1.18.x**, GitHub often returns **`model_picker_enabled: false` for every model** even when `policy.state` is `enabled` → upstream filters to zero models → `Provider not found: github-copilot` (issue [#42083](https://github.com/anomalyco/opencode/issues/42083)).

**Fix (local):** plugin `scripts/plugins/opencode-copilot-picker-fix.js` — keep usable models (policy≠disabled + limits + tool_calls), ignore picker flag.

```bash
opencode models github-copilot
# expect dozens of models (gpt-4.1, gpt-5-mini, claude-haiku-4.5, …)
```
