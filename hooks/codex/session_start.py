#!/usr/bin/env python3
"""
Codex hook: SessionStart
Event: fires when a session starts (matcher: startup|resume).
Core: context_injector — injects k-context + k-workspace + session date.
Input stdin: {"session_id":"...","cwd":"...","hook_event_name":"SessionStart","model":"..."}
Output stdout: JSON with `hookSpecificOutput.additionalContext` plus optional `systemMessage`.
"""
import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import context_injector

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================

def handle_session_start(agent_name: str) -> dict:
    data = context_injector.build_context_output(agent_name)
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
    except Exception:
        sys.exit(0)

if __name__ == "__main__":
    main()
