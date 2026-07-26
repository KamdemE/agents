#!/usr/bin/env python3
"""
Gemini hook: BeforeTool
Event: fires before a tool executes (matcher: write_file|replace).
Core: path_guard + skill_edit_guard for `.agents/` file writes.
Impact: deny → tool execution is blocked with reason shown to agent.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import path_guard, skill_edit_guard

# Map Gemini tool name → (content_field, path_field)
_TOOL_FIELDS = {
    "write_file": ("content", "file_path"),
    "replace": ("new_string", "file_path"),
}

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================


def handle_before_tool(tool_name: str, tool_input: dict) -> dict:
    fields = _TOOL_FIELDS.get(tool_name)
    if not fields:
        return {"decision": "allow"}

    content_field, path_field = fields
    content = tool_input.get(content_field, "")
    file_path = tool_input.get(path_field, "")

    errors = path_guard.guard_content(content, file_path=file_path)
    skill_result = skill_edit_guard.evaluate_skill_edit(tool_name, tool_input)
    errors.extend(skill_result["errors"])
    if errors:
        return {
            "decision": "deny",
            "reason": skill_edit_guard.build_edit_block_message(
                tool_name,
                skill_result["file_path"] or file_path or "unknown path",
                errors,
                skill_result["notes"],
            ),
        }
    return {"decision": "allow"}


# ==============================================================================
# PART 2: MAIN ORCHESTRATOR
# ==============================================================================


def main():
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})
        print(json.dumps(handle_before_tool(tool_name, tool_input)))
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        print(json.dumps({"decision": "allow"}), file=sys.stderr)


if __name__ == "__main__":
    main()
