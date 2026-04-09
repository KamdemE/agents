# Hybrid Memory-Curation Vision (`.agents/`)

## Problem

Real-time updates across `k-*` files improve long-term quality but can slow execution flow during active work.

## Proposed Hybrid Model

### 1) Immediate (minimal) during run

Record only critical facts:
- IDs (`UID`, task id, message id, JID)
- concrete action taken
- incidents/errors and blockers

Goal: preserve speed while keeping auditability.

### 2) Deferred (automatic) memory curation

Use a dedicated `memory-curator` agent at:
- `session_end`, or
- inactivity window `> X minutes`

Pipeline:
1. read transcript/events
2. extract durable learnings
3. propose/update `k-*` patches in batch
4. apply consistent updates (version + changelog + context sync)

### 3) Guardrails (always immediate)

Never defer these:
- broken auth / broken transport
- security rules and policy changes
- workflow-breaking regressions
- irreversible decision changes

## Completion Note (user intent extension)

Inside normal assistant responses/reflections, leave compact “curation hints” to guide the deferred memory-curator:
- `CURATION_HINT: <fact>`
- `CURATION_PRIORITY: high|medium|low`
- `CURATION_TARGET: k-mail|k-whatsapp|k-context|...`

This allows lightweight live execution plus high-quality post-run memory updates.

## Why This Fits

- Fast run-time interaction
- Preserves long-term knowledge quality
- Reduces repetitive manual memory maintenance
- Keeps critical safety/incident memory immediate
