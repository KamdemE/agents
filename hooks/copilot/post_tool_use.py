#!/usr/bin/env python3
"""
Copilot VS Code hook: PostToolUse
Event: fires after a tool execution.
Role: advisory SKILL.md header/footer completeness check (non-blocking).
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import skill_edit_guard
from core.settings import is_hook_feature_enabled


def _normalize_replace_payload(
    tool_name: str, tool_input: dict
) -> tuple[str, str, str] | None:
    if tool_name in {"Edit", "replace"}:
        file_path = tool_input.get("file_path", "")
        old_string = tool_input.get("old_string", "")
        new_string = tool_input.get("new_string", "")
        return str(file_path or ""), str(old_string or ""), str(new_string or "")

    if tool_name in {"replace_string_in_file", "replaceStringInFile"}:
        file_path = tool_input.get("filePath") or tool_input.get("file_path") or ""
        old_string = tool_input.get("oldString") or tool_input.get("old_string") or ""
        new_string = tool_input.get("newString") or tool_input.get("new_string") or ""
        return str(file_path), str(old_string), str(new_string)

    return None


def _build_advisory(file_path: str, previous_text: str, current_text: str) -> dict:
    errors = skill_edit_guard._check_required_updates(
        file_path, previous_text, current_text
    )
    if not errors:
        return {}

    lines = ["SKILL.md advisory (edit applied - follow up needed before session end):"]
    lines.extend(f"- {e}" for e in errors)
    lines.append("Complete with another edit to avoid session_guard blocking at Stop.")
    return {
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": "\n".join(lines),
        },
        "systemMessage": "SKILL.md update is incomplete; see advisory context.",
    }


def handle_post_tool_use(tool_name: str, tool_input: dict) -> dict:
    if not is_hook_feature_enabled("skill_edit_guard"):
        return {}
    if not is_hook_feature_enabled("skill_edit_header_footer_check"):
        return {}

    normalized = _normalize_replace_payload(tool_name, tool_input)
    if normalized is None:
        return {}

    file_path, old_string, new_string = normalized
    if not skill_edit_guard._is_kpi_skill_path(file_path):
        return {}
    if not old_string or not new_string:
        return {}

    try:
        current_text = Path(file_path).read_text(encoding="utf-8")
    except OSError:
        return {}

    if new_string not in current_text:
        return {}

    previous_text = current_text.replace(new_string, old_string, 1)
    return _build_advisory(file_path, previous_text, current_text)


def main() -> None:
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})
        print(json.dumps(handle_post_tool_use(tool_name, tool_input)))
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        print(json.dumps({}))


if __name__ == "__main__":
    main()
