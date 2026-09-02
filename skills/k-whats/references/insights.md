# k-whats Insights

Purpose: durable behavioral memory to improve proactive drafting and reduce user corrections.

## Communication Style

- Default language preference: French unless conversation history clearly indicates otherwise.
- Preferred tone in most peer messages: concise, neutral, respectful, low-excitement wording.
- Keep follow-ups practical and action-oriented; avoid over-enthusiastic phrasing unless requested.

## Message Patterns

- Common workflow: inspect recent exchange, adapt wording to user's own style, draft, send, then summarize what was done.
- For contact lookup, use JID-based flow rather than name-based text search.

## Tooling Patterns

- When sending via `whats-proxy do send-text`, **avoid leading emoji / non-UTF-8-safe bytes** at the start of `text`; prefer a plain ASCII opener (e.g. `Pour ...`) to prevent a replacement character or truncation on the first grapheme.
- Use `whats-proxy do <action>` for all conversation, reading, and sending actions (proxy-only, no MCP).
- Community root JIDs are structural containers, not direct messaging targets.
- `whats-proxy` daemon manages Baileys socket, store persistence, and reconnection — one daemon per account with O_EXCL lock.
- For deterministic reuse across tools, prefer the canonical Baileys auth/state directory managed by `whats-proxy` rather than trying to share browser internals.

## Open Behavior Rules

- Always read this file before composing any significant WhatsApp reply.
- After each WhatsApp task, append any new reusable pattern (tone, correction, workflow preference, recurring contacts, recurring topics).

