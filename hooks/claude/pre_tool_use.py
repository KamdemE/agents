#!/usr/bin/env python3
"""
Claude hook: PreToolUse
Event: fires after Claude creates tool parameters and before the tool executes.
Core: path_guard + skill_edit_guard for `.agents/` file writes.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import path_guard, skill_edit_guard

_WRITE_TOOLS = {
    "Write": ("content", "file_path"),
    "Edit": ("new_string", "file_path"),
}


def _build_deny(reason: str) -> dict:
    return {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }


def handle_pre_tool_use(tool_name: str, tool_input: dict) -> dict:
    if tool_name in _WRITE_TOOLS:
        content_field, path_field = _WRITE_TOOLS[tool_name]
        content = tool_input.get(content_field, "")
        file_path = tool_input.get(path_field, "")
        errors = path_guard.guard_content(content, file_path=file_path)
        # Header/footer check (version + Changelog + SessionLog) is delegated to
        # PostToolUse as a non-blocking advisory. Only structure + content checks
        # remain here as blocking guards.
        skill_result = skill_edit_guard.evaluate_skill_edit(
            tool_name, tool_input, check_header_footer=False
        )
        errors.extend(skill_result["errors"])
        if errors:
            return _build_deny(
                skill_edit_guard.build_edit_block_message(
                    tool_name,
                    skill_result["file_path"] or file_path or "unknown path",
                    errors,
                    skill_result["notes"],
                )
            )
        return {}
    return {}


def main():
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})
        print(json.dumps(handle_pre_tool_use(tool_name, tool_input)))
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        print(json.dumps({}), file=sys.stderr)


if __name__ == "__main__":
    main()
