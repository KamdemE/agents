#!/usr/bin/env python3
"""
Codex hook: PreToolUse
Event: fires before a tool executes.
Core: path_guard + skill_edit_guard for structured file edits when the runtime exposes them.
Input stdin: {"session_id":"...","hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"..."}}
Output stdout: JSON deny/allow  |  exit 2 = hard block
Note: if Codex only exposes Bash in the current runtime, this hook is effectively a no-op.
"""
import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import path_guard, skill_edit_guard

# For future structured edit events. Current Codex runtimes may not expose them.
_WRITE_TOOLS = {
    "Write": ("content", "file_path"),
    "Edit": ("new_string", "file_path"),
    "write_file": ("content", "path"),
    "replace": ("new_string", "file_path"),
}

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================

def handle_pre_tool_use(tool_name: str, tool_input: dict) -> dict | None:
    """Returns a deny dict if violations found, else None (allow via exit 0)."""
    fields = _WRITE_TOOLS.get(tool_name)
    if not fields:
        return None

    content_field, path_field = fields
    content = tool_input.get(content_field, "")
    file_path = tool_input.get(path_field, "")
    errors = path_guard.guard_content(content, file_path=file_path)
    skill_result = skill_edit_guard.evaluate_skill_edit(tool_name, tool_input)
    errors.extend(skill_result["errors"])
    if errors:
        return {
            "decision": "block",
            "reason": skill_edit_guard.build_edit_block_message(
                tool_name,
                skill_result["file_path"] or file_path or "unknown path",
                errors,
                skill_result["notes"],
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
            reason = result.get("reason", "")
            print(json.dumps(result))
            if reason:
                print(reason, file=sys.stderr)
            sys.exit(2)  # exit 2 = hard block in Codex
        sys.exit(0)
    except Exception:
        sys.exit(0)  # fail-safe

if __name__ == "__main__":
    main()
