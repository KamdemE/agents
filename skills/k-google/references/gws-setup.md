# GWS setup — status & finalize (KπX)

> Generated: 2026-05-25 · Updated: 2026-09-03 · All setup completed.

## Done (CLI)

| Item | kpihx-labs | kpihx-489121 (KpihX) |
|------|------------|----------------------|
| Billing | already ON | **linked** to `019864-FC909B-AB04B4` |
| `classroom` + `contacts` APIs | enabled | enabled |
| Full Workspace API bundle | already had ~46; +2 | **21 APIs enabled** (Drive→Pub/Sub block) |
| Config dirs | `$HOME/.config/gws/kpihx-labs/` | `$HOME/.config/gws/kpihx/` |
| `gws auth setup` TUI | ✅ completed | ✅ completed |
| `gws auth login` | ✅ kpihx.labs@gmail.com | ✅ kapoivha@gmail.com |

Verify counts:

```bash
gcloud services list --enabled --project=kpihx-labs --format="value(config.name)" | wc -l
gcloud services list --enabled --project=kpihx-489121 --format="value(config.name)" | wc -l
```

Expected: **~48** (labs), **~61** (kpihx).

---

## Auth setup (if redo needed)

### Profile kpihx-labs

1. Open: https://console.cloud.google.com/apis/credentials?project=kpihx-labs
2. Consent screen: https://console.cloud.google.com/apis/credentials/consent?project=kpihx-labs
   - User type: **External** → save through wizard
   - **Test users** → add `kpihx.labs@gmail.com`
3. **Create credentials** → **OAuth client ID** → **Desktop app** → name `gws-kpihx-labs`
4. Copy **Client ID** and **Client secret** into the TUI prompts
5. Result: `$HOME/.config/gws/kpihx-labs/client_secret.json`

```bash
export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/kpihx-labs"
export GOOGLE_WORKSPACE_PROJECT_ID="kpihx-labs"
gws auth setup --project kpihx-labs
```

### Profile kpihX

Same console flow with `project=kpihx-489121` and client name `gws-kpihx`.

```bash
export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/kpihx"
export GOOGLE_WORKSPACE_PROJECT_ID="kpihx-489121"
gws auth setup --project kpihx-489121
```

---

## Browser login (`gws auth login`) — KπX only

Use **wrappers** (sourced from `.kshrc` via `gws-profiles.sh`):

**Labs:**

```bash
gws-labs auth login -s drive,gmail,calendar,sheets,docs,slides,tasks,people,chat,forms,keep,meet
# Sign in: kpihx.labs@gmail.com
gws-labs auth status
```

**KpihX:**

```bash
gws-kpihx auth login -s gmail,drive,calendar,contacts,sheets,docs,slides,tasks,people,chat,forms,keep,meet,classroom
# Sign in: kapoivha@gmail.com
gws-kpihx auth status
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
| kpihx-labs | https://console.cloud.google.com/apis/credentials/consent?project=kpihx-labs | https://console.cloud.google.com/apis/credentials?project=kpihx-labs |
| kpihx-489121 | https://console.cloud.google.com/apis/credentials/consent?project=kpihx-489121 | https://console.cloud.google.com/apis/credentials?project=kpihx-489121 |

---

## Vault (canonical secrets)

Path: **KpihX-Labs → Infra → Fluid → Google**

| Item | Profile dir |
|------|-------------|
| Google Fluid KpihX-Labs | `~/.config/gws/kpihx-labs/client_secret.json` |
| Google Fluid KpihX | `~/.config/gws/kpihx/client_secret.json` |

Fields: `GOAUTH_CLIENT_ID`, `GOAUTH_CLIENT_SECRET`.

## Notes

- `gcloud` admin account `kapoivha@gmail.com` is OK for **project setup**; `gws auth login` should use **kpihx.labs@gmail.com** / kapoivha@gmail.com for tokens.
- Testing-mode OAuth: max ~25 scopes per login — use `-s` lists above, not `--full`.
- `reseller.googleapis.com` was toggled ON in labs setup TUI (optional for consumer Gmail).
- `.env` files (`gws-kpihx.env`, `gws-labs.env`) removed 2026-09-03 — use wrappers from `gws-profiles.sh` instead.
