# Hermes Clean Setup

This runbook rebuilds Hermes with `$HOME/.hermes` as its sole mutable runtime home. The immutable configuration and systemd asset remain under `k-hermes` in `$HOME/.agents`; the stock UV-installed `hermes` executable remains outside the kernel.

## Canonical layout

```text
$HOME/.agents/skills/k-hermes/
├── assets/config.yaml
├── assets/profiles/ollama/config.yaml
├── assets/profiles/opencode-go/config.yaml
└── assets/hermes-gateway.service

$HOME/.hermes/
├── config.yaml                 -> k-hermes/assets/config.yaml
├── SOUL.md                     -> $HOME/.agents/AGENTS.md
├── memories/USER.md            -> $HOME/.agents/skills/kpihx/SKILL.md
└── profiles/
    ├── ollama/config.yaml      -> k-hermes/assets/profiles/ollama/config.yaml
    └── opencode-go/config.yaml -> k-hermes/assets/profiles/opencode-go/config.yaml
```

## Rebuild procedure

1. Stop the user gateway before moving an existing runtime home.
2. Preserve each existing Hermes home before reset; never overwrite authentication, SQLite state, skills, or logs during a migration.
3. Reinstall the official package with `uv tool install --reinstall hermes-agent`.
4. Recreate `$HOME/.hermes/memories/` and profile directories.
5. Recreate the registered configuration, SOUL, and USER symlinks from `assets/links.jsonc`.
6. Reload the user manager and start `hermes-gateway.service` from its registered canonical asset.

The stock `$HOME/.local/bin/hermes` executable is managed by UV and is deliberately absent from `assets/links.jsonc`: Hermes itself defaults to `$HOME/.hermes`, so no wrapper or `HERMES_HOME` override is required.

## Provider profiles

| Profile | Provider | Default model | Use |
|---|---|---|---|
| `ollama` | Local Ollama | `phi4-mini:latest` | `hermes --profile ollama chat` |
| `opencode-go` | OpenCode Go | `mimo-v2.5` | `hermes --profile opencode-go chat` |

The local model inventory is `phi4-mini:latest`, `qwen3:latest`, and `qwen2.5:latest`. The OpenCode Go profile uses `OPENCODE_API_KEY` from the invoking environment; no secret belongs in the kernel.

## Verification

```bash
systemctl --user is-active hermes-gateway.service
hermes --profile ollama config
hermes --profile opencode-go config
hermes --profile ollama -z "Briefly confirm that the local Ollama profile is available."
```

The final local smoke must return a non-empty model response. A remote OpenCode Go inference request is optional because it consumes provider credit.
