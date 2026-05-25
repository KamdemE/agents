# k-microsoft/scripts

**Pre-Fluid inventory** — run these instead of re-inventing `m365` glue until the Fluid/ts-proxy bridge exists. See `SKILL.md` → **Pre-Fluid scripts**. (`az` deactivated — not used.)

| Script | Purpose |
|--------|---------|
| `m365_inspect_status.py` | `m365 status` (never login/logout) |
| `m365_inspect_inbox.py` | Inbox message list (JSON → readable summary) |
| `m365_inspect_contacts.py` | Graph `/me/contacts` via `m365 request` |

**Shared:** `_m365_common.py` (import only).

## Usage

```bash
python3 "$HOME/.agents/skills/k-microsoft/scripts/m365_inspect_status.py"
python3 "$HOME/.agents/skills/k-microsoft/scripts/m365_inspect_inbox.py" --folder Inbox --json
python3 "$HOME/.agents/skills/k-microsoft/scripts/m365_inspect_contacts.py" --top 100
```

## Agent ownership (mandatory)

- Keep this directory **ordered**: one concern per script, shared logic in `_m365_common.py`.
- Any new script → **add a row here** and a one-liner in `SKILL.md` the same workstream.
- **Never** add scripts that call `m365 login`, `logout`, or `setup`.
- After changing behavior → bump `SKILL.md` `metadata.version` + Changelog.
- Prefer extending an existing script over `/tmp` one-offs.
