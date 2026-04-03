"""Core: startup context injection from the configured startup skill list."""
import datetime
import os

from core.settings import get_startup_skill_paths, is_hook_feature_enabled


def get_context_content() -> str:
    """Read and concatenate the configured startup skills."""
    content = ""
    for path in get_startup_skill_paths():
        if os.path.exists(path):
            try:
                with open(path, "r", encoding="utf-8") as f:
                    content += f"\n--- {os.path.basename(path)} ---\n"
                    content += f.read()
            except OSError:
                continue
    return content


def build_context_output(agent_name: str) -> dict:
    """Returns {'context': str, 'system_message': str} for wrappers."""
    if not is_hook_feature_enabled("startup_context"):
        return {"context": "", "system_message": ""}
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
