#!/usr/bin/env python3
"""
Claude hook: Stop
Event: fires when Claude has finished responding.
Core: response_validator + session_guard.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import response_validator, session_guard


def handle_stop(
    last_assistant_message: str | None = None,
    stop_hook_active: bool = False,
) -> dict:
    # Avoid a self-sustaining retry loop if Claude is already retrying due to this same Stop hook.
    if last_assistant_message and not stop_hook_active:
        validation = response_validator.validate_response(last_assistant_message)
        if not validation["passed"]:
            return {
                "decision": "block",
                "reason": "CRITICAL: Your last response violates AGENTS.md rules:\n"
                + "\n".join(f"- {error}" for error in validation["errors"]),
            }

    result = session_guard.check_agents_git_status()
    if result["has_changes"]:
        return {
            "decision": "block",
            "reason": result["message"],
        }
    return {}


def main():
    try:
        input_data = json.load(sys.stdin)
        print(
            json.dumps(
                handle_stop(
                    last_assistant_message=input_data.get("last_assistant_message"),
                    stop_hook_active=bool(input_data.get("stop_hook_active")),
                )
            )
        )
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        print(json.dumps({}), file=sys.stderr)


if __name__ == "__main__":
    main()
