#!/usr/bin/env python3
"""
Claude hook: SessionStart
Event: fires when a session begins or resumes.
Core: context_injector — injects k-context startup context.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import context_injector


def handle_session_start(agent_name: str) -> dict:
    data = context_injector.build_context_output(agent_name)
    if not data["context"] and not data["system_message"]:
        return {}
    return {
        "systemMessage": data["system_message"],
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": data["context"],
        },
    }


def main():
    try:
        json.load(sys.stdin)
        agent_name = sys.argv[1] if len(sys.argv) > 1 else "CLAUDE"
        print(json.dumps(handle_session_start(agent_name)))
    except (json.JSONDecodeError, KeyError, TypeError, ValueError, IndexError):
        print(json.dumps({}), file=sys.stderr)


if __name__ == "__main__":
    main()
