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

## Search Pitfalls

- **Phonetic/typo variants matter:** When searching for compound terms like "Navier-Stokes", try both halves separately ("navier", "stokes") AND phonetic typos ("nvier", "stock") — WhatsApp messages often contain misspellings. Example: "nvier et stock" = "Navier-Stokes" with typos.
- `find-messages` with a misspelled term can still match if the substring exists (e.g., "nvier" matched "janvier" in a different chat) — always verify the match is semantically relevant, not just a substring hit.

## Open Behavior Rules

- Always read this file before composing any significant WhatsApp reply.
- After each WhatsApp task, append any new reusable pattern (tone, correction, workflow preference, recurring contacts, recurring topics).

## Investigation Pipeline (2026-09-09)

- Vague chat refs from KπX ("k-whats 336") resolve with a global `find-messages` keyword search first — never assume a JID prefix (the ENSPY CAF thread was NOT in the 336-prefixed group).
- Voice notes: `media-download` by message ID → `~/Downloads/Whats-Proxy/<phone>/` → `k-whisper 1 -p <file>` (transcript auto-saved next to audio). Set `lang` correctly for French-accented speech; default `en` still yields a usable gist for Franglais.

