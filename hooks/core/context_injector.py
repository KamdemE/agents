"""Core: startup context injection from the configured startup skill list."""
import datetime
import os

from core.device_detector import (
    device_context_block,
    detect_device,
    infra_skill_path,
)
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

    # 3. Startup skills (k-context only)
    for path in get_startup_skill_paths():
        skill = _read_file(path)
        if skill:
            content += f"\n--- {os.path.basename(path)} ---\n{skill}\n"

    return content


def build_context_output(agent_name: str) -> dict:
    """Returns {'context': str, 'system_message': str} for wrappers."""
    if not is_hook_feature_enabled("startup_context"):
        return {"context": "", "system_message": ""}

    now = datetime.datetime.now()
    date_line = f"Session date: {now.strftime('%Y-%m-%d')} ({now.strftime('%A')})"
    parts = [date_line]

    # Device detection block (feature-flagged)
    if is_hook_feature_enabled("device_detection"):
        dev_block = device_context_block()
        if dev_block:
            parts.append(f"\n{dev_block}")
            # Also inject the full infra SKILL.md if detected
            _, skill_name, _ = detect_device()
            skill_path = infra_skill_path(skill_name)
            if skill_path:
                skill_content = _read_file(skill_path)
                if skill_content:
                    parts.append(
                        f"\n--- {os.path.basename(os.path.dirname(skill_path))}/SKILL.md ---"
                        f"\n{skill_content}"
                    )

    # Startup skills
    context = get_context_content()
    parts.append(f"\nMANDATORY STARTUP CONTEXT:\n{context}")

    return {
        "context": "\n".join(parts),
        "system_message": (
            f"[HOOK] Startup context injected into {agent_name} "
            f"on {now.strftime('%Y-%m-%d')} at {now.strftime('%H:%M')}."
        ),
    }
