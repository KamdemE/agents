# X (Twitter) API — KπX setup (`X Dev`)

> **Skill:** `k-x` · **Registry:** `k-clis/references/social-dev-platforms.md` · **Vault item:** **X Dev**

## Agent-done (2026-05-25)

| Check | Result |
|-------|--------|
| `GET /2/users/me` via **Vaultwarden** | ✅ **@KPIHX7** · id `1643990993983926280` |
| `GET /2/users/me` via **JSON** | ✅ **@KPIHX7** (2026-05-25, JSON filled) |
| `POST /2/tweets` | ❌ **402 CreditsDepleted** — recharge at developer.x.com / console.x.com |

**Fix JSON from working env (after `Vaultwarden unlock`):**

```bash
cd "$HOME/.agents/skills/k-x/scripts"
uv run python sync_creds_from_env.py
uv run python x_cli.py --creds-file "$HOME/.config/kpihx/x/credentials.json" me
```

**CLI:** `"$HOME/.agents/skills/k-x/scripts/README.md"`

## Secrets — what KπX must do

### Option A — Recommended (no JSON file)

Secrets stay in **Vaultwarden** item **X Dev** → injected by **`Vaultwarden`** into the shell:

| Vault field | Env var | Used for |
|-------------|---------|----------|
| API Key | `X_API_KEY` | OAuth 1.0a ✅ |
| API Key Secret | `X_API_KEY_SECRET` | OAuth 1.0a ✅ |
| Access Token | `X_ACCESS_TOKEN` | OAuth 1.0a ✅ |
| Access Token Secret | `X_ACCESS_TOKEN_SECRET` | OAuth 1.0a ✅ |
| Bearer Token | `X_BEARER_TOKEN` | App-only (not `/users/me`) |
| Client ID / Secret | `X_CLIENT_ID`, `X_CLIENT_SECRET` | OAuth 2.0 PKCE (future) |

**You do not need a JSON file** if agents/scripts run after `Vaultwarden unlock` (same as Cloudflare / mail).

Verify (names only):

```bash
env | grep -E '^X_' | cut -d= -f1
```

### Option B — JSON credentials (active while `Vaultwarden` in mutation)

**Path (fill secrets here):** `$HOME/.config/kpihx/x/credentials.json` · mode `600` · **never commit** (outside `.agents/` repo).

Replace the four placeholders from Vault item **X Dev**:

| JSON key | Vault field |
|----------|-------------|
| `api_key` | `X_API_KEY` |
| `api_key_secret` | `X_API_KEY_SECRET` |
| `access_token` | `X_ACCESS_TOKEN` |
| `access_token_secret` | `X_ACCESS_TOKEN_SECRET` |

Template copy: `k-x/assets/credentials.json.example` (optional bearer/OAuth2 keys not required for `me` / `tweet`).

CLI:

```bash
cd "$HOME/.agents/skills/k-x/scripts"
uv run python x_cli.py --creds-file "$HOME/.config/kpihx/x/credentials.json" me
```

### What NOT to put in JSON

- Do not duplicate into repo, chat, or `GLOBAL_ENV_VARS` plaintext in git-tracked files.
- `X_LOGIN` / `X_PASS` (if present) = **human login**, not API — do not use in scripts.

## KπX manual — recharger les crédits X (402 CreditsDepleted)

X API = **pay-per-use** (pas d’abonnement fixe obligatoire). Sans crédits → `POST /2/tweets` et beaucoup de reads → **402**.

### Étapes (console)

1. Ouvre **https://console.x.com/** ou **https://developer.x.com/** (même compte dev).
2. Sélectionne ton **Project** puis l’**App** liée à `@KPIHX7`.
3. Menu **Billing**, **Credits**, ou **Usage and billing** (libellé selon UI).
4. **Purchase credits** — choisis un montant (ex. 10–25 USD pour commencer).
5. Ajoute une **carte** si demandé ; définis **Default payment method**.
6. *(Recommandé)* **Auto-recharge** : seuil bas (ex. 5 USD) + recharge (ex. 25 USD) pour éviter nouveaux 402.
7. Vérifie **Credit balance** > 0 dans le dashboard.

Docs : https://docs.x.com/x-api/getting-started/pricing · https://docs.x.com/fundamentals/developer-portal

### Re-test après recharge

```bash
cd "$HOME/.agents/skills/k-x/scripts"
uv run python x_cli.py --creds-file "$HOME/.config/kpihx/x/credentials.json" tweet "KpihX smoke — delete me"
```

Until credits: **`me` works** (profile verify); **posting and timeline read fail with 402**.

## Auth matrix

| Endpoint | Bearer | OAuth 1.0a user |
|----------|--------|-----------------|
| `GET /2/users/me` | ❌ 403 | ✅ |
| `POST /2/tweets` | ❌ | ✅ (needs credits) |

## QMD keywords

`X Dev`, `KPIHX7`, `OAuth 1.0a`, `CreditsDepleted`, `x_cli`
