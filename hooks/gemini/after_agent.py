#!/usr/bin/env python3
"""
Gemini hook: AfterAgent
Event: fires when the agent loop ends (after response is generated).
Core: response_validator — enforces Comments/Remarks/TODO/Suggestions structure.
Impact: deny → agent must retry; allow → turn completes.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import response_validator

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================


def handle_after_agent(input_data: dict) -> dict:
    prompt_response = input_data.get("prompt_response", "")
    # Skip validation on cancelled/interrupted turns (empty response or
    # explicit cancelled flag from Gemini CLI).
    if input_data.get("cancelled") or not prompt_response.strip():
        return {"decision": "allow"}
    # Skip validation if the response contains NO section markers at all.
    # This covers two cases that both cause infinite retry loops on deny:
    #   1. Partial response generated before user cancelled (pre-section content)
    #   2. Model meta-response ("I'll fix the sections") after a prior deny
    # In both cases the model cannot self-correct in the retry; allow silently
    # and let the BeforeAgent injection remind it on the next real user turn.
    has_any_section = any(
        pattern.search(prompt_response)
        for _, pattern in response_validator._SECTION_DEFS
    )
    if not has_any_section:
        return {"decision": "allow"}
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
        print(json.dumps(handle_after_agent(input_data)))
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        print(json.dumps({"decision": "allow"}), file=sys.stderr)


if __name__ == "__main__":
    main()
