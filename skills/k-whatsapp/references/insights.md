# k-whatsapp Insights

Purpose: durable behavioral memory to improve proactive drafting and reduce user corrections.

## Communication Style

- Default language preference: French unless conversation history clearly indicates otherwise.
- Preferred tone in most peer messages: concise, neutral, respectful, low-excitement wording.
- Keep follow-ups practical and action-oriented; avoid over-enthusiastic phrasing unless requested.

## Message Patterns

- Common workflow: inspect recent exchange, adapt wording to user's own style, draft, send, then summarize what was done.
- For contact lookup, use JID-based flow rather than name-based text search.

## Tooling Patterns

- Use whats-mcp (`http` or `stdio`) for conversation and sending actions.
- Community root JIDs are structural containers, not direct messaging targets.
- HTTP streamable transport can reject calls with `Bad Request: No valid session ID provided` when the MCP client lost/never established its session header context; stdio fallback can still work in the same moment.
- Server-side health/admin endpoints are useful to separate transport-session issues from WhatsApp account connectivity (`/health`, `/admin/status`).
- Edge keeps WhatsApp Web data under profile IndexedDB (`$HOME/.config/microsoft-edge/Default/IndexedDB/https_web.whatsapp.com_0.indexeddb.*`), but this browser session store is not drop-in compatible with Baileys auth files.
- For deterministic reuse across tools, prefer one canonical Baileys auth/state directory (`WHATSAPP_STATE_DIR`) and let clients consume that service over MCP/HTTP rather than trying to share browser internals.

## Open Behavior Rules

- Always read this file before composing any significant WhatsApp reply.
- After each WhatsApp task, append any new reusable pattern (tone, correction, workflow preference, recurring contacts, recurring topics).

