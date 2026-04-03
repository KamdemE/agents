"""
Core: Skill Watcher
Detects recently modified skills and injects a pointer-based rules reminder.
Rules text lives in $HOME/.agents/AGENTS.md (single source of truth — no duplication).
Wrappers decide where to inject this reminder in their own lifecycle.
"""
import os
import time

from core.settings import AGENTS_MD_DISPLAY, SKILLS_DIR, is_hook_feature_enabled
from core.response_validator import build_required_structure_reminder
from core.session_guard import build_agents_maintenance_checklist
from core.skill_content_guard import build_skill_content_violation_report
from core.skill_structure_guard import build_skill_structure_violation_report

_AGENTS_MD = AGENTS_MD_DISPLAY


def get_recently_changed_skills(skills_dir: str = None, minutes: int = 10) -> list:
    """Returns list of .md files in skills_dir modified within the last N minutes."""
    if not is_hook_feature_enabled("recent_skill_changes"):
        return []
    if skills_dir is None:
        skills_dir = SKILLS_DIR

    changed = []
    threshold = time.time() - (minutes * 60)

    for root, _, files in os.walk(skills_dir):
        for file in files:
            if file.endswith(".md"):
                file_path = os.path.join(root, file)
                try:
                    if os.path.getmtime(file_path) > threshold:
                        changed.append(file_path)
                except OSError:
                    continue
    return changed


def build_reminder_message(agent_name: str, changed_skills: list) -> str:
    """
    Constructs a rules reminder that POINTS to AGENTS.md — never duplicates rule text.
    This avoids desync: if AGENTS.md rules change, this hook stays valid automatically.
    """
    reminder_parts: list[str] = []

    if is_hook_feature_enabled("rules_reminder"):
        reminder_parts.append(build_required_structure_reminder(agent_name).rstrip())

    if is_hook_feature_enabled("path_rule_reminder"):
        reminder_parts.append(
            f"- Path generalization (applies ONLY to files within $HOME/.agents/):\n"
            f"  Forbidden: literal home directory paths or bare ~. Required: $HOME and $USER.\n"
            f"  {_AGENTS_MD} → '### Style' for the full rule."
        )

    if changed_skills:
        changed_block: list[str] = []
        if is_hook_feature_enabled("recent_skill_structure_report"):
            violations = build_skill_structure_violation_report(changed_skills)
            if violations:
                changed_block.append(violations)
        if is_hook_feature_enabled("recent_skill_content_report"):
            content_violations = build_skill_content_violation_report(changed_skills)
            if content_violations:
                changed_block.append(content_violations)
        if is_hook_feature_enabled("recent_skill_maintenance_checklist"):
            changed_block.append(
                build_agents_maintenance_checklist(
                    changed_skill_files=changed_skills,
                    include_git_sync=False,
                )
            )
        if changed_block:
            reminder_parts.append("RECENTLY MODIFIED SKILLS (last 10 min):\n" + "\n\n".join(changed_block))

    if not reminder_parts:
        return ""
    return "<agent-mandatory-reminder>\nPRE-RESPONSE RULES CHECK:\n" + "\n".join(reminder_parts) + "\n</agent-mandatory-reminder>"
