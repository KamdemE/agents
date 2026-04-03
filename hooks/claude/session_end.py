#!/usr/bin/env python3
"""
Claude hook: SessionEnd
Event: fires when the Claude session terminates.
Core: session_guard — advisory reminder only.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import session_guard


def handle_session_end() -> dict:
    result = session_guard.check_agents_git_status()
    if result["has_changes"]:
        return {"systemMessage": f"⚠️ {result['message']}"}
    return {}


def main():
    try:
        json.load(sys.stdin)
        print(json.dumps(handle_session_end()))
    except Exception:
        print(json.dumps({}))


if __name__ == "__main__":
    main()
