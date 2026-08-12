# What's Up — Status Digest Protocol

## Triggers (non-exhaustive)

"What's up", "what's new", "quoi de neuf", "des nouvelles", concise greetings when KπX expects a status snapshot — treat as What's up.

## Domain Map

| Intent | Load | Description |
|--------|------|-------------|
| Full (no qualifier) | See sequential rule | One domain per assistant response only — never merge |
| context / projects | `k-context` | Active Projects + Session Log + Brainstorm Registry — exhaustive, no synthesis |
| mail | `k-mail` | Mail briefing per `k-mail` `## What's up` section |
| whats / whatsapp | `k-whatsapp` | WhatsApp briefing per `k-whatsapp` `## What's up` section |
| tick | `k-tick` | TickTick briefing per `k-tick` `## What's up` section |
| tg / telegram | `k-tg` | Deep Telegram triage (Issues → General → infra bots); LAST in the default ladder |

## Default Full Sequence

`k-context` → `k-mail` → `k-whatsapp` → `k-tick` → `k-tg`

## Hard Rules

### One generation = one slice
When executing the full sequence, deliver EXACTLY one domain per assistant turn. PROHIBITED: running two+ briefings in a single generation. After each slice, stop and offer: « What's up suivant : [mail | whats | tick | tg] — dis `continue` ou le nom du canal. »

### Mail auth safety
In What's up mail flows: NEVER run `m365 login` / `m365 logout` / `m365 setup`. Only read/status M365 commands allowed. If auth is missing, stop and ask KπX to authenticate manually.

### Batch depth rule
Treat each slice as a batch deep-dive workflow: keep exploring until the information set is materially complete. Stop only when additional fetches are unlikely to add relevant signal.

### Gold standard
Deliver the most detailed output possible by default, with zero-loss reporting. Do NOT compress into a short recap, do NOT replace raw facts with synthesis, and do NOT ask KπX to request more detail later.
