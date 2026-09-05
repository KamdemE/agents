# k-google/scripts

**Pre-Fluid inventory** — run these instead of re-writing one-off `gws` glue until the ts-proxy-style bridge exists. See `SKILL.md` → **Pre-Fluid scripts**.

| Script | Purpose |
|--------|---------|
| `gws_auth_status.py` | OAuth file presence per profile (no secret values) |
| `gws_inspect_contacts.py` | People `connections.list` — filters: `all`, `email`, `kamdem`, `poly` |
| `gws_inspect_recent_mail.py` | Gmail recent messages (Subject/From/Date metadata) |
| `gws_dump_state.sh` | Full Workspace state dump → `assets/dumps/*.json` (see SKILL) |

**Shared:** `_gws_common.py` (import only — not executed directly).

## Usage

```bash
python3 "$HOME/.agents/skills/k-google/scripts/gws_inspect_contacts.py" --profile labs --filter email
python3 "$HOME/.agents/skills/k-google/scripts/gws_inspect_recent_mail.py" --profile kpihx --count 20 --json
python3 "$HOME/.agents/skills/k-google/scripts/gws_auth_status.py" --profile both
$HOME/.agents/skills/k-google/scripts/gws_dump_state.sh kpihx
```

## Agent ownership (mandatory)

- Keep this directory **ordered**: one concern per script, shared logic in `_gws_common.py`.
- Any new script → **add a row here** and a one-liner in `SKILL.md` the same workstream.
- After changing behavior → bump `SKILL.md` `metadata.version` + Changelog.
- Do not commit secrets, tokens, or downloaded mail bodies into the repo.
- Prefer extending an existing script over duplicating `/tmp` one-offs.
