---
name: k-cloudflare
description: >
  KπX Cloudflare — flarectl (DNS/zones) on workstation; tunnel connector on homelab server only.
  Inbound @kpihx-labs.com Email Routing + Worker. Load for DNS, edge routing, or inbound mail ops.
license: private
metadata:
  author: KpihX
  version: "1.4.8"
  scope: operations
allowed-tools: Bash(flarectl:*), Bash(curl:*)
---

# KπX — Cloudflare

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

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

## Inbound email (`@kpihx-labs.com`) — LIVE

| Item | Location |
|------|----------|
| **Ops / curl / MX / rules** | `references/email-routing-ops.md` |
| **E2E verify (send matrix, traps)** | `references/inbound-email-e2e.md` |
| **Outbound free (Send-as)** | `references/inbound-email-outbound-free.md` · live checklist `references/outbound-setup-status.md` |
| **SOT + Worker bundle** | `assets/kpihx-labs-inbound-router/` |
| **Rollout** | `scripts/deploy-inbound-email-full.sh` (prime → sync → deploy) |
| **Worker rules** | `scripts/apply-inbound-email-worker-rules.sh` |
| **Route sync** | `scripts/sync-inbound-email-routes.sh` |
| **Anti-spam** | `scripts/apply-inbound-antispam-filters.sh` (Gmail + Outlook inbox rules) |
| **Archive E2E tests** | `scripts/archive-inbound-e2e-tests.sh` · manifest `references/email-e2e-test-manifest.md` |
| **Outbound check** | `scripts/check-outbound-setup.sh` |
| **Read-only check** | `scripts/verify-inbound-e2e.sh <TAG>` |
| **Worker entry** | `assets/kpihx-labs-inbound-router.mjs` (bundle under `assets/kpihx-labs-inbound-router/`) |

**Live aliases (2026-05-25):** `kpihx@` → Hotmail + kapoivha · `contact@` → Labs + kapoivha · `ivann@` → Hotmail only.  
**Mandatory:** `ensure-destination-prime-rules.sh` before Worker forwards. **Mailbox proof:** `k-mail` + `gws` + `m365` — see E2E doc (never Hotmail→`ivann@` self-test).

## Active on workstation (Ubuntu dev)

| Tool | Role | Verify |
|------|------|--------|
| **`flarectl`** | DNS + zones (`kpihx-labs.com`, ACME TXT, CNAME → tunnel ID) | `flarectl zone list` (`CF_API_TOKEN` via **`k-bw`** / **`k-clis`** token gate) |
| **`wrangler`** | **Inbound Email Worker only** (`deploy-inbound-email-worker.sh`) — not general Workers dev | `npx wrangler@3 --version` at deploy time |

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
| Tunnel | **`kpihx-labs`** — Zero Trust **remote-managed**, **HEALTHY** |
| Connector | `cloudflared tunnel run <token>` on **homelab / docker-host** only |
| Ingress | Dashboard **or** API → `references/tunnel-routes-api.md` |
| DNS from laptop | **`flarectl`** (CNAME → `<tunnel-uuid>.cfargotunnel.com`) |

Do **not** use **Add connector** on the dev laptop for prod. Internal admin → **Tailscale** + **`k-clis`** / **`ts-proxy`**.

## Two planes

| Plane | Where | Tool |
|-------|-------|------|
| **Connector** | Homelab server | `cloudflared` (installed there) |
| **Control** | Workstation (+ anywhere with token) | `flarectl` · **Email Routing API** via `curl` |

**Gaps:** Tunnel ingress + Access → `references/cf-proxy-request-shapes.md`.

## Credentials

- **`CF_API_TOKEN`** — Vault `GLOBAL_ENV_VARS` → env source · gate: **`k-clis`** → `references/token-gate.md`.
- **Tunnel run token** — homelab server / Vault only — never on workstation git repos.

## Cross-skills

| Task | Skill |
|------|-------|
| Traefik, Docker, tunnel on server | **`kpihx-labs`**, **`k-docker`** |
| Internal mesh, ACL | **Tailscale**, **`ts-proxy`**, **`k-clis`** |
| Inbox verification, What's up mail | **`k-mail`**, **`k-microsoft`**, **`k-google`** (gws) |
| Secrets | local config / env (no longer injected via `k-bw` — purged 2026-08-14) |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-cloudflare/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-cloudflare/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-25 | [CURSOR] | v1.4.8 — E2E mail archive; outbound COMPLETE; DMARC; script index in SKILL. |
| 2026-05-25 | [CURSOR] | v1.4.0 — Inbound LIVE doc split + anti-spam + Worker deploy scope. |
| [SUMMARY] | — | v1.4.1–v1.4.7 outbound/send-as/DMARC; v1.3.0 prime rules; v1.2.x tunnel + quarantine. |
