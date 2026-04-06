# Mail Tooling Rewrite Brainstorm

## Goal

Design a mail workspace that cleanly separates:

- `mail-cli` for the complete human-facing command surface.
- `mail-mcp` for a compact agent-facing transport.
- `mail-admin` for credentials, bootstrap, health, and diagnostics.
- `mail-skill` for hot instructions, templates, aliases, and usage policy.

## Core Idea

The MCP should stay small and stable.
The skill should stay editable and descriptive.
The CLI should stay complete.
The admin layer should stay secret-aware but not model-facing.

## Recommended MCP Shape

Prefer one validated `execute` tool over a large tool catalog.

Suggested payload:

- `action`
- `account`
- `args`
- `dry_run`

Optional support tools:

- `help`
- `auth_status`

## Secret Handling

Secrets must never pass through the skill prompt.
Instead:

1. The agent expresses intent.
2. The local runtime resolves the account.
3. The resolver reads the secret source of truth.
4. The mail engine executes the action.
5. The response is masked before returning.

## Why This Works

- Lower token usage than a large MCP tool surface.
- Better validation than a free-form command string.
- Easier to evolve the skill without touching the engine.
- Easier to keep CLI and MCP behavior aligned.

## Open Questions

- What should be the single source of truth for credentials?
- Should the MCP accept only structured payloads or also a tiny DSL?
- Which account aliases should be standard across mail, LinkedIn, and WhatsApp?
- How should templates and contact shortcuts be shared between skill and CLI?
