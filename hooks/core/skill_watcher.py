"""
Core: Skill Watcher
Per-turn governance reminder.
It does not restate AGENTS rules in detail; it only points the agent back to
AGENTS.md as the single source of truth.
"""
from __future__ import annotations

from core.settings import AGENTS_MD, is_hook_feature_enabled


def build_governance_reminder() -> str:
    """Return the compact pre-turn governance reminder block."""
    if not is_hook_feature_enabled("governance_reminder"):
        return ""
    lines = "\n".join(
        (
            f"- If {AGENTS_MD} is not already in working context, read it now.",
            f"- Use {AGENTS_MD} as the single source of truth for response rules and .agents maintenance.",
            (
                "- If your work changes $HOME/.agents/, update "
                "$HOME/.agents/skills/k-context/SKILL.md and any affected k-* skills per AGENTS.md."
            ),
        )
    )
    return (
        "<agent-governance-reminder>\n"
        "AGENTS CHECK:\n"
        f"{lines}\n"
        "</agent-governance-reminder>"
    )
