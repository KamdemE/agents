#!/usr/bin/env python3
"""
Codex hook: SessionStart
Event: fires when a session starts (matcher: startup|resume).
Core: context_injector — injects k-context + session date.
Input stdin: {"session_id":"...","cwd":"...","hook_event_name":"SessionStart","model":"..."}
Output stdout: JSON with `hookSpecificOutput.additionalContext` plus optional `systemMessage`.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import context_injector

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================


def handle_session_start(agent_name: str) -> dict:
    data = context_injector.build_context_output(agent_name)
    if not data["context"] and not data["system_message"]:
        return {}
    return {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": data["context"],
        },
        "systemMessage": data["system_message"],
    }


# ==============================================================================
# PART 2: MAIN ORCHESTRATOR
# ==============================================================================


def main():
    try:
        json.load(sys.stdin)
        agent_name = sys.argv[1] if len(sys.argv) > 1 else "CODEX"
        print(json.dumps(handle_session_start(agent_name)))
    except (json.JSONDecodeError, KeyError, TypeError, ValueError, IndexError):
        sys.exit(0)


if __name__ == "__main__":
    main()
