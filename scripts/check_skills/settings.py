"""Core: shared paths and display helpers for offline skill validators."""

from __future__ import annotations

import os

HOME = os.environ["HOME"]

# ==============================================================================
# PATHS
# ==============================================================================

AGENTS_DIR = os.path.join(HOME, ".agents")
SKILLS_DIR = os.path.join(AGENTS_DIR, "skills")
AGENTS_MD = "$HOME/.agents/AGENTS.md"


def display_path(path: str) -> str:
    """Render an absolute path with $HOME for human-readable hook output."""
    return path.replace(HOME, "$HOME")
