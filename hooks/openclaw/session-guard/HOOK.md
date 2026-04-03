---
name: session-guard
description: "Advisory finalization guard for pending .agents maintenance."
metadata:
  openclaw:
    emoji: "🧾"
    events:
      - command:stop
---

# Hook: session-guard

Fires on `command:stop`. Calls `core/session_guard.py` to inspect
`$HOME/.agents/` git status and build the shared finalization reminder when
there are pending changes.

## Output (pending maintenance)
```json
{ "systemMessage": "⚠️ SESSION FINALIZATION REQUIRED: $HOME/.agents/ has uncommitted changes..." }
```

## Output (clean)
```json
{}
```
