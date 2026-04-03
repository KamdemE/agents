#!/usr/bin/env python3
"""
Codex hook: PreToolUse
Event: fires before a tool executes (matcher: Bash — only tool Codex currently emits).
Core: path_guard — blocks hardcoded paths ONLY for Bash commands that write to $HOME/.agents/.
Input stdin: {"session_id":"...","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"..."}}
Output stdout: JSON deny/allow  |  exit 2 = hard block
Note: Codex currently only emits "Bash" for PreToolUse.
"""
import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import path_guard

# For Codex Bash tool, command field to guard
_TOOL_CONTENT_FIELD = {
    "Bash": "command",
    "bash": "command",
}

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================

def handle_pre_tool_use(tool_name: str, tool_input: dict) -> dict | None:
    """Returns a deny dict if violations found, else None (allow via exit 0)."""
    field = _TOOL_CONTENT_FIELD.get(tool_name)
    if not field:
        return None

    content = tool_input.get(field, "")
    if not content:
        return None

    # For Bash commands, we can't easily know the target file_path before execution.
    # Pass None — path_guard will apply checks (best-effort for .agents/ write detection).
    # Only guard if the command references .agents/ path
    home = __import__("os").environ["HOME"]
    agents_in_cmd = ".agents/" in content or f"{home}/.agents" in content
    if not agents_in_cmd:
        return None

    errors = path_guard.guard_content(content, file_path=None, checks=[path_guard.check_path_generalization])
    if errors:
        return {
            "decision": "block",
            "reason": (
                f"CRITICAL: Tool '{tool_name}' blocked — hardcoded path in command "
                f"targeting $HOME/.agents/:\n"
                + "\n".join(f"- {e}" for e in errors)
            ),
        }
    return None

# ==============================================================================
# PART 2: MAIN ORCHESTRATOR
# ==============================================================================

def main():
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})
        result = handle_pre_tool_use(tool_name, tool_input)
        if result:
            print(json.dumps(result))
            sys.exit(2)  # exit 2 = hard block in Codex
        sys.exit(0)
    except Exception:
        sys.exit(0)  # fail-safe

if __name__ == "__main__":
    main()
