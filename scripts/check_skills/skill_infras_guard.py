"""Core: infra-skill wiring guard for KπX-owned skills.

Verifies that every infra skill (from assets/infras_skills.jsonc) has:
  - the 'MANDATORY — read `k-infras`' setup note in its SKILL.md
  - a 'kshrc-*' symlink entry registered in assets/links.jsonc (by TARGET path)

Extracted from check_skills.py (2026-08-15) so check_skills.py stays a thin
aggregator of the other *.py guard modules. Shared JSONC helpers come from
libs/jsonc_lib.py (the Python twin of libs/jsonc_lib.sh).
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
# make the shared libs importable (libs/jsonc_lib.py)
sys.path.insert(0, str(ROOT / "libs"))
sys.path.insert(0, str(ROOT / "scripts" / "check_skills"))

from jsonc_lib import load_jsonc_obj
from settings import display_path

REQUIRED_NOTE = (
    "> **MANDATORY — read `k-infras` → New Infra Setup Checklist FIRST** to "
    "understand the setup rule: everything lives in `.agents/` (single source of "
    "truth); `$HOME`/`/root` items are symlinks (`ln -sf`). Each infra has its own "
    "`assets/kshrc` (copied from `k-zsh/assets/kshrc.base` and customized)."
)


def check_infra_skills() -> list[str]:
    """Return findings for infra-skill wiring issues (empty list = OK)."""
    findings: list[str] = []
    infra_file = ROOT / "assets" / "infras_skills.jsonc"
    links_file = ROOT / "assets" / "links.jsonc"
    if not infra_file.exists():
        findings.append(f"{display_path(str(infra_file))}: missing infras_skills.jsonc")
        return findings

    infra_map = load_jsonc_obj(infra_file)
    if not infra_map:
        findings.append(f"{display_path(str(infra_file))}: empty infras_skills.jsonc")
        return findings

    links = load_jsonc_obj(links_file).get("links", {})

    for infra, skill in infra_map.items():
        skill_md = ROOT / "skills" / str(skill) / "SKILL.md"
        if not skill_md.exists():
            findings.append(
                f"{display_path(str(skill_md))}: infra '{infra}' maps to skill "
                f"'{skill}' but SKILL.md missing."
            )
            continue
        text = skill_md.read_text(encoding="utf-8")
        if REQUIRED_NOTE not in text:
            findings.append(
                f"{display_path(str(skill_md))}: infra skill '{skill}' missing "
                f"'{REQUIRED_NOTE}' setup note."
            )
        # Verify a kshrc-* link is registered for this infra skill by TARGET path
        expected_target = f"$HOME/.agents/skills/{skill}/assets/kshrc"
        has_kshrc = any(
            isinstance(entry, dict) and entry.get("target") == expected_target
            for entry in links.values()
        )
        if not has_kshrc:
            findings.append(
                f"assets/links.jsonc: infra '{infra}' skill '{skill}' missing a "
                f"kshrc-* link targeting {expected_target}."
            )
    return findings
