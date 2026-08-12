"""Core: settings for paths and feature flags used by the offline skill validators."""

from __future__ import annotations

import os

HOME = os.environ["HOME"]

# ==============================================================================
# PATHS
# ==============================================================================

AGENTS_DIR = os.path.join(HOME, ".agents")
SKILLS_DIR = os.path.join(AGENTS_DIR, "skills")
AGENTS_MD = "$HOME/.agents/AGENTS.md"

# ==============================================================================
# FEATURE FLAGS
# ==============================================================================
# Only flags actually read by skill_edit_guard.py. All other flags historically
# present here (startup/context/response-validation/session-guard families)
# were dead code left over from the deleted core/ hook architecture (OpenCode
# now owns all runtime hook logic in JS — see k-opencode/scripts/hooks/) and
# were purged 2026-08-09 (zero importers confirmed via grep before removal).

HOOK_FEATURES = {
    # skill_edit_guard.py
    "skill_edit_guard": True,  # Validate KπX skill edits before the write tool executes.
    "skill_edit_structure_check": True,  # Require edited k-* skills to remain structurally valid.
    "skill_edit_content_check": True,  # Require bundled top-level files to stay surfaced in the skill.
    "skill_edit_header_footer_check": True,  # Require metadata.version and changelog updates on edited skills.
    "skill_edit_k_context_session_log": True,  # Require k-context edits to also update Session Log.
    "skill_edit_k_context_project_note": True,  # Add a soft reminder about Active Projects on k-context edits.
}


def is_hook_feature_enabled(feature_name: str) -> bool:
    """Return True/False for one declared feature flag."""
    return bool(HOOK_FEATURES.get(feature_name, False))


def display_path(path: str) -> str:
    """Render an absolute path with $HOME for human-readable hook output."""
    return path.replace(HOME, "$HOME")
