"""
Core: Prompt Injector
Injects lightweight dynamic context before each LLM call.
Wrappers decide where to inject this per-turn context in their own lifecycle.
"""
import datetime
import getpass
import os
import socket

from core.settings import is_hook_feature_enabled


def get_dynamic_context(cwd: str | None = None) -> str:
    """Returns a small XML block with date, time, machine, user, and cwd."""
    if not is_hook_feature_enabled("dynamic_context"):
        return ""
    now = datetime.datetime.now()
    current_cwd = cwd or os.getcwd()
    user = getpass.getuser()
    machine = socket.gethostname()
    return (
        "<dynamic-context>\n"
        f"Date: {now.strftime('%Y-%m-%d')} ({now.strftime('%A')})\n"
        f"Time: {now.strftime('%H:%M')}\n"
        f"Prompt: \u2500[{user}@{machine}]\n"
        f"Current directory: {current_cwd}\n"
        "</dynamic-context>"
    )
