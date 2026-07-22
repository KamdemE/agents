"""Core: settings for paths, timings, startup skills, and feature flags."""
from __future__ import annotations

import os

HOME = os.environ["HOME"]

# ==============================================================================
# PATHS
# ==============================================================================

AGENTS_DIR = os.path.join(HOME, ".agents")
SKILLS_DIR = os.path.join(AGENTS_DIR, "skills")
HOOKS_DIR = os.path.join(AGENTS_DIR, "hooks")
AGENTS_MD = "$HOME/.agents/AGENTS.md"
SOUL_MD = "$HOME/.agents/SOUL.md"
USER_MD = "$HOME/.agents/USER.md"
STARTUP_SKILLS = ("k-context",)

# ==============================================================================
# TIME WINDOWS
# ==============================================================================

HOOK_TIMINGS = {
    "session_dirty_grace_minutes": 30,
    "subprocess_timeout_seconds": 5,
}

# ==============================================================================
# FEATURE FLAGS
# ==============================================================================

HOOK_FEATURES = {
    # context_injector.py
    "startup_context":                     True,  # Inject k-context at session bootstrap.
    "device_detection":                    True,  # Auto-detect device via Tailscale and inject the matching k-infra skill.

    # prompt_injector.py
    "dynamic_context":                     True,  # Inject date, time, user@host, and cwd before each turn.

    # skill_watcher.py
    "governance_reminder":                 True,  # Inject the compact AGENTS pointer reminder before each turn.

    # response_validator.py
    "response_validation":                 True,  # Enable final-response validation as a whole.
    "response_check_section_order":        True,  # Enforce Comments/Remarks/TODOs/Suggestions exact section order.
    "response_check_comments":             True,  # Require a non-empty Commentaires/Comments section body.
    "response_check_remarks":              True,  # Require Remarques/Remarks to contain `vide`/`empty` or a flat list.
    "response_check_todos":                True,  # Require the TODOs table header [Task|Tache | Urgent | Important].
    "response_check_suggestions":          True,  # Require at least 3 numbered proactive suggestions.

    # path_guard.py
    "path_generalization":                 True,  # Enforce $HOME/$USER-style paths for .agents file edits.

    # skill_edit_guard.py
    "skill_edit_guard":                    True,  # Validate KπX skill edits before the write tool executes.
    "skill_edit_structure_check":          True,  # Require edited k-* skills to remain structurally valid.
    "skill_edit_content_check":            True,  # Require bundled top-level files to stay surfaced in the skill.
    "skill_edit_header_footer_check":      True,  # Require metadata.version and changelog updates on edited skills.
    "skill_edit_k_context_session_log":    True,  # Require k-context edits to also update Session Log.
    "skill_edit_k_context_project_note":   True,  # Add a soft reminder about Active Projects on k-context edits.

    # session_guard.py
    "session_dirty_repo":                  True,  # Check whether $HOME/.agents/ still has pending git changes.
    "session_dirty_grace_period":          True,  # Only surface finalization after the grace window has elapsed.
    "session_skill_structure_report":      True,  # Include skill_structure_guard findings in finalization.
    "session_skill_content_report":        True,  # Include skill_content_guard findings in finalization.
    "session_maintenance_reminder":        True,  # Include the compact finalization steps in session messages.
}


def is_hook_feature_enabled(feature_name: str) -> bool:
    """Return True/False for one declared feature flag."""
    return bool(HOOK_FEATURES.get(feature_name, False))


def get_hook_timing(name: str) -> int:
    """Return one shared hook timing constant."""
    return int(HOOK_TIMINGS[name])


def get_skill_md_path(skill_name: str) -> str:
    """Return the absolute path to one skill's SKILL.md file."""
    return os.path.join(SKILLS_DIR, skill_name, "SKILL.md")


def get_startup_skill_paths() -> list[str]:
    """Return the startup skill paths in order."""
    return [get_skill_md_path(skill_name) for skill_name in STARTUP_SKILLS]


def display_path(path: str) -> str:
    """Render an absolute path with $HOME for human-readable hook output."""
    return path.replace(HOME, "$HOME")
