"""
Core: Settings
Shared constants for all hook modules. Single source of truth — never duplicate here.
$HOME is resolved once at import time; all paths are absolute.
Import with: from core.settings import AGENTS_DIR, K_CONTEXT_PATH, AGENTS_MD, ...
"""
import os

HOME = os.environ["HOME"]

AGENTS_DIR = os.path.join(HOME, ".agents")
AGENTS_MD = os.path.join(AGENTS_DIR, "AGENTS.md")
AGENTS_MD_DISPLAY = "$HOME/.agents/AGENTS.md"
SKILLS_DIR = os.path.join(HOME, ".agents/skills")
K_CONTEXT_PATH = os.path.join(HOME, ".agents/skills/k-context/SKILL.md")
K_WORKSPACE_PATH = os.path.join(HOME, ".agents/skills/k-workspace/SKILL.md")

AGENTS_STYLE_REF = f"(see {AGENTS_MD_DISPLAY} → '### Style')"

HOOK_FEATURES = {
    # context_injector.py
    "startup_context":                    True,  # Inject k-context + k-workspace at SessionStart / bootstrap.

    # prompt_injector.py
    "dynamic_context":                    True,  # Inject date, time, user@host, and current directory per turn.

    # skill_watcher.py
    "rules_reminder":                     True,  # Inject the AGENTS response-structure reminder block.
    "path_rule_reminder":                 True,  # Inject the reminder about $HOME/$USER path generalization in .agents/.
    "recent_skill_changes":               True,  # Detect recently modified SKILL.md files before building skill reminders.
    "recent_skill_structure_report":      True,  # Include skill_structure_guard findings in the reminder.
    "recent_skill_content_report":        True,  # Include skill_content_guard findings in the reminder.
    "recent_skill_maintenance_checklist": True,  # Include the maintenance checklist for modified skills.

    # response_validator.py
    "response_validation":                True,  # Enable final-response validation as a whole.
    "response_check_section_order":       True,  # Enforce Comments/Remarks/TODOs/Suggestions exact section order.
    "response_check_comments":            True,  # Require a non-empty Commentaires/Comments section body.
    "response_check_remarks":             True,  # Require Remarques/Remarks to contain `vide`/`empty` or a flat list.
    "response_check_todos":               True,  # Require the TODOs table header [Task|Tache | Urgent | Important].
    "response_check_suggestions":         True,  # Require at least 3 numbered proactive suggestions.

    # path_guard.py
    "path_generalization":                True,  # Enforce $HOME/$USER-style paths and reject bare ~ in .agents-targeted content.

    # session_guard.py
    "session_dirty_repo":                 True,  # Check whether $HOME/.agents/ has uncommitted changes.
    "session_skill_structure_report":     True,  # Include skill_structure_guard findings in session finalization.
    "session_skill_content_report":       True,  # Include skill_content_guard findings in session finalization.
    "session_maintenance_checklist":      True,  # Include the shared maintenance checklist in finalization.
}


def is_hook_feature_enabled(feature_name: str) -> bool:
    """Return True unless the feature is explicitly disabled."""
    return HOOK_FEATURES.get(feature_name, True)
