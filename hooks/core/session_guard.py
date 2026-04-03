"""Core: delayed finalization guard for a dirty $HOME/.agents/ repo."""
from __future__ import annotations

import os
import subprocess
import time

from core.settings import (
    AGENTS_DIR,
    AGENTS_MD,
    display_path,
    get_hook_timing,
    is_hook_feature_enabled,
)
from core.skill_content_guard import build_skill_content_violation_report
from core.skill_structure_guard import build_skill_structure_violation_report


def _status_line_to_path(status_line: str) -> str:
    payload = status_line[3:] if len(status_line) > 3 else status_line
    if " -> " in payload:
        payload = payload.split(" -> ", 1)[1]
    return payload.strip()


def _status_line_to_abs_path(status_line: str, agents_dir: str) -> str:
    return os.path.join(agents_dir, _status_line_to_path(status_line))


def _collect_git_status_lines() -> list[str]:
    result = subprocess.run(
        ["git", "-C", AGENTS_DIR, "status", "--porcelain"],
        capture_output=True,
        text=True,
        timeout=get_hook_timing("subprocess_timeout_seconds"),
        check=False,
    )
    return [line.rstrip() for line in result.stdout.splitlines() if line.strip()]


def _oldest_dirty_age_minutes(changed_files: list[str], agents_dir: str) -> int | None:
    ages: list[float] = []
    now = time.time()
    for status_line in changed_files:
        abs_path = _status_line_to_abs_path(status_line, agents_dir)
        try:
            ages.append((now - os.path.getmtime(abs_path)) / 60)
        except OSError:
            continue
    if not ages:
        return None
    return int(max(ages))


def _changed_skill_paths(changed_files: list[str], agents_dir: str) -> list[str]:
    return [
        _status_line_to_abs_path(line, agents_dir)
        for line in changed_files
        if _status_line_to_path(line).endswith("SKILL.md")
    ]


def _build_finalization_message(changed_files: list[str], agents_dir: str, oldest_age_minutes: int | None) -> str:
    skill_paths = _changed_skill_paths(changed_files, agents_dir)
    other_paths = [
        _status_line_to_abs_path(line, agents_dir)
        for line in changed_files
        if not _status_line_to_path(line).endswith("SKILL.md")
    ]

    grace = get_hook_timing("session_dirty_grace_minutes")
    lines = [
        "SESSION FINALIZATION REQUIRED",
        "",
        (
            "$HOME/.agents/ is still dirty and the oldest pending change is older than "
            f"{grace} minute(s)."
            if oldest_age_minutes is not None
            else "$HOME/.agents/ is still dirty and should be finalized per AGENTS.md."
        ),
        "",
    ]

    if skill_paths:
        lines.append("Changed skill files:")
        lines.extend(f"  {display_path(path)}" for path in skill_paths)
        lines.append("")

        if is_hook_feature_enabled("session_skill_structure_report"):
            violations = build_skill_structure_violation_report(skill_paths)
            if violations:
                lines.extend(violations.splitlines())
                lines.append("")
        if is_hook_feature_enabled("session_skill_content_report"):
            violations = build_skill_content_violation_report(skill_paths)
            if violations:
                lines.extend(violations.splitlines())
                lines.append("")

    if other_paths:
        lines.append("Other changed files:")
        lines.extend(f"  {display_path(path)}" for path in other_paths)
        lines.append("")

    if is_hook_feature_enabled("session_maintenance_reminder"):
        lines.extend(
            (
                "Next:",
                f"- Re-read {AGENTS_MD} and finalize the pending .agents changes per its rules.",
                "- Update $HOME/.agents/skills/k-context/SKILL.md for this work.",
                "- Update any touched k-* skills and other affected .md files.",
                "- Commit and run `make -C $HOME/.agents push`.",
            )
        )

    return "\n".join(lines).rstrip()


def check_agents_git_status() -> dict:
    """Return the delayed finalization state for $HOME/.agents/."""
    if not is_hook_feature_enabled("session_dirty_repo"):
        return {
            "has_changes": False,
            "changed_files": [],
            "agents_dir": AGENTS_DIR,
            "oldest_age_minutes": None,
            "message": "",
        }

    try:
        changed_files = _collect_git_status_lines()
        if not changed_files:
            return {
                "has_changes": False,
                "changed_files": [],
                "agents_dir": AGENTS_DIR,
                "oldest_age_minutes": None,
                "message": "",
            }

        oldest_age_minutes = _oldest_dirty_age_minutes(changed_files, AGENTS_DIR)
        if is_hook_feature_enabled("session_dirty_grace_period"):
            grace = get_hook_timing("session_dirty_grace_minutes")
            if oldest_age_minutes is not None and oldest_age_minutes < grace:
                return {
                    "has_changes": False,
                    "changed_files": changed_files,
                    "agents_dir": AGENTS_DIR,
                    "oldest_age_minutes": oldest_age_minutes,
                    "message": "",
                }

        return {
            "has_changes": True,
            "changed_files": changed_files,
            "agents_dir": AGENTS_DIR,
            "oldest_age_minutes": oldest_age_minutes,
            "message": _build_finalization_message(changed_files, AGENTS_DIR, oldest_age_minutes),
        }
    except Exception:
        return {
            "has_changes": False,
            "changed_files": [],
            "agents_dir": AGENTS_DIR,
            "oldest_age_minutes": None,
            "message": "",
        }
