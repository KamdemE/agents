#!/usr/bin/env python3
"""
Codex hook: Stop
Event: fires when a conversation turn ends (matcher ignored).
Core: response_validator + session_guard.
Impact: exit 2 = Codex displays stderr and forces another turn.
Input stdin: {"session_id":"...","hook_event_name":"Stop","transcript_path":"...",...}
"""
import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from core import response_validator, session_guard

# ==============================================================================
# PART 1: EVENT HANDLER
# ==============================================================================

def _extract_last_assistant_response(transcript_path: str | None) -> str:
    """Extract the last assistant final answer from a Codex transcript."""
    if not transcript_path:
        return ""

    transcript = Path(transcript_path)
    if not transcript.exists():
        return ""

    last_assistant = ""
    last_final = ""

    try:
        with transcript.open(encoding="utf-8") as handle:
            for line in handle:
                record = json.loads(line)
                if record.get("type") != "response_item":
                    continue
                payload = record.get("payload", {})
                if payload.get("type") != "message" or payload.get("role") != "assistant":
                    continue
                text = "".join(
                    item.get("text", "")
                    for item in payload.get("content", [])
                    if item.get("type") in {"output_text", "input_text"}
                ).strip()
                if not text:
                    continue
                last_assistant = text
                if payload.get("phase") == "final_answer":
                    last_final = text
    except (OSError, json.JSONDecodeError):
        return ""

    return last_final or last_assistant


def handle_stop(transcript_path: str | None = None) -> int:
    """Returns exit code: 2 if response/finalization checks fail, 0 otherwise."""
    response_text = _extract_last_assistant_response(transcript_path)
    if response_text:
        validation = response_validator.validate_response(response_text)
        if not validation["passed"]:
            print(
                "CRITICAL: Your last response violates AGENTS.md rules:\n"
                + "\n".join(f"- {error}" for error in validation["errors"]),
                file=sys.stderr,
            )
            return 2

    result = session_guard.check_agents_git_status()
    if result["has_changes"]:
        print(result["message"], file=sys.stderr)
        return 2  # force Codex to act on the message
    return 0

# ==============================================================================
# PART 2: MAIN ORCHESTRATOR
# ==============================================================================

def main():
    try:
        input_data = json.load(sys.stdin)
        sys.exit(handle_stop(input_data.get("transcript_path")))
    except Exception:
        sys.exit(0)  # fail-safe

if __name__ == "__main__":
    main()
