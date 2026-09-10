---
name: k-cloudflare
description: >
  Cloudflare — flarectl (DNS/zones) on workstation; tunnel connector on homelab server only.
  Inbound @<yourdomain.com> Email Routing + Worker. Load for DNS, edge routing, or inbound mail ops.
license: private
metadata:
  author: 
  version: "1.0.0"
  scope: operations
allowed-tools: Bash(flarectl:*), Bash(curl:*)
---

#  — Cloudflare

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION).**

> **OS references:** `references/ubuntu.md` (flarectl setup on workstation) · `references/windows.md` (flarectl via WSL) · `references/debian.md` (cloudflared tunnel on server)

## Cloud hub

Registry map: `$HOME/.agents/skills/k-clis/references/cloud-hub.md` · load **`k-clis`** first for cross-provider routing.

## Philosophy

| Principle | Meaning |
|-----------|---------|
| **Split paths** | **Public** homelab → Cloudflare Tunnel on **server** · **Internal** access → **Tailscale** (not duplicate public exposure) |
| **Workstation** | **`flarectl` only** for DNS/API control — no prod `cloudflared` connector on laptop |
| **0 Magic** | DNS explicit via token; tunnel connector on always-on homelab host |
| **Sovereign proxy (future)** | **`cf-proxy`** — ts-proxy-style CLI+MCP+HITL → `references/cf-proxy-vision.md` |

## Canonical IDs & Zero Trust Access

| Item | Value / ID | Details |
|------|------------|---------|
| **Account ID** | `5d0ff5e40bbc37baed99d3c7aacd0741` | Cloudflare Account `Labs` |
| **Zone ID** | `255f60d9f77924ac016c194300dbeb3c` | Zone `<github-user>.com` |
| **Tunnel ID** | `db6721cb-6bfe-4750-b55a-124e6dc74388` | Tunnel `<github-user>` (`remote_config: true`, **HEALTHY**) |
| **Access Policy** | `d6f8ccdd-6f8f-4780-b8ca-0756e7fb7415` | `Admins` policy (`session_duration: 24h`, allow 3 emails) |
| **Google IdP** | `a4c9264c-5736-4a9d-9cb9-4dab305aae13` | Client `747851806672-ncbjr8e18gtdbonupcfgmh1j1d961q69...` |
| **OTP IdP** | `a0756076-653c-4fb1-8747-626f216ac615` | Email 6-digit PIN fallback |

**Protected Access Apps (6 self-hosted apps, 24h session):** `live.<github-user>.com`, `ai.<github-user>.com`, `mail.<github-user>.com`, `whats.<github-user>.com`, `tick.<github-user>.com`, `sentinel.<github-user>.com`.  
**Architecture & SSO detail:** `references/access-sso-architecture.md`  
**Tunnel Ingress & Traefik routing:** `references/tunnel-ingress-traefik.md`

## Generic API Request Templates (`assets/templates/`)

Agents must copy a template to `/tmp/`, edit values, and launch via `with-env curls -p cloudflare ...`:

| Template Asset | Purpose |
|----------------|---------|
| `assets/templates/template-access-app.json` | Create/update Access Application |
| `assets/templates/template-access-policy.json` | Create/update Access Policy |
| `assets/templates/template-tunnel-ingress.json` | Update Tunnel Ingress configuration |
| `assets/templates/template-email-routing-rule.json` | Create Email Routing rule |
| `assets/templates/template-dns-record.json` | Create CNAME / DNS record |

## Inbound email (`@<yourdomain.com>`) — LIVE

| Item | Location |
|------|----------|
| **Ops / curl / MX / rules** | `references/email-routing-ops.md` |
| **E2E verify (send matrix, traps)** | `references/inbound-email-e2e.md` |
| **Outbound free (Send-as)** | `references/inbound-email-outbound-free.md` · live checklist `references/outbound-setup-status.md` |
| **SOT + Worker bundle** | `assets/inbound-router/` |
| **Rollout** | `scripts/deploy-inbound-email-full.sh` (prime → sync → deploy) |
| **Deploy only** | `scripts/deploy-inbound-email-worker.sh` (wrangler deploy only) |
| **Worker rules** | `scripts/apply-inbound-email-worker-rules.sh` |
| **Route sync** | `scripts/sync-inbound-email-routes.sh` |
| **Anti-spam** | `scripts/apply-inbound-antispam-filters.sh` (Gmail + Outlook inbox rules) |
| **Archive E2E tests** | `scripts/archive-inbound-e2e-tests.sh` · manifest `references/email-e2e-test-manifest.md` |
| **Outbound check** | `scripts/check-outbound-setup.sh` |
| **Read-only check** | `scripts/verify-inbound-e2e.sh <TAG>` |
| **Worker entry** | `assets/inbound-router.mjs` (bundle under `assets/inbound-router/`) |

