# Google Workspace Full-MCP Vision

## Objective

Manage Google Workspace end-to-end from MCP-based agents and skills, using Google-native APIs first, with extensible modules for workflows beyond basic mail/chat usage.

## Scope (Target Capabilities)

- Gmail: read/search/archive/labels/send/drafts/templates/thread workflows
- Calendar: events, reminders, shared calendars, conflict checks
- Drive: file lifecycle, sharing, permissions, folder policies, retention
- Docs/Sheets/Slides: create/update/export, structured generation pipelines
- Contacts: lookup, enrichment, dedup, segmentation
- Admin (where authorized): users/groups/org policies/audit exports
- Chat/Meet signals (if enabled APIs and scopes permit)

## Architecture Principle

### 1) Modular MCP stack

Split by domain with shared auth/session core:
- `google-mail-mcp`
- `google-calendar-mcp`
- `google-drive-mcp`
- `google-docs-mcp`
- optional `google-admin-mcp`

Each module exposes a narrow contract and composes through orchestrator agents.

### 2) Auth & identity

- OAuth2 / service-account flows managed centrally
- least-privilege scopes per module
- explicit account routing for multi-account contexts
- credential rotation and revocation runbooks

### 3) Skill layer

Dedicated `k-google-workspace` skill should define:
- account map and scope matrix
- operation playbooks (read/write/recovery)
- incident patterns and anti-footgun rules
- cross-MCP choreography examples (mail -> calendar -> drive)

## Delivery Strategy

1. Start with Gmail + Calendar + Drive high-value workflows.
2. Add docs automation (Docs/Sheets/Slides generation and updates).
3. Add admin/audit modules only when governance and scopes are validated.
4. Keep all workflows source-of-truth-first and policy-auditable.

## "And more" extension lane

Use workflow orchestrators to combine Google with other MCPs:
- mail deadlines -> TickTick
- drive docs -> presentation pipelines
- calendar events -> WhatsApp summaries (with approval gates)

This keeps Google as a sovereign productivity backbone while remaining composable with the wider KπX agent OS.
