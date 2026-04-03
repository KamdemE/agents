#!/usr/bin/env python3
"""
Gemini hook: BeforeTool
Event: fires before a tool executes (matcher: write_file|replace).
Core: path_guard — blocks hardcoded paths ONLY for writes within $HOME/.agents/.
Impact: deny → tool execution is blocked with reason shown to agent.
"""
import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import path_guard

# Map Gemini tool name → (content_field, path_field)
_TOOL_FIELDS = {
    "write_file": ("content", "path"),
    "replace":    ("new_string", "file_path"),
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

    # path_guard scopes automatically: no-op if file_path not in $HOME/.agents/
    errors = path_guard.guard_content(content, file_path=file_path)
    if errors:
        return {
            "decision": "deny",
            "reason": (
                f"CRITICAL: Tool '{tool_name}' blocked — rule violations in "
                f"{file_path or 'unknown path'}:\n"
                + "\n".join(f"- {e}" for e in errors)
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
    except Exception:
        print(json.dumps({"decision": "allow"}))

if __name__ == "__main__":
    main()
