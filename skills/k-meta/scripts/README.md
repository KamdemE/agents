# k-meta scripts

```bash
cd "$HOME/.agents/skills/k-meta/scripts"
uv sync
# Fill $HOME/.config/kpihx/meta/credentials.json first
uv run python meta_cli.py --creds-file "$HOME/.config/kpihx/meta/credentials.json"
```

Sync from bw-env when all META_* vars are in env:

```bash
uv run python sync_creds_from_env.py
```
