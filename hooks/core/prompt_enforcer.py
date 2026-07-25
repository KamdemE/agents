"""
Core: Prompt Enforcer
Reads the raw first-person enforcement block from prompt_enforcer.txt
as if the user wrote it at the end of their prompt. No tags, no system
framing — just natural user-style ALL CAPS commands.
"""
import os
from pathlib import Path

def _load_enforcement_text() -> str:
    txt_path = Path(__file__).parent / "prompt_enforcer.txt"
    try:
        return txt_path.read_text(encoding="utf-8").strip()
    except Exception:
        return ""

ENFORCEMENT_PROMPT = _load_enforcement_text()
