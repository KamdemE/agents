# Outbound setup — live status (`@kpihx-labs.com`)

> **Status: COMPLETE (2026-05-25)** — all three aliases `accepted` on Gmail send-as.

> **Target:** `contact@` → Labs Gmail · `kpihx@` + `ivann@` → kapoivha Gmail (read on Hotmail) · **Gmail SMTP** (free).

## Agent-done (2026-05-25)

| Item | Status |
|------|--------|
| Apex **SPF** | `v=spf1 include:_spf.google.com include:_spf.mx.cloudflare.net ~all` |
| **_dmarc** | ✅ `v=DMARC1; p=none; rua=mailto:kapoivha@gmail.com` (API updated 2026-05-25, id `db7b3c48…`) |
| Inbound routing + anti-spam | LIVE — see `inbound-email-e2e.md` |
| Gmail API `sendAs.create` | **Blocked** (403 — OAuth scope; UI required) |

## Progress

| Phase | Status |
|-------|--------|
| A App passwords | ✅ KπX 2026-05-25 |
| B Labs `contact@` send-as | ✅ verified `accepted` (API) |
| C Outlook web | ❌ removed by Microsoft |
| C′ kapoivha `ivann@` + `kpihx@` | ✅ both `accepted` (gws API 2026-05-25) |
| D Agent verify + test send | ✅ **COMPLETE** — all 3 aliases send via Gmail (Labs + kapoivha); m365 = Hotmail default only |

## KπX actions (interactive — required)

### Phase A — App passwords (Google Account, ~5 min each) ✅

| # | Account | Label suggestion | URL |
|---|---------|------------------|-----|
| A1 | `kpihx.labs@gmail.com` | `Mail Labs contact` | https://myaccount.google.com/apppasswords |
| A2 | `kapoivha@gmail.com` | `Mail Outlook aliases` | same (logged in as kapoivha) |

**Requirements:** 2FA enabled on each Google account.

**When done:** reply `app passwords ok` (do not paste passwords in chat).

---

### Phase B — Labs Gmail: `contact@` (~10 min)

1. Gmail **kpihx.labs@gmail.com** → Settings → **Accounts** → *Send mail as* → **Add**.
2. Email: `contact@kpihx-labs.com` · Name: `KpihX`.
3. SMTP: `smtp.gmail.com` · port **587** · TLS · user `kpihx.labs@gmail.com` · password = **A1 app password**.
4. Open verification email (Labs or kapoivha inbox) → confirm.

**When done:** reply `contact sendas ok`. ✅

---

### Phase C — Outlook web ❌ (not available on consumer accounts)

Microsoft **removed** “Connected accounts” / custom SMTP in **outlook.live.com** Settings (no **Sync email** under Email — only Compose and reply, Rules, etc.). You cannot add `kpihx@` / `ivann@` send-as there anymore.

### Phase C′ — kapoivha Gmail send-as (recommended) ← **CURRENT**

Same steps as Phase B, but on **kapoivha@gmail.com** with app password **A2**:

1. Gmail **kapoivha** → Settings → Accounts → *Send mail as* → add **`kpihx@kpihx-labs.com`** then **`ivann@kpihx-labs.com`**.
2. SMTP: `smtp.gmail.com:587` · user `kapoivha@gmail.com` · password A2.
3. Verify each (forwards arrive on Hotmail + kapoivha).

**Usage:** read/reply on **Hotmail** for `ivann@`/`kpihx@` inbound; **compose send** from **Gmail kapoivha** choosing the right **From** (or reply from Gmail after forward).

**Optional:** Outlook **desktop** (Windows/Mac) may still allow SMTP accounts — not outlook.live.com web.

**When done:** reply `kapoivha sendas ok` (both aliases).

### Phase C″ — Outlook desktop only (if installed)

File → Account settings → add IMAP/SMTP send account — only if you use the desktop app; web path above is dead.

---

### Phase D — Agent resume after B+C

Agent will:

- `gws-labs` / Graph list send-as aliases
- Send one test per alias (optional)
- Mark this file **COMPLETE**

## tmux handoff (if KπX prefers terminal)

```bash
tmux attach -t default   # or: tmux new -s outbound
```

Agent may `send-keys` browser-open commands only — **never** paste app passwords in pane history from agent side.

## Verify commands (agent)

```bash
# Labs send-as list
GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/kpihx-labs" GOOGLE_WORKSPACE_PROJECT_ID="kpihx-labs" \
  gws gmail users settings sendAs list --params '{"userId":"me"}'

# SPF live
flarectl dns list --zone kpihx-labs.com | rg -i spf
```

## QMD keywords

`outbound setup`, `send mail as`, `app password`, `contact@`, `outbound-setup-status`
