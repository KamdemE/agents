# <primary@gmail.com> — Gmail hygiene (operational)

**Profiles:** `gws-primary` (kapoivha) · `gws-labs` (kpihx.labs) — hygiene applies to the kpihx profile.

## Baseline (2026-05-25 cleanup)

| Metric | Before | After |
|--------|--------|-------|
| INBOX | ~15 670 | **0** |
| UNREAD | ~14 208 | **0** |
| TRASH | 0 → 1 232 → emptied via UI | **0** (after « Vider la corbeille ») |
| Total messages | ~15 987 | ~14 770 (archived, not deleted) |

## Long-term automation installed

### User labels

- `/TickTick`, `/LinkedIn`, `/GitHub`, `/DMARC`, `/Homelab`, `/Notifications`

### Gmail filters (skip inbox + mark read where noted)

| Criteria | Action |
|----------|--------|
| `from:mail.ticktick.com` | Label TickTick, skip inbox |
| `from:linkedin.com` | Label LinkedIn, skip inbox |
| `from:notifications@github.com` / `noreply@github.com` | Label GitHub, skip inbox |
| `from:noreply-dmarc-support@google.com` | Label DMARC, skip inbox |
| `to:@<yourdomain.com>` | Label Homelab, skip inbox |
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
| `from:<alumni@gmail.com>` | Skip inbox |

## Manual follow-ups ()

1. ~~**TickTick email notifications**~~ — **Done 2026-05-25** via Edge (`browser-mcp-stdio`): Settings → Notifications → **Email Notifications OFF** (`<primary@gmail.com>` still linked). Gmail filter `from:mail.ticktick.com` still skips inbox.
2. **LinkedIn / Carrefour / Medium:** unsubscribe in browser when a promo appears (filters already skip inbox).
3. **gws OAuth scope:** re-auth with `gmail.modify` if agents need `batchDelete` / `emptyTrash` API (current token: modify via `batchModify` only).

## Maintenance (post deep-cleanup script removal)

The one-off `gws_gmail_deep_cleanup.py` was removed 2026-09-04. Current hygiene tooling:

```bash
# Inspect recent mailbox state
python3 "$HOME/.agents/skills/k-google/scripts/gws_inspect_recent_mail.py" --profile kpihx --count 20

# Full workspace dump (labels, filters, send-as, settings) via gws-primary / gws-labs
$HOME/.agents/skills/k-google/scripts/gws_dump_state.sh kpihx
$HOME/.agents/skills/k-google/scripts/gws_dump_state.sh labs
```

Filters and labels above remain live in Gmail settings (idempotent — the cleanup script only created them once; they persist).
