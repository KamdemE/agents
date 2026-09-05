# Vault token gate (all cloud / API CLIs)

> **Hub rule:** `k-clis/SKILL.md` → **Vault token gate (mandatory)**. Secrets detail → local config / env (no longer injected via `k-bw` — purged 2026-08-14). Interactive shell → **`k-tmux`**.

## Scope

Applies to every tool that needs **high-impact tokens** from Vaultwarden via **`Vaultwarden`**, including but not limited to:

| Variable family | Tools |
|-----------------|-------|
| `CF_API_TOKEN` | `flarectl`, Cloudflare API `curl` |
| M365 / Graph | `m365` (KπX login only — agents read after unlock) |
| Google OAuth files | `gws`, `gcloud` ADC |
| MCP / API keys | mail-mcp, tick-mcp, link-proxy, ts-proxy, etc. |
| Social JSON (local) | `$HOME/.config/kpihx/x/credentials.json`, `$HOME/.config/kpihx/meta/credentials.json` |

**Social JSON rule:** files are **outside** `.agents/` git — agents use `--creds-file` on `x_cli.py` / `meta_cli.py` when `Vaultwarden` is incomplete. **Never** commit, copy into skills, or paste values in chat.

## Hard rules (agents)

1. **Never** print, log, `echo`, or `cat` secret **values** (tokens, passwords, API keys).
2. **Never** run `env | grep TOKEN=…` with values — names only: `env | grep -E 'API|TOKEN' | cut -d= -f1`.
3. **Never** read Vault export files or `Vaultwarden get` output into chat.
4. **Try the target CLI first** in the current shell; only escalate if auth/env errors prove missing injection.

## Escalation ladder (strict order)

### Step 1 — Direct CLI attempt

Run the smallest read-only check (e.g. `flarectl zone list`, `m365 status`, `ts-proxy admin status`).

### Step 2 — tmux `default` or `remote`

Load **`k-tmux`**. Reuse or attach session **`default`** or **`remote`** (KπX interactive shells with `Vaultwarden` already sourced).

1. `tmux ls` — pick `default` or `remote`.
2. `send-keys` the **same** command into the pane (full line + Enter).
3. Poll `capture-pane` **≥30s** before chat handoff.
4. Tell KπX: `tmux attach -t default` (or `remote`) and what to confirm.

Do **not** run `Vaultwarden unlock` in a raw agent tool shell if Step 2 is available.

### Step 3 — Unlock in tmux (KπX password)

Only if Step 2 still fails (empty `CF_API_TOKEN`, auth errors after interactive shell):

1. In tmux pane: `Vaultwarden unlock && Vaultwarden get` (or the minimal unlock flow from **`k-bw`**).
2. **Stop** — ask KπX in chat to enter the **Vault master password** in that tmux pane.
3. After KπX confirms, **repeat Step 1** in tmux (not in agent shell unless injection confirmed).

### Step 4 — Never

- Invent tokens or ask KπX to paste tokens in chat.
- Run `m365 login` / `gws auth login` from agents without explicit KπX request (browser OAuth is KπX-owned).

## `CF_API_TOKEN` (Cloudflare)

- **SOT:** Vaultwarden `GLOBAL_ENV_VARS` → injected by **`Vaultwarden`** on login shells.
- **flarectl** reads `CF_API_TOKEN` only — no alternate flag.
- Agent non-interactive shells often **lack** injection → use ladder above before reporting "flarectl broken".

## Verification (safe)

```bash
env | grep -E '^CF_' | cut -d= -f1
flarectl zone list
curl -s "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer $CF_API_TOKEN" | head -5
```

Expect verify JSON `"status":"active"` — do not paste the token into chat.
