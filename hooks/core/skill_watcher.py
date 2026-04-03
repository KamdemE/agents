"""
Core: Skill Watcher
Detects recently modified skills and injects a pointer-based rules reminder.
Rules text lives in $HOME/.agents/AGENTS.md (single source of truth — no duplication).
Wrappers decide where to inject this reminder in their own lifecycle.
"""
import os
import time

from core.settings import AGENTS_MD_DISPLAY, SKILLS_DIR
from core.response_validator import build_required_structure_reminder
from core.session_guard import build_agents_maintenance_checklist
from core.skill_content_guard import build_skill_content_violation_report
from core.skill_structure_guard import build_skill_structure_violation_report

_AGENTS_MD = AGENTS_MD_DISPLAY


def get_recently_changed_skills(skills_dir: str = None, minutes: int = 10) -> list:
    """Returns list of .md files in skills_dir modified within the last N minutes."""
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
    reminder = "<agent-mandatory-reminder>\n"
    reminder += "PRE-RESPONSE RULES CHECK:\n"

    # --- Response structure (single source of truth: response_validator) ---
    reminder += build_required_structure_reminder(agent_name)

    # --- Path rule (scoped) ---
    reminder += (
        f"- Path generalization (applies ONLY to files within $HOME/.agents/):\n"
        f"  Forbidden: literal home directory paths or bare ~. Required: $HOME and $USER.\n"
        f"  {_AGENTS_MD} → '### Style' for the full rule.\n"
    )

    # --- Skill modifications (dynamic, injected only when needed) ---
    if changed_skills:
        violations = build_skill_structure_violation_report(changed_skills)
        content_violations = build_skill_content_violation_report(changed_skills)
        reminder += (
            "\nRECENTLY MODIFIED SKILLS (last 10 min):\n"
            + (f"{violations}\n\n" if violations else "")
            + (f"{content_violations}\n\n" if content_violations else "")
            + build_agents_maintenance_checklist(
                changed_skill_files=changed_skills,
                include_git_sync=False,
            )
            + "\n"
        )

    reminder += "</agent-mandatory-reminder>"
    return reminder
