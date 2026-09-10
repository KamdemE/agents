# k-hermes Insights

## 2026-06-04 — Multi-Provider Reconnaissance

- **Discovery method:** The richest credential source is OpenCode's `auth.json` — it aggregates every provider the system has authenticated (API keys for mistral, venice, openai, openrouter, opencode-go + OAuth for google, github-copilot).
- **Second source:** OpenClaw's `openclaw.json` has a huge `models.providers` block with Venice defining ~40 models (claude, gpt, gemini, grok, deepseek, qwen3 all via Venice).
- **Credential sprawl:** Keys are scattered across `~/.vibe/.env`, `~/.openclaw/.env`, `~/.continue/.env`, `~/.colab/.env`, and shell env. There is no single source of truth. Vaultwarden is configured but unused — all keys are plaintext in dotfiles.
- **Venice is the most valuable provider:** The Venice API key gives access to Claude Opus 4.6 (1M ctx), GPT-5.4 (1M ctx), Grok 4.1, Gemini 3, DeepSeek v3.2, and dozens more — all free via Venice's API.
- **Profile-per-provider** is the cleanest way to manage Hermes multi-provider access without clobbering config.yaml.

## 2026-06-03 — Initial

- Hermes is deployed as a persistent Memory Layer and Headless Daemon.
- Auto-generated Hermes skills must remain sandboxed in `$HERMES_HOME/skills` and NOT symlinked to the production  kernel.
