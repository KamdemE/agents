# k-media scripts

| Script | Usage |
|--------|--------|
| `youtube_gcp_bootstrap.sh` | `gcloud` enable API + status (idempotent) |
| `youtube_cli.py` | OAuth + YouTube API smoke |

## YouTube CLI

```bash
cd "$HOME/.agents/skills/k-media/scripts"
uv sync
uv run python youtube_cli.py auth      # once (browser)
uv run python youtube_cli.py channels
uv run python youtube_cli.py upload --file /path/to.mp4 --privacy unlisted
```

**Token:** `$HOME/.config/gws/<github-user>/youtube_token.json` (never commit).
