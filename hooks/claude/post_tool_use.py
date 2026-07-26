#!/usr/bin/env python3
"""
Claude hook: PostToolUse
Event: fires after a tool executes, before the result is shown to the model.
Role: advisory SKILL.md header/footer completeness check (non-blocking).

After Write/Edit on a k-* SKILL.md, reads the post-edit file state, reconstructs
the previous state from old_string, and warns if version/Changelog/SessionLog were
not updated in this edit. The agent can then do a follow-up Edit to complete the
update. No blocking — enforcement falls back to session_guard at Stop.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import skill_edit_guard
from core.settings import is_hook_feature_enabled

_EDIT_TOOLS = {"Write", "Edit"}


def handle_post_tool_use(tool_name: str, tool_input: dict) -> dict:
    if tool_name not in _EDIT_TOOLS:
        return {}
    if not is_hook_feature_enabled("skill_edit_guard"):
        return {}
    if not is_hook_feature_enabled("skill_edit_header_footer_check"):
        return {}

    file_path = tool_input.get("file_path", "")
    if not skill_edit_guard._is_kpi_skill_path(file_path):
        return {}

    # Read the actual post-edit file state
    try:
        current_text = Path(file_path).read_text(encoding="utf-8")
    except OSError:
        return {}

    # Reconstruct the previous state for Edit calls
    if tool_name == "Edit":
        old_string = tool_input.get("old_string", "")
        new_string = tool_input.get("new_string", "")
        if not (old_string and new_string and new_string in current_text):
            return {}
        previous_text = current_text.replace(new_string, old_string, 1)
    else:
        # Write: no pre-write state available for comparison
        return {}

    errors = skill_edit_guard._check_required_updates(
        file_path, previous_text, current_text
    )
    if not errors:
        return {}

    lines = [
        "⚠️  SKILL.md advisory (edit applied — follow up needed before session end):"
    ]
    lines.extend(f"   - {e}" for e in errors)
    lines.append(
        "   → Complete the update with another Edit covering all required sections "
        "to avoid session_guard blocking at Stop."
    )
    return {"output": "\n".join(lines)}


def main() -> None:
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})
        result = handle_post_tool_use(tool_name, tool_input)
        print(json.dumps(result))
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        print(json.dumps({}), file=sys.stderr)


if __name__ == "__main__":
    main()
