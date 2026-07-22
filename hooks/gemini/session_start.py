#!/usr/bin/env python3
"""
Gemini hook: SessionStart
Event: fires when a session begins or resumes.
Core: context_injector — injects k-context startup context.
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
    if not data["context"] and not data["system_message"]:
        return {}
    return {
        "hookSpecificOutput": {"additionalContext": data["context"]},
        "systemMessage": data["system_message"],
    }

# ==============================================================================
# PART 2: MAIN ORCHESTRATOR
# ==============================================================================

def main():
    try:
        json.load(sys.stdin)
        agent_name = sys.argv[1] if len(sys.argv) > 1 else "AGENT"
        print(json.dumps(handle_session_start(agent_name)))
    except Exception:
        print(json.dumps({"decision": "allow"}))

if __name__ == "__main__":
    main()
