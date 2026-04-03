"""
Core: Response Validator
Validates a plain response string against the AGENTS.md response contract.
Error messages reference $HOME/.agents/AGENTS.md — never duplicate the full rule text.
"""
from __future__ import annotations

import re

from core.settings import AGENTS_MD_DISPLAY, AGENTS_STYLE_REF

_AGENTS_REF = AGENTS_STYLE_REF
_AGENTS_MD = AGENTS_MD_DISPLAY
_TODO_TABLE_HEADER = re.compile(
    r"\|\s*(Task|Tache)\s*\|\s*Urgent\s*\|\s*Important\s*\|",
    re.IGNORECASE,
)
_NUMBERED_ITEM = re.compile(r"^\d+\.\s+.+", re.MULTILINE)
_LIST_ITEM = re.compile(r"^\s*(?:[-*]|\d+\.)\s+.+", re.MULTILINE)
_HEADING_PREFIX = r"^(?:#{1,6}\s*)?"

_SECTION_DEFS = [
    (
        "comments",
        re.compile(_HEADING_PREFIX + r"(Commentaires|Comments)\s*:\s*$", re.IGNORECASE | re.MULTILINE),
    ),
    (
        "remarks",
        re.compile(_HEADING_PREFIX + r"(Remarques|Remarks)\s*:\s*$", re.IGNORECASE | re.MULTILINE),
    ),
    ("todos", re.compile(_HEADING_PREFIX + r"TODOs\s*$", re.IGNORECASE | re.MULTILINE)),
    (
        "suggestions",
        re.compile(
            _HEADING_PREFIX + r"(Suggestions\s+Proactives|Proactive\s+Suggestions)\s*:\s*$",
            re.IGNORECASE | re.MULTILINE,
        ),
    ),
]


def build_required_structure_reminder(agent_name: str) -> str:
    """Returns the mandatory response structure reminder used by wrappers."""
    return (
        f"- If {_AGENTS_MD} is not yet loaded, read it now.\n"
        f"  Mandatory response structure in this exact order:\n"
        f"  1. `Commentaires:` or `Comments:` (optional Markdown heading markers allowed)\n"
        f"  2. `Remarques:` or `Remarks:` — findings list, or `vide`/`empty` if none\n"
        f"  3. `TODOs` — from k-context ONLY (optional Markdown heading markers allowed)\n"
        f"     Table header accepted: [Task|Tache | Urgent | Important], filtered to [{agent_name}] or [ALL], max 3 rows\n"
        f"  4. `Suggestions Proactives:` or `Proactive Suggestions:` (at least 3 numbered suggestions; optional Markdown heading markers allowed)\n"
        f"  {_AGENTS_REF}\n"
    )


def _section_matches(response: str) -> list[tuple[str, int, int]]:
    matches: list[tuple[str, int, int]] = []
    for section_name, pattern in _SECTION_DEFS:
        match = pattern.search(response)
        if match:
            matches.append((section_name, match.start(), match.end()))
    return matches


def _find_sections(response: str) -> dict[str, tuple[int, int]]:
    matches = _section_matches(response)
    bounds: dict[str, tuple[int, int]] = {}
    for idx, (section_name, _, body_start) in enumerate(matches):
        next_start = matches[idx + 1][1] if idx + 1 < len(matches) else len(response)
        bounds[section_name] = (body_start, next_start)
    return bounds


def _extract_section_body(response: str, section_name: str) -> str:
    bounds = _find_sections(response)
    if section_name not in bounds:
        return ""
    start, end = bounds[section_name]
    return response[start:end].strip()


def check_section_order(response: str):
    """Checks presence and strict order of the mandatory sections."""
    section_positions: list[tuple[str, int]] = []
    for section_name, pattern in _SECTION_DEFS:
        match = pattern.search(response)
        if not match:
            return (
                "Missing mandatory response sections. Expected, in order: "
                "`Commentaires/Comments`, `Remarques/Remarks`, `TODOs`, "
                f"`Suggestions Proactives/Proactive Suggestions`. {_AGENTS_REF}"
            )
        section_positions.append((section_name, match.start()))

    expected_order = [name for name, _ in _SECTION_DEFS]
    actual_order = [name for name, _ in sorted(section_positions, key=lambda item: item[1])]
    if actual_order != expected_order:
        return (
            "Mandatory sections are out of order. Expected exact order: "
            "`Commentaires/Comments` → `Remarques/Remarks` → `TODOs` → "
            f"`Suggestions Proactives/Proactive Suggestions`. {_AGENTS_REF}"
        )
    return None


def check_collaboration_comments(response: str):
    """Checks the mandatory Commentaires/Comments section body is non-empty."""
    body = _extract_section_body(response, "comments")
    if not body:
        return f"Missing body under mandatory `Commentaires/Comments` section. {_AGENTS_REF}"
    return None


def check_remarks_section(response: str):
    """Checks the mandatory Remarques/Remarks section content."""
    body = _extract_section_body(response, "remarks")
    if not body:
        return f"Missing body under mandatory `Remarques/Remarks` section. {_AGENTS_REF}"

    normalized = body.strip().lower()
    if normalized in {"vide", "empty"}:
        return None
    if not _LIST_ITEM.search(body):
        return (
            "The mandatory `Remarques/Remarks` section must contain either `vide`/`empty` "
            f"or a flat list of findings. {_AGENTS_REF}"
        )
    return None


def check_todo_table(response: str):
    """Checks the mandatory TODOs section with the required table columns."""
    body = _extract_section_body(response, "todos")
    if not _TODO_TABLE_HEADER.search(body):
        return (
            "Missing mandatory TODOs table [Task|Tache | Urgent | Important] "
            f"inside the `TODOs` section. Tasks must come from k-context only. {_AGENTS_REF}"
        )
    return None


def check_proactive_suggestions(response: str):
    """Checks the mandatory Proactive Suggestions section (at least 3 numbered)."""
    body = _extract_section_body(response, "suggestions")
    suggestions = _NUMBERED_ITEM.findall(body)
    if len(suggestions) < 3:
        return (
            f"Found only {len(suggestions)} proactive suggestion(s) inside the suggestions section. "
            f"At least 3 required. {_AGENTS_REF}"
        )
    return None


_VALIDATORS = [
    check_section_order,
    check_collaboration_comments,
    check_remarks_section,
    check_todo_table,
    check_proactive_suggestions,
]


def validate_response(response: str) -> dict:
    """Runs all validators. Returns {'passed': bool, 'errors': list[str]}."""
    errors = [error for validator in _VALIDATORS if (error := validator(response)) is not None]
    return {"passed": len(errors) == 0, "errors": errors}