**Live aliases:** `mail@` → Hotmail + primary Gmail · `contact@` → Labs Gmail + primary · `personal@` → Hotmail only.  
**Mandatory:** `ensure-destination-prime-rules.sh` before Worker forwards. **Mailbox proof:** `k-mail` + `gws` + `m365` — see E2E doc (never Hotmail→`personal@` self-test).

## Active on workstation (Ubuntu dev)

| Tool | Role | Verify / API usage |
|------|------|--------------------|
| **`flarectl`** | DNS + zones (`<github-user>.com`, ACME TXT, CNAME → tunnel ID) | **`with-env flarectl`** (always with `with-env` in tmux — `CF_API_TOKEN` is in Vault, not raw env) |
| **`curls`** | **REST API control** (Tunnel Ingress, Access Apps, Email Routing) | **`with-env curls -p cloudflare <url>`** — secure token injection via `k-clis` manifest |
| **`wrangler`** | **Inbound Email Worker only** (`deploy-inbound-email-full.sh`) | `npx wrangler@3 --version` at deploy time |

**Rule:** **`with-env flarectl`** for DNS/zones. **`with-env curls -p cloudflare`** for Tunnel Ingress, Access Apps, Policies, or Email Routing API. Always run in tmux (`k-tmux`).

**State dump script:** `with-env $HOME/.agents/skills/k-cloudflare/scripts/dump-cf-state.sh` (dumps to `assets/dumps/*.json`).

**Worker log diagnostics:** `references/wrangler-tail-procedure.md` — `wrangler tail` for live runtime logs (forward ok/failed per destination).

**Setup:** `references/setup.md` · examples: `$HOME/Work/techskills/cloudflare.md`.

## Quarantined on workstation (do not install without reason)

| Tool | Status | When to reconsider |
|------|--------|-------------------|
| **`cloudflared`** | **NOT on workstation** — prod connector lives on **homelab server** | Dev-only: quick tunnel → `references/cloudflared-quarantine.md` |
| **`wrangler`** (general) | **NOT for routine IDE Workers** — exception: inbound router deploy script above | Same quarantine pattern as `cloudflared` |

Full future-use map: **`references/cloudflared-quarantine.md`**.

## Prod tunnel (homelab server — not this machine)

| Item | Value |
|------|--------|
| Tunnel | **`<github-user>`** — Zero Trust **remote-managed**, **HEALTHY** |
| Connector | `cloudflared tunnel run <token>` on **homelab / docker-host** only |
| Ingress | Dashboard **or** API → `references/tunnel-routes-api.md` |
| DNS from laptop | **`with-env flarectl`** (CNAME → `<tunnel-uuid>.cfargotunnel.com`) |

Do **not** use **Add connector** on the dev laptop for prod. Internal admin → **Tailscale** + **`k-clis`** / **`ts-proxy`**.

## Two planes

| Plane | Where | Tool |
|-------|-------|------|
| **Connector** | Homelab server | `cloudflared` (installed there) |
| **Control** | Workstation (+ anywhere with token) | **`with-env flarectl`** · **`with-env curls -p cloudflare`** |

**Gaps:** Tunnel ingress + Access → `references/cf-proxy-request-shapes.md`.

## Credentials

- **`CF_API_TOKEN`** — Vault `GLOBAL_ENV_VARS` → env source · gate: **`k-clis`** → `references/token-gate.md`.
- **Tunnel run token** — homelab server / Vault only — never on workstation git repos.

## Cross-skills

| Task | Skill |
|------|-------|
| Traefik, Docker, tunnel on server | **`<github-user>`**, **`k-docker`** |
| Internal mesh, ACL | **Tailscale**, **`ts-proxy`**, **`k-clis`** |
| Inbox verification, What's up mail | **`k-mail`**, **`k-microsoft`**, **`k-google`** (gws) |
| Secrets | local config / env (no longer injected via `k-bw` — purged 2026-08-14) |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-cloudflare/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-cloudflare/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

