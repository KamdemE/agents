# GWS setup — status & finalize ()

> Generated: 2026-05-25 · Updated: 2026-09-03 · All setup completed.

## Done (CLI)

| Item | <github-user> | kpihx-489121 () |
|------|------------|----------------------|
| Billing | already ON | **linked** to `019864-FC909B-AB04B4` |
| `classroom` + `contacts` APIs | enabled | enabled |
| Full Workspace API bundle | already had ~46; +2 | **21 APIs enabled** (Drive→Pub/Sub block) |
| Config dirs | `$HOME/.config/gws/<github-user>/` | `$HOME/.config/gws/kpihx/` |
| `gws auth setup` TUI | ✅ completed | ✅ completed |
| `gws auth login` | ✅ <labs@gmail.com> | ✅ <primary@gmail.com> |

Verify counts:

```bash
gcloud services list --enabled --project=<github-user> --format="value(config.name)" | wc -l
gcloud services list --enabled --project=kpihx-489121 --format="value(config.name)" | wc -l
```

Expected: **~48** (labs), **~61** (kpihx).

---

## Auth setup (if redo needed)

### Profile <github-user>

1. Open: https://console.cloud.google.com/apis/credentials?project=<github-user>
2. Consent screen: https://console.cloud.google.com/apis/credentials/consent?project=<github-user>
   - User type: **External** → save through wizard
   - **Test users** → add `<labs@gmail.com>`
3. **Create credentials** → **OAuth client ID** → **Desktop app** → name `gws-<github-user>`
4. Copy **Client ID** and **Client secret** into the TUI prompts
5. Result: `$HOME/.config/gws/<github-user>/client_secret.json`

```bash
export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/<github-user>"
export GOOGLE_WORKSPACE_PROJECT_ID="<github-user>"
gws auth setup --project <github-user>
```

### Profile kpihX

Same console flow with `project=kpihx-489121` and client name `gws-primary`.

```bash
export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/kpihx"
export GOOGLE_WORKSPACE_PROJECT_ID="kpihx-489121"
gws auth setup --project kpihx-489121
```

---

## Browser login (`gws auth login`) —  only

Use **wrappers** (sourced from `.kshrc` via `gws-profiles.sh`):

**Labs:**

```bash
gws-labs auth login -s drive,gmail,calendar,sheets,docs,slides,tasks,people,chat,forms,keep,meet
# Sign in: <labs@gmail.com>
gws-labs auth status
```

**:**

```bash
gws-primary auth login -s gmail,drive,calendar,contacts,sheets,docs,slides,tasks,people,chat,forms,keep,meet,classroom
# Sign in: <primary@gmail.com>
gws-primary auth status
```

Smoke tests:

```bash
gws drive files list --params '{"pageSize":3}'
gws people connections list --params '{"pageSize":5}'
```

---

## Console quick links

| Project | Consent | Credentials |
|---------|---------|-------------|
| <github-user> | https://console.cloud.google.com/apis/credentials/consent?project=<github-user> | https://console.cloud.google.com/apis/credentials?project=<github-user> |
| kpihx-489121 | https://console.cloud.google.com/apis/credentials/consent?project=kpihx-489121 | https://console.cloud.google.com/apis/credentials?project=kpihx-489121 |

---

## Vault (canonical secrets)

Path: **Labs → Infra → Fluid → Google**

| Item | Profile dir |
|------|-------------|
| Google Fluid Labs | `~/.config/gws/<github-user>/client_secret.json` |
| Google Fluid  | `~/.config/gws/kpihx/client_secret.json` |

Fields: `GOAUTH_CLIENT_ID`, `GOAUTH_CLIENT_SECRET`.

## Notes

- `gcloud` admin account `<primary@gmail.com>` is OK for **project setup**; `gws auth login` should use **<labs@gmail.com>** / <primary@gmail.com> for tokens.
- Testing-mode OAuth: max ~25 scopes per login — use `-s` lists above, not `--full`.
- `reseller.googleapis.com` was toggled ON in labs setup TUI (optional for consumer Gmail).
- `.env` files (`gws-primary.env`, `gws-labs.env`) removed 2026-09-03 — use wrappers from `gws-profiles.sh` instead.
