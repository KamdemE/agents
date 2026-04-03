"""
Core: Context Injector
Reads k-context + k-workspace SKILL.md and returns startup context with session date.
Wrappers decide where to inject this startup context in their own lifecycle.
"""
import datetime
import os

from core.settings import K_CONTEXT_PATH, K_WORKSPACE_PATH

_SKILL_PATHS = [K_CONTEXT_PATH, K_WORKSPACE_PATH]


def get_context_content() -> str:
    """Reads and concatenates k-context and k-workspace SKILL.md contents."""
    content = ""
    for path in _SKILL_PATHS:
        if os.path.exists(path):
            try:
                with open(path, "r") as f:
                    content += f"\n--- {os.path.basename(path)} ---\n"
                    content += f.read()
            except OSError:
                continue
    return content


def build_context_output(agent_name: str) -> dict:
    """Returns {'context': str, 'system_message': str} for wrappers."""
    context = get_context_content()
    now = datetime.datetime.now()
    date_line = f"Session date: {now.strftime('%Y-%m-%d')} ({now.strftime('%A')})"
    return {
        "context": f"{date_line}\n\nMANDATORY STARTUP CONTEXT:\n{context}",
        "system_message": (
            f"[HOOK] Startup context injected into {agent_name} "
            f"on {now.strftime('%Y-%m-%d')} at {now.strftime('%H:%M')}."
        ),
    }
