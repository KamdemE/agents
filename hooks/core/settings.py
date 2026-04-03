"""
Core: Settings
Shared constants for all hook modules. Single source of truth — never duplicate here.
$HOME is resolved once at import time; all paths are absolute.
Import with: from core.settings import AGENTS_DIR, K_CONTEXT_PATH, AGENTS_MD, ...
"""
import os

HOME = os.environ["HOME"]

AGENTS_DIR = os.path.join(HOME, ".agents")
AGENTS_MD = os.path.join(AGENTS_DIR, "AGENTS.md")
AGENTS_MD_DISPLAY = "$HOME/.agents/AGENTS.md"
SKILLS_DIR = os.path.join(HOME, ".agents/skills")
K_CONTEXT_PATH = os.path.join(HOME, ".agents/skills/k-context/SKILL.md")
K_WORKSPACE_PATH = os.path.join(HOME, ".agents/skills/k-workspace/SKILL.md")

AGENTS_STYLE_REF = f"(see {AGENTS_MD_DISPLAY} → '### Style')"
