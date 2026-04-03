"""
Core: Session Guard
Checks if $HOME/.agents/ git repo has uncommitted changes.
If yes, returns a finalization message asking the agent to:
  1. Update header + footer (version + changelog) of each modified skill
  2. Update k-context (Session Log, Active Projects, TODOs)
  3. git commit + make push in $HOME/.agents/
Wrappers decide where to run this finalization check in their own lifecycle.
"""
import subprocess

from core.skill_content_guard import build_skill_content_violation_report
from core.settings import AGENTS_DIR, AGENTS_MD_DISPLAY
from core.skill_structure_guard import build_skill_structure_violation_report

_AGENTS_MD = AGENTS_MD_DISPLAY


def _status_line_to_path(status_line: str) -> str:
    """Extract the repo-relative path from one porcelain status line."""
    payload = status_line[3:] if len(status_line) > 3 else status_line
    if " -> " in payload:
        payload = payload.split(" -> ", 1)[1]
    return payload.strip()


def build_agents_maintenance_checklist(
    changed_skill_files: list[str] | None = None,
    include_git_sync: bool = False,
    agents_dir: str | None = None,
) -> str:
    """Single source of truth for the .agents maintenance checklist."""
    parts: list[str] = []

    if changed_skill_files:
        changed_list = "\n".join(f"  {path}" for path in changed_skill_files)
        parts.append(
            "For EACH modified skill file:\n"
            f"{changed_list}\n"
            "  1. Bump metadata.version in YAML frontmatter (header)\n"
            "  2. Add entry to Changelog table (footer, newest-first, max 2 + [SUMMARY])\n"
            f"  → Format rules: {_AGENTS_MD} → '### Provenance & Quality'"
        )

    parts.append(
        "Update $HOME/.agents/skills/k-context/SKILL.md:\n"
        "  - Changelog header: bump version\n"
        "  - Session Log: add entry for today's work (newest-first)\n"
        "  - Active Projects: update status of impacted projects\n"
        "  - TODOs: remove completed items only; do not invent new ones\n"
        f"  → Format rules: {_AGENTS_MD} → '### Session & Memory'"
    )

    if include_git_sync and agents_dir is not None:
        parts.append(
            f"Finally: git commit + make push in {agents_dir}\n"
            f"  → Rule: {_AGENTS_MD} → '### Provenance & Quality' (Kernel sync)"
        )

    return "\n\n".join(parts)


def _build_finalization_message(changed_files: list, agents_dir: str) -> str:
    skill_files = [f for f in changed_files if "skills/" in f]
    other_files = [f for f in changed_files if "skills/" not in f]
    skill_paths = [
        f"{agents_dir}/{_status_line_to_path(line)}"
        for line in skill_files
        if _status_line_to_path(line).endswith("SKILL.md")
    ]

    msg = "SESSION FINALIZATION REQUIRED: $HOME/.agents/ has uncommitted changes.\n\n"

    if skill_files:
        msg += "Modified skill files:\n"
        for f in skill_files:
            msg += f"  {f}\n"
        msg += "\n"
        violations = build_skill_structure_violation_report(skill_paths)
        if violations:
            msg += f"{violations}\n\n"
        content_violations = build_skill_content_violation_report(skill_paths)
        if content_violations:
            msg += f"{content_violations}\n\n"

    if other_files:
        msg += "Other changed files:\n"
        for f in other_files:
            msg += f"  {f}\n"
        msg += "\n"

    msg += build_agents_maintenance_checklist(
        changed_skill_files=skill_files,
        include_git_sync=True,
        agents_dir=agents_dir,
    )
    return msg


def check_agents_git_status() -> dict:
    """
    Returns:
        {
            'has_changes': bool,
            'changed_files': list[str],   # git status --porcelain lines
            'agents_dir': str,
            'message': str                # empty if no changes
        }
    Fail-safe: on any error returns has_changes=False (never blocks on crash).
    """
    try:
        result = subprocess.run(
            ["git", "-C", AGENTS_DIR, "status", "--porcelain"],
            capture_output=True, text=True, timeout=5
        )
        lines = [ln.strip() for ln in result.stdout.strip().splitlines() if ln.strip()]
        has_changes = bool(lines)
        return {
            "has_changes": has_changes,
            "changed_files": lines,
            "agents_dir": AGENTS_DIR,
            "message": _build_finalization_message(lines, AGENTS_DIR) if has_changes else "",
        }
    except Exception:
        # fail-safe: don't block on git errors
        return {
            "has_changes": False,
            "changed_files": [],
            "agents_dir": AGENTS_DIR,
            "message": "",
        }
