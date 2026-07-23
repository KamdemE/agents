# k-x scripts

```bash
cd "$HOME/.agents/skills/k-x/scripts"
uv sync
# Requires Vaultwarden unlock (X_* in environment)
uv run python x_cli.py me
uv run python x_cli.py tweet "Hello" --dry-run
uv run python x_cli.py tweet "Hello"   # needs X API credits
```

**Creds file:** `$HOME/.config/kpihx/x/credentials.json`

Sync from Vaultwarden (one-shot, local):

```bash
uv run python sync_creds_from_env.py
```

CLI: `--creds-file "$HOME/.config/kpihx/x/credentials.json"`
