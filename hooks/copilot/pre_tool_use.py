#!/usr/bin/env python3
"""
Copilot VS Code hook: PreToolUse
Event: fires before any tool execution.
Core: path_guard + skill_edit_guard for .agents file writes.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import path_guard, skill_edit_guard


def _build_deny(reason: str) -> dict:
    return {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason,
        }
    }


def _normalize_single_edit(tool_name: str, tool_input: dict) -> tuple[str | None, dict | None, str | None, str | None]:
    # Returns: (canonical_tool_name, canonical_input, file_path, content_for_path_guard)
    if tool_name in {"Write", "Edit", "write_file", "replace"}:
        if tool_name in {"Write", "write_file"}:
            path_value = tool_input.get("file_path") or tool_input.get("path")
            content_value = tool_input.get("content")
            canonical_tool = "Write" if tool_name == "Write" else "write_file"
            canonical_input = {
                "file_path": path_value,
                "path": path_value,
                "content": content_value if isinstance(content_value, str) else "",
            }
            return canonical_tool, canonical_input, str(path_value or ""), canonical_input["content"]

        old_value = tool_input.get("old_string")
        new_value = tool_input.get("new_string")
        path_value = tool_input.get("file_path")
        canonical_tool = "Edit" if tool_name == "Edit" else "replace"
        canonical_input = {
            "file_path": path_value,
            "old_string": old_value if isinstance(old_value, str) else "",
            "new_string": new_value if isinstance(new_value, str) else "",
        }
        return canonical_tool, canonical_input, str(path_value or ""), canonical_input["new_string"]

    if tool_name in {"create_file", "createFile"}:
        path_value = tool_input.get("filePath") or tool_input.get("path")
        content_value = tool_input.get("content")
        canonical_input = {
            "path": path_value,
            "content": content_value if isinstance(content_value, str) else "",
        }
        return "write_file", canonical_input, str(path_value or ""), canonical_input["content"]

    if tool_name in {"replace_string_in_file", "replaceStringInFile"}:
        path_value = tool_input.get("filePath") or tool_input.get("file_path")
        old_value = tool_input.get("oldString") or tool_input.get("old_string")
        new_value = tool_input.get("newString") or tool_input.get("new_string")
        canonical_input = {
            "file_path": path_value,
            "old_string": old_value if isinstance(old_value, str) else "",
            "new_string": new_value if isinstance(new_value, str) else "",
        }
        return "replace", canonical_input, str(path_value or ""), canonical_input["new_string"]

    return None, None, None, None


def _validate_one(tool_name: str, tool_input: dict) -> list[str]:
    canonical_tool, canonical_input, file_path, content = _normalize_single_edit(tool_name, tool_input)
    if not canonical_tool or canonical_input is None:
        return []

    errors = path_guard.guard_content(content or "", file_path=file_path or "")
    skill_result = skill_edit_guard.evaluate_skill_edit(canonical_tool, canonical_input)
    errors.extend(skill_result["errors"])
    if errors:
        return [
            skill_edit_guard.build_edit_block_message(
                canonical_tool,
                skill_result["file_path"] or file_path or "unknown path",
                errors,
                skill_result["notes"],
            )
        ]
    return []


def handle_pre_tool_use(tool_name: str, tool_input: dict) -> dict:
    if tool_name in {"multi_replace_string_in_file", "multiReplaceStringInFile"}:
        replacements = tool_input.get("replacements", [])
        for replacement in replacements:
            synthetic = {
                "filePath": replacement.get("filePath"),
                "oldString": replacement.get("oldString"),
                "newString": replacement.get("newString"),
            }
            errors = _validate_one("replace_string_in_file", synthetic)
            if errors:
                return _build_deny("\n".join(errors))
        return {}

    errors = _validate_one(tool_name, tool_input)
    if errors:
        return _build_deny("\n".join(errors))
    return {}


def main() -> None:
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})
        print(json.dumps(handle_pre_tool_use(tool_name, tool_input)))
    except Exception:
        print(json.dumps({}))


if __name__ == "__main__":
    main()
