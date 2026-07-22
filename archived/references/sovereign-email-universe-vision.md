# Sovereign Email Universe — Vision & Analysis

## Goal Description
Establish a 100% personalized and sovereign email infrastructure for the KpihX-Labs organization using the `@kpihx-labs.com` domain. This transforms the technical infrastructure into a coherent digital identity.

## Analysis of the Environment
- **Domain**: `kpihx-labs.com` (Cloudflare).
- **Infrastructure**: Homelab (`homelab` / `kpihx-ubuntu`) ready for Docker/Traefik.
- **Connectivity**: Tailscale secured.
- **Current Stack**: `mail-mcp` (IMAP/SMTP) and `m365` CLI already in use.

## Proposed Pathways

### Path A: Sovereign Routing (Cloudflare + Relay) — *Agile*
- **Incoming**: Cloudflare Email Routing (unlimited aliases: `ivann@`, `ops@`, `sentinel@`) redirecting to existing mailboxes.
- **Outgoing**: Transactional SMTP Relay (Postmark, Brevo, SES) for high deliverability.
- **Pros**: 100% reliability, no spam/reputation management, professional identity.

### Path B: Full Sovereign Server (Mailcow / Stalwart) — *Independence*
- **Implementation**: Deploying a full mail stack on Homelab.
- **Challenge**: Port 25 (SMTP) blocks on residential IPs (requires WireGuard tunnel to a VPS gateway).
- **Pros**: Total ownership of data/logs, no subscriptions, true Personal OS peak.

### Path C: Managed Pro (Microsoft 365 Business) — *Collaborative*
- **Implementation**: Connecting domain to M365 tenant.
- **Pros**: Native `m365` CLI integration, maximum reliability for academic/pro flows.

## The KpihX-Labs Blueprint (Aliases)
| Alias | Usage |
| :--- | :--- |
| **`ivann@kpihx-labs.com`** | Primary Sovereign Identity. |
| **`sentinel@kpihx-labs.com`** | System Heartbeat (monitoring, alerts, logs). |
| **`lab@kpihx-labs.com`** | Research, AI tool registrations, hackathons. |
| **`ops@kpihx-labs.com`** | Infrastructure administration (Cloudflare, GH, GL). |
| **`bot@kpihx-labs.com`** | Automated agents (WhatsApp, Telegram bots). |

## Technical Requirements (The Trust Trinity)
- **SPF**: List authorized sending servers.
- **DKIM**: Digital signature for integrity.
- **DMARC**: Policy enforcement for SPF/DKIM failures.

## Next Steps
1. [ ] Audit Cloudflare Email Routing eligibility.
2. [ ] Standardize visual signatures for `@kpihx-labs.com`.
3. [ ] Plan migration of Sentinel alerts to `sentinel@kpihx-labs.com`.
