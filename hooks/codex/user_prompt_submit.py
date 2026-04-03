#!/usr/bin/env python3
"""
Codex hook: UserPromptSubmit
Event: fires whenever a user submits a prompt (matcher ignored).
Core: prompt_injector (date/time) + skill_watcher (rules reminder + skill mods).
Input stdin: {"session_id":"...","cwd":"...","hook_event_name":"UserPromptSubmit",...}
Output stdout: JSON with `hookSpecificOutput.additionalContext` injected before the LLM call.
"""
import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import prompt_injector, skill_watcher

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================

def handle_user_prompt_submit(agent_name: str, cwd: str | None = None) -> dict:
    dynamic = prompt_injector.get_dynamic_context(cwd=cwd)
    changed = skill_watcher.get_recently_changed_skills()
    reminder = skill_watcher.build_reminder_message(agent_name, changed)
    parts = [part for part in (dynamic, reminder) if part]
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
        print(json.dumps(handle_user_prompt_submit(agent_name, cwd=input_data.get("cwd"))))
    except Exception:
        sys.exit(0)

if __name__ == "__main__":
    main()
