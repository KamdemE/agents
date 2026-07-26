#!/usr/bin/env python3
"""
Gemini hook: SessionEnd
Event: fires when a session ends (exit, clear).
Core: session_guard — checks if $HOME/.agents/ git repo has uncommitted changes.
Impact: advisory (SessionEnd cannot block in Gemini) — uses systemMessage.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import session_guard

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================


def handle_session_end() -> dict:
    result = session_guard.check_agents_git_status()
    if result["has_changes"]:
        return {"systemMessage": f"⚠️ {result['message']}"}
    return {}


# ==============================================================================
# PART 2: MAIN ORCHESTRATOR
# ==============================================================================


def main():
    try:
        json.load(sys.stdin)
        print(json.dumps(handle_session_end()))
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        print(json.dumps({}), file=sys.stderr)


if __name__ == "__main__":
    main()
