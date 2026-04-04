"""Core: pre-write validation for KπX skill edits."""
from __future__ import annotations

import os
import re
from pathlib import Path

from core.settings import AGENTS_MD, SKILLS_DIR, display_path, is_hook_feature_enabled
from core.skill_content_guard import validate_skill_content_text
from core.skill_structure_guard import (
    extract_frontmatter,
    extract_table_after_heading,
    parse_table_rows,
    validate_skill_structure_text,
)

_TOOL_SPECS = {
    "Write": {"mode": "full", "path_field": "file_path", "content_field": "content"},
    "write_file": {"mode": "full", "path_field": "path", "content_field": "content"},
    "Edit": {
        "mode": "replace",
        "path_field": "file_path",
        "old_field": "old_string",
        "new_field": "new_string",
    },
    "replace": {
        "mode": "replace",
        "path_field": "file_path",
        "old_field": "old_string",
        "new_field": "new_string",
    },
}


def _is_kpi_skill_path(file_path: str) -> bool:
    if not file_path:
        return False
    path = Path(file_path).resolve()
    try:
        path.relative_to(Path(SKILLS_DIR))
    except ValueError:
        return False
    return path.name == "SKILL.md" and path.parent.name.startswith("k-")


def _read_existing_text(file_path: str) -> str | None:
    try:
        return Path(file_path).read_text(encoding="utf-8")
    except OSError:
        return None


def _extract_version(text: str) -> str:
    frontmatter = extract_frontmatter(text) or ""
    match = re.search(r'^\s*version:\s*"?(.*?)"?\s*$', frontmatter, re.MULTILINE)
    return match.group(1).strip() if match else ""


def _table_snapshot(text: str, heading: str) -> str:
    return "\n".join(extract_table_after_heading(text, heading)).strip()


def _build_candidate_text(tool_name: str, tool_input: dict) -> tuple[str | None, str | None]:
    spec = _TOOL_SPECS.get(tool_name)
    if not spec:
        return None, None

    if spec["mode"] == "full":
        content = tool_input.get(spec["content_field"], "")
        return (content if isinstance(content, str) else ""), None

    file_path = tool_input.get(spec["path_field"], "")
    existing_text = _read_existing_text(file_path)
    if existing_text is None:
        return None, None

    old_string = tool_input.get(spec["old_field"], "")
    new_string = tool_input.get(spec["new_field"], "")
    if not isinstance(old_string, str) or not isinstance(new_string, str):
        return None, None
    if old_string not in existing_text:
        return None, None
    return existing_text.replace(old_string, new_string, 1), existing_text


def _check_required_updates(file_path: str, previous_text: str | None, candidate_text: str) -> list[str]:
    if previous_text is None or previous_text == candidate_text:
        return []
    if not is_hook_feature_enabled("skill_edit_header_footer_check"):
        return []

    errors: list[str] = []
    path = display_path(file_path)
    if _extract_version(previous_text) == _extract_version(candidate_text):
        errors.append(
            f"{path}: edited `SKILL.md` without bumping `metadata.version` "
            f"(see {AGENTS_MD} → '### Provenance & Quality')."
        )
    if _table_snapshot(previous_text, "Changelog") == _table_snapshot(candidate_text, "Changelog"):
        errors.append(
            f"{path}: edited `SKILL.md` without updating `## Changelog` "
            f"(see {AGENTS_MD} → '### Provenance & Quality')."
        )
    if (
        os.path.basename(os.path.dirname(file_path)) == "k-context"
        and is_hook_feature_enabled("skill_edit_k_context_session_log")
        and _table_snapshot(previous_text, "Session Log") == _table_snapshot(candidate_text, "Session Log")
    ):
        errors.append(
            f"{path}: edited `k-context` without updating `## Session Log` "
            f"(see {AGENTS_MD} → '### Session & Memory')."
        )
    return errors


def _build_notes(file_path: str) -> list[str]:
    if (
        os.path.basename(os.path.dirname(file_path)) == "k-context"
        and is_hook_feature_enabled("skill_edit_k_context_project_note")
    ):
        return [
            "Also review `## Active Projects` if this work changed project scope, status, or introduced a new project."
        ]
    return []


def evaluate_skill_edit(tool_name: str, tool_input: dict, check_header_footer: bool = True) -> dict:
    """Return a normalized result for one prospective skill edit.

    Args:
        check_header_footer: When False, skip the version/Changelog/SessionLog
            completeness check. Use False in PreToolUse hooks that delegate the
            check to a PostToolUse advisory instead.
    """
    file_path = tool_input.get(_TOOL_SPECS[tool_name]["path_field"], "") if tool_name in _TOOL_SPECS else ""
    if not is_hook_feature_enabled("skill_edit_guard") or not _is_kpi_skill_path(file_path):
        return {"file_path": file_path, "errors": [], "notes": []}

    candidate_text, previous_text = _build_candidate_text(tool_name, tool_input)
    if candidate_text is None:
        return {"file_path": file_path, "errors": [], "notes": []}

    errors: list[str] = []
    if is_hook_feature_enabled("skill_edit_structure_check"):
        errors.extend(validate_skill_structure_text(file_path, candidate_text))
    if is_hook_feature_enabled("skill_edit_content_check"):
        errors.extend(validate_skill_content_text(file_path, candidate_text))
    if check_header_footer:
        errors.extend(_check_required_updates(file_path, previous_text, candidate_text))
    return {
        "file_path": file_path,
        "errors": errors,
        "notes": _build_notes(file_path),
    }


def build_edit_block_message(tool_name: str, file_path: str, errors: list[str], notes: list[str] | None = None) -> str:
    """Format one human-readable blocking message for Gemini/Claude/OpenClaw wrappers."""
    details = "\n".join(f"- {item}" for item in errors)
    message = (
        f"CRITICAL: Tool `{tool_name}` cannot write {display_path(file_path)} until the skill update is complete.\n"
        f"{details}"
    )
    if notes:
        message += "\n\nNotes:\n" + "\n".join(f"- {item}" for item in notes)
    return message
