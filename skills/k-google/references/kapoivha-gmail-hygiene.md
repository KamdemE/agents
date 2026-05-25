# kapoivha@gmail.com — Gmail hygiene (operational)

**Profile:** `gws-kpihx` · **Script:** `$HOME/.agents/skills/k-google/scripts/gws_gmail_deep_cleanup.py`

## Baseline (2026-05-25 cleanup)

| Metric | Before | After |
|--------|--------|-------|
| INBOX | ~15 670 | **0** |
| UNREAD | ~14 208 | **0** |
| TRASH | 0 → 1 232 → emptied via UI | **0** (after « Vider la corbeille ») |
| Total messages | ~15 987 | ~14 770 (archived, not deleted) |

## Long-term automation installed

### User labels

- `KpihX/TickTick`, `KpihX/LinkedIn`, `KpihX/GitHub`, `KpihX/DMARC`, `KpihX/Homelab`, `KpihX/Notifications`

### Gmail filters (skip inbox + mark read where noted)

| Criteria | Action |
|----------|--------|
| `from:mail.ticktick.com` | Label TickTick, skip inbox |
| `from:linkedin.com` | Label LinkedIn, skip inbox |
| `from:notifications@github.com` / `noreply@github.com` | Label GitHub, skip inbox |
| `from:noreply-dmarc-support@google.com` | Label DMARC, skip inbox |
| `to:@kpihx-labs.com` | Label Homelab, skip inbox |
| `from:deliveroo.com` / `t.deliveroo.com` | Label Notifications, skip inbox |
| `from:news@communications.socgen.com` | Skip inbox |
| `from:carrefour@email.carrefour.fr` | Skip inbox |
| `from:no-reply@email.lebara.fr` | Skip inbox |
| `subject:(OUT-E2E OR E2E-)` | Trash |
| `from:noreply@ip-paris.fr` | Skip inbox |
| `from:aliexpress.com` | Skip inbox |
| `from:pypi.org` | Skip inbox |
| `from:discord.com` | Skip inbox |
| `from:getgitguardian.com` | Skip inbox |
| `from:enspyalumni.abroad@gmail.com` | Skip inbox |

## Manual follow-ups (KπX)

1. ~~**TickTick email notifications**~~ — **Done 2026-05-25** via Edge (`browser-mcp-stdio`): Settings → Notifications → **Email Notifications OFF** (`kapoivha@gmail.com` still linked). Gmail filter `from:mail.ticktick.com` still skips inbox.
2. **LinkedIn / Carrefour / Medium:** unsubscribe in browser when a promo appears (filters already skip inbox).
3. **gws OAuth scope:** re-auth with `gmail.modify` if agents need `batchDelete` / `emptyTrash` API (current token: modify via `batchModify` only).

## Re-run cleanup

```bash
python3 "$HOME/.agents/skills/k-google/scripts/gws_gmail_deep_cleanup.py" --dry-run
python3 "$HOME/.agents/skills/k-google/scripts/gws_gmail_deep_cleanup.py"
```

Idempotent: skips existing filters; archives matching queries again.
