#!/usr/bin/env python3
"""
Gemini hook: BeforeAgent
Event: fires after user submits prompt, before the agent starts planning.
Core: prompt_injector + skill_watcher.
"""
import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import prompt_injector, skill_watcher

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================

def handle_before_agent(agent_name: str, cwd: str | None = None) -> dict:
    dynamic = prompt_injector.get_dynamic_context(cwd=cwd)
    reminder = skill_watcher.build_governance_reminder()
    parts = [part for part in (dynamic, reminder) if part]
    if not parts:
        return {}
    return {"hookSpecificOutput": {"additionalContext": "\n".join(parts)}}

# ==============================================================================
# PART 2: MAIN ORCHESTRATOR
# ==============================================================================

def main():
    try:
        input_data = json.load(sys.stdin)
        agent_name = sys.argv[1] if len(sys.argv) > 1 else "AGENT"
        print(json.dumps(handle_before_agent(agent_name, cwd=input_data.get("cwd"))))
    except Exception:
        print(json.dumps({"decision": "allow"}))

if __name__ == "__main__":
    main()
