"""Core: path guard for file edits targeting $HOME/.agents/."""

import os
import re

from core.settings import AGENTS_DIR, AGENTS_MD, is_hook_feature_enabled

# Matches literal home-directory paths or a bare ~ not preceded by $
_PATTERN_HOME = re.compile(r"/home/[^/\s\"'`]+|(?<!\$)\b~\b")

_AGENTS_DIR_NORM = os.path.normpath(AGENTS_DIR)


def _is_agents_file(file_path: str) -> bool:
    """Returns True if file_path is within $HOME/.agents/."""
    norm = os.path.normpath(os.path.abspath(file_path))
    return norm.startswith(_AGENTS_DIR_NORM + os.sep) or norm == _AGENTS_DIR_NORM


def check_path_generalization(content: str):
    """Returns an error string if a hardcoded home path is found, else None."""
    if not is_hook_feature_enabled("path_generalization"):
        return None
    if _PATTERN_HOME.search(content):
        return (
            "Literal home-directory path or bare `~` detected in `.agents/` content. "
            f"Use `$HOME` and `$USER` per {AGENTS_MD} → `### Style`."
        )
    return None


_DEFAULT_CHECKS = [check_path_generalization]


def guard_content(
    content: str, file_path: str | None = None, checks: list | None = None
) -> list:
    """
    Runs checks against content. Returns list of error strings (empty = all clear).
    Scoping rule: if file_path is provided and is NOT within $HOME/.agents/, returns [].
    """
    if file_path and not _is_agents_file(file_path):
        return []  # path rule applies ONLY to .agents/ files
    active = checks if checks is not None else _DEFAULT_CHECKS
    if not active:
        return []
    return [e for c in active if (e := c(content)) is not None]
