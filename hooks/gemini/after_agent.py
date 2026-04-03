#!/usr/bin/env python3
"""
Gemini hook: AfterAgent
Event: fires when the agent loop ends (after response is generated).
Core: response_validator — enforces Comments/Remarks/TODO/Suggestions structure.
Impact: deny → agent must retry; allow → turn completes.
"""
import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import response_validator

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================

def handle_after_agent(prompt_response: str) -> dict:
    result = response_validator.validate_response(prompt_response)
    if not result["passed"]:
        return {
            "decision": "deny",
            "reason": "CRITICAL: Your response violates AGENTS.md rules:\n"
                      + "\n".join(f"- {e}" for e in result["errors"]),
        }
    return {"decision": "allow"}

# ==============================================================================
# PART 2: MAIN ORCHESTRATOR
# ==============================================================================

def main():
    try:
        input_data = json.load(sys.stdin)
        response = input_data.get("prompt_response", "")
        print(json.dumps(handle_after_agent(response)))
    except Exception:
        print(json.dumps({"decision": "allow"}))

if __name__ == "__main__":
    main()
