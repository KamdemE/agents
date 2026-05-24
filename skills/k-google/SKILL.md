---
name: k-google
description: >
  KπX Google stack — gcloud (GCP container) and gws (Workspace content). Drive files via
  k-rclone/k-drive. Load before Google Cloud or Workspace tasks.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
  scope: operations
allowed-tools: Bash(gws:*), Bash(gcloud:*), Bash(rclone:*)
---

# KπX — Google (Cloud + Workspace)

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

## Cloud hub

Registry map: `$HOME/.agents/skills/k-cloud-tools/references/cloud-hub.md` · load **`k-cloud-tools`** when routing across providers.

## Two planes (mandatory)

| Plane | Tool | Scope |
|-------|------|--------|
| **Container** | `gcloud` | GCP projects, IAM, Compute, GKE, buckets, API enablement |
| **Content** | `gws` | Gmail, Drive API, Calendar, Sheets, Docs (Discovery CLI) |
| **Local files** | `rclone` | Mounted trees — **`k-rclone`**, semantics — **`k-drive`** |

**Rule:** infra → `gcloud`. User mail/calendar/docs API → `gws`. Bulk file browse → mounts, not API alone.

## Tools (verify with `!<cmd>`)

| Binary | Runbook |
|--------|---------|
| `gcloud` | Google Cloud SDK — `gcloud version` |
| `gws` | `$HOME/Work/techskills/gws-cli.md` — `npm install -g @googleworkspace/cli` |
| `rclone` | `$HOME/.agents/skills/k-rclone/SKILL.md` |

Auth: `gws auth setup` — **KπX-owned** (agents do not complete OAuth). Secrets via **`k-bw`** / `bw-env`.

**Read-only default** until KπX approves send/upload.

```bash
gws gmail users messages list --params '{"userId":"me","maxResults":5}'
gws drive files list --params '{"pageSize":10}'
```

## Mail exception

| Account | Tool | Skill |
|---------|------|-------|
| Poly Zimbra | mail-mcp | **`k-mail`** (canonical) |
| Gmail | `gws` gmail service | this skill |

## MCP / future

| Now | Optional later |
|-----|----------------|
| CLI: `gws`, `gcloud`, shell from agents | `workspace-mcp` (PyPI) |
| | Unified CLI+MCP contract → `references/mcp-cli-vision.md` |

## Cross-skills

| Task | Load |
|------|------|
| Mount / remote | `k-rclone` |
| `Gdrive_X` paths | `k-drive` |
| Poly mail | `k-mail` |
| Cloudflare / Tailscale | `k-cloud-tools` |
| GCP data pipelines | GCP skills + `gcloud` |

## Insights Discipline (mandatory)

- Read `$HOME/.agents/skills/k-google/references/insights.md` before non-trivial work in this skill domain.
- Update `$HOME/.agents/skills/k-google/references/insights.md` at the end of the task with durable lessons (mistakes to avoid, validated fixes, and anti-repeat guidance).
- Keep insights autonomous and evolutionary: add/refine/restructure entries proactively to prevent repeated errors.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-05-25 | [CURSOR] | v1.1.0 — Uniform cloud-hub routing; compact layout; removed duplicate prose. |
| [SUMMARY] | — | v1.0.0 — Initial stack: gcloud + gws + rclone/k-drive; gws 0.22.5 installed. |
