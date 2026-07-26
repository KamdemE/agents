#!/usr/bin/env python3
"""
Codex hook: UserPromptSubmit
Event: fires whenever a user submits a prompt (matcher ignored).
Core: prompt_injector + skill_watcher.
Input stdin: {"session_id":"...","cwd":"...","hook_event_name":"UserPromptSubmit",...}
Output stdout: JSON with `hookSpecificOutput.additionalContext` injected before the LLM call.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import prompt_injector, skill_watcher
from core.prompt_enforcer import ENFORCEMENT_PROMPT

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================


def handle_user_prompt_submit(agent_name: str, cwd: str | None = None) -> dict:
    dynamic = prompt_injector.get_dynamic_context(cwd=cwd)
    reminder = skill_watcher.build_governance_reminder()
    enforcement = ENFORCEMENT_PROMPT
    parts = [part for part in (dynamic, reminder, enforcement) if part]
    if not parts:
        return {}
    return {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": "\n".join(parts),
        }
    }


# ==============================================================================
# PART 2: MAIN ORCHESTRATOR
# ==============================================================================


def main():
    try:
        input_data = json.load(sys.stdin)
        agent_name = sys.argv[1] if len(sys.argv) > 1 else "CODEX"
        print(
            json.dumps(handle_user_prompt_submit(agent_name, cwd=input_data.get("cwd")))
        )
    except (json.JSONDecodeError, KeyError, TypeError, ValueError, IndexError):
        sys.exit(0)


if __name__ == "__main__":
    main()
