# Providers — Ollama & Ollama6

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

Auto-synced by `scripts/opencode-ollama.sh` (sourced from `.kshrc`) after `ollama pull`/`rm`/`delete`. See the `Scripts` section in `SKILL.md`.

## Provider: Ollama6 (deep-pc6)

```jsonc
"provider": {
  "ollama6": {
    "npm": "@ai-sdk/openai-compatible",
    "name": "Ollama6",
    "options": { "baseURL": "http://localhost:11436/v1" },
    "models": {
      "dolphin-mixtral:latest", "gemma3:27b", "qwen3:30b", ...
    }
  }
}
```

Models auto-synced by `opencode-ollama6.sh` (sourced from `.kshrc` — exact equivalent of `opencode-ollama.sh` for the `ollama6` provider). Full model names as keys. The wrapper lives in `k-dxo/scripts/opencode-ollama6.sh` and wraps `ollama6 pull`/`rm`/`delete` and surgically replaces the `ollama6` sub-block only (other providers untouched). Requires the DxO VPN (`vpn-dxo.service`) + the deep-pc6 Ollama tunnel (`ollama6-tunnel.service`, see k-dxo). When the tunnel is down the sync is skipped silently (like the `ollama` wrapper when the local server is unreachable). `ollama6` itself stays core-only.

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

Auto-discovered via `opencode-models-discovery` plugin (queries `GET /v1/models` at startup, parses `id`, `name`, `context_length` from `~/.local/share/openvino/models/<id>/config.json` `max_position_embeddings` → `40960` for `qwen3-0.6b`). **No manual `models` block** — `opencode ls` and `opencode run --agent Lite --model openvino/qwen3-0.6b` work without listing, like `anthropic`/`antigravity` via OAuth. Code side: `AI/openvino/src/k_openvino/serve.py` exposes `GET /v1/models` with `context_length` and `GET /v1/models/{id}` for the plugin to fetch.
