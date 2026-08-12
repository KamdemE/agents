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
