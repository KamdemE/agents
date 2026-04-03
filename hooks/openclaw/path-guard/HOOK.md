---
name: path-guard
description: "Advisory path guard for .agents file edits surfaced through OpenClaw."
metadata:
  openclaw:
    emoji: "🛡️"
    events:
      - message:sent
---

# Hook: path-guard

Fires on `message:sent`. If the event includes a target file path, calls
`core/path_guard.py` against the message content with that path. If
violations are found for a file inside `$HOME/.agents/`, returns a warning
`systemMessage` so the agent can self-correct on its next turn.

## Input
```json
{ "content": "...", "filePath": "/abs/path", "role": "assistant", ... }
```

## Output (violation found)
```json
{ "systemMessage": "⚠️ PATH GUARD: ..." }
```

## Output (clean)
```json
{}
```
