#!/usr/bin/env python3
"""
Copilot VS Code hook: Stop
Event: fires when an agent session attempts to stop.
Core: response_validator + session_guard.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import response_validator, session_guard


def _extract_last_assistant_response(transcript_path: str | None) -> str:
    if not transcript_path:
        return ""

    transcript = Path(transcript_path)
    if not transcript.exists():
        return ""

    last_text = ""
    try:
        with transcript.open(encoding="utf-8") as handle:
            for line in handle:
                record = json.loads(line)
                if record.get("type") != "response_item":
                    continue
                payload = record.get("payload", {})
                if (
                    payload.get("type") != "message"
                    or payload.get("role") != "assistant"
                ):
                    continue
                text = "".join(
                    item.get("text", "")
                    for item in payload.get("content", [])
                    if item.get("type") in {"output_text", "input_text"}
                ).strip()
                if text:
                    last_text = text
    except (OSError, json.JSONDecodeError):
        return ""

    return last_text


def _build_block(reason: str) -> dict:
    return {
        "hookSpecificOutput": {
            "hookEventName": "Stop",
            "decision": "block",
            "reason": reason,
        }
    }


def handle_stop(
    last_assistant_message: str | None = None,
    transcript_path: str | None = None,
    stop_hook_active: bool = False,
) -> dict:
    response_text = (
        last_assistant_message or ""
    ).strip() or _extract_last_assistant_response(transcript_path)
    if response_text and not stop_hook_active:
        validation = response_validator.validate_response(response_text)
        if not validation["passed"]:
            return _build_block(
                "CRITICAL: Your last response violates AGENTS.md rules:\n"
                + "\n".join(f"- {error}" for error in validation["errors"])
            )

    result = session_guard.check_agents_git_status()
    if result["has_changes"] and not stop_hook_active:
        return _build_block(result["message"])

    return {}


def main() -> None:
    try:
        input_data = json.load(sys.stdin)
        print(
            json.dumps(
                handle_stop(
                    last_assistant_message=input_data.get("last_assistant_message"),
                    transcript_path=input_data.get("transcript_path"),
                    stop_hook_active=bool(input_data.get("stop_hook_active")),
                )
            )
        )
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        print(json.dumps({}))


if __name__ == "__main__":
    main()
