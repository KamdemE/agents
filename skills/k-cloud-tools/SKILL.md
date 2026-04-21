---
name: k-cloud-tools
description: Management of Cloud, Infrastructure, and Social Media CLIs/APIs (Cloudflare, Tailscale, GCP, Azure, M365, Meta, X).
license: private
metadata:
  author: KpihX
  version: "1.0.0"
  scope: operations
---

# Operational Skill — Cloud & Social Tools

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Overview

This skill centralizes the management, configuration, and audit of command-line interfaces and APIs used to control KπX's sovereign grid and digital footprint.

## Tool Registry

### 1. Networking & Infrastructure
| Tool | Namespace | Status | Purpose |
|------|-----------|--------|---------|
| `cloudflared` | Cloudflare | **INSTALLED** | Tunneling, Zero Trust access |
| `wrangler` | Cloudflare | **INSTALLED** | Workers, Pages, R2 deployment |
| `tailscale` | Tailscale | **INSTALLED** | Mesh network management |

### 2. Cloud Providers
| Tool | Provider | Status | Purpose |
|------|----------|--------|---------|
| `gcloud` | Google Cloud | **INSTALLED** | GCP Resources, AI Studio |
| `az` | Azure | **MISSING** | Azure Resources, OpenAI |
| `m365` | Microsoft 365 | **INSTALLED** | Microsoft Account, Outlook, Graph |

### 3. Social Media & Communication (API/Developer Access)
| Platform | Tool / CLI | API Status | Management Type |
|----------|------------|------------|-----------------|
| **YouTube** | `yt-dlp` / Google API | **TBD** | Data extraction & Channel Mgmt |
| **WhatsApp** | Cloud API / `whats-mcp` | **ACTIVE (Bot)** | Official API integration planned |
| **LinkedIn** | LinkedIn API | **ACTIVE** | Dev portal access verified |
| **X (Twitter)** | `twarc2` / API v2 | **TBD** | Developer portal request needed |
| **Facebook** | Graph API | **TBD** | Meta for Developers account |
| **Instagram** | Graph API | **TBD** | Meta for Developers account |

## API Credentials & Developer Portals

To maintain a fluid architecture, API keys must be managed in Bitwarden and injected via `bw-env` or stored in the `homelab` Secrets Manager.

- **Meta (FB/Insta/WA):** [developers.facebook.com](https://developers.facebook.com/)
- **Google (YouTube/GCP):** [console.cloud.google.com](https://console.cloud.google.com/)
- **X (Twitter):** [developer.twitter.com](https://developer.twitter.com/)
- **LinkedIn:** [developer.linkedin.com](https://developer.linkedin.com/)

## Pending API Access Requests

| Platform | Step | Status | Notes |
|----------|------|--------|-------|
| **YouTube** | Enable Data API v3 in GCP | **TODO** | Linked to `kpihx.labs@gmail.com` project |
| **Meta** | Create App in Dev Portal | **TODO** | Need validation for Instagram Graph |
| **X** | Apply for Free/Basic tier | **TODO** | Essential for automated tweeting |
| **WhatsApp** | Business API setup | **IN PROGRESS** | Transitioning from unofficial bot to Cloud API |

- **Cloudflare:** `~/.cloudflared/`, `wrangler.toml` (project-specific)
- **Tailscale:** `/etc/tailscale/`, native systemd service
- **M365:** Managed via `m365 login`
- **GCP:** `~/.config/gcloud/`

## Operating Procedures

### Cloudflare Management
- List tunnels: `cloudflared tunnel list`
- Deploy Worker: `wrangler deploy`

### Microsoft 365 Management
- Check login: `m365 status`
- Manage users/apps: Use `m365` commands (see `k-mail` for mail-specifics).

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-20 | [ANTIGRAVITY] | v1.0.0 — Initial creation; added tool registry for Cloudflare, Tailscale, GCP, Azure, and Social Media. |
| [SUMMARY] | — | Initial version |
