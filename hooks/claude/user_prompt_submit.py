#!/usr/bin/env python3
"""
Claude hook: UserPromptSubmit
Event: fires when a user submits a prompt, before Claude processes it.
Core: prompt_injector + skill_watcher.
"""
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import prompt_injector, skill_watcher


def handle_user_prompt_submit(agent_name: str, cwd: str | None = None) -> dict:
    dynamic = prompt_injector.get_dynamic_context(cwd=cwd)
    reminder = skill_watcher.build_governance_reminder()
    parts = [part for part in (dynamic, reminder) if part]
    if not parts:
        return {}
    return {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": "\n".join(parts),
        }
    }


def main():
    try:
        input_data = json.load(sys.stdin)
        agent_name = sys.argv[1] if len(sys.argv) > 1 else "CLAUDE"
        print(json.dumps(handle_user_prompt_submit(agent_name, cwd=input_data.get("cwd"))))
    except Exception:
        print(json.dumps({}))


if __name__ == "__main__":
    main()
