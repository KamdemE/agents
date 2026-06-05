"""Core: startup context injection from the configured startup skill list."""
import datetime
import os

from core.settings import (
    AGENTS_MD,
    SOUL_MD,
    USER_MD,
    get_startup_skill_paths,
    is_hook_feature_enabled,
    display_path,
)


def _read_file(path: str) -> str:
    """Read one file, return empty string on failure."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()
    except OSError:
        return ""


def get_context_content() -> str:
    """Read and concatenate: SOUL.md → USER.md → startup skills."""
    content = ""

    # 1. SOUL.md — personality/identity (if exists)
    soul = _read_file(SOUL_MD)
    if soul:
        content += f"\n--- SOUL.md ---\n{soul}\n"

    # 2. USER.md — operator profile (if exists)
    user = _read_file(USER_MD)
    if user:
        content += f"\n--- USER.md ---\n{user}\n"

    # 3. Startup skills (k-context, k-workspace, k-agents...)
    for path in get_startup_skill_paths():
        skill = _read_file(path)
        if skill:
            content += f"\n--- {os.path.basename(path)} ---\n{skill}\n"

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
