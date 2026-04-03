---
name: context-injector
description: "Injects KπX startup context into OpenClaw bootstrap."
metadata:
  openclaw:
    emoji: "🧠"
    events:
      - agent:bootstrap
---

# Hook: context-injector

Fires on `agent:bootstrap`. Calls `core/context_injector.py` via subprocess
and returns the result as `additionalContext` to the OpenClaw agent.

## Input
Standard OpenClaw bootstrap event payload.

## Output
```json
{ "additionalContext": "MANDATORY STARTUP CONTEXT:\n..." }
```
