#!/usr/bin/env python3
"""
Claude hook: PreToolUse
Event: fires after Claude creates tool parameters and before the tool executes.
Core: path_guard — enforces $HOME/$USER generalization only for .agents writes.
"""
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import path_guard

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
        if errors:
            return _build_deny(
                f"CRITICAL: Tool '{tool_name}' blocked for {file_path or 'unknown path'}:\n"
                + "\n".join(f"- {error}" for error in errors)
            )
        return {}

    if tool_name == "Bash":
        command = tool_input.get("command", "")
        if not command:
            return {}
        home = os.environ["HOME"]
        agents_in_cmd = ".agents/" in command or f"{home}/.agents" in command or "$HOME/.agents" in command
        if not agents_in_cmd:
            return {}
        errors = path_guard.guard_content(
            command,
            checks=[path_guard.check_path_generalization],
        )
        if errors:
            return _build_deny(
                "CRITICAL: Bash command targeting $HOME/.agents/ contains forbidden hardcoded home paths:\n"
                + "\n".join(f"- {error}" for error in errors)
            )
    return {}


def main():
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})
        print(json.dumps(handle_pre_tool_use(tool_name, tool_input)))
    except Exception:
        print(json.dumps({}))


if __name__ == "__main__":
    main()
