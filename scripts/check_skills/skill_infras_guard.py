"""Core: kshrc-link wiring guard for -owned skills.

Verifies that every skill shipping an `assets/kshrc` has a matching entry
registered in assets/links.jsonc (by TARGET path) — otherwise `make
set-links` would never deploy it and the shell hub would silently diverge.

Extracted from check_skills.py (2026-08-15) so check_skills.py stays a thin
aggregator of the other *.py guard modules. Shared JSONC helpers come from
libs/jsonc_lib.py (the Python twin of libs/jsonc_lib.sh).
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
# make the shared libs importable (libs/jsonc/jsonc_lib.py)
sys.path.insert(0, str(ROOT / "libs"))
sys.path.insert(0, str(ROOT / "libs" / "jsonc"))
sys.path.insert(0, str(ROOT / "scripts" / "check_skills"))

from jsonc_lib import load_jsonc_obj
from settings import display_path


def check_infra_skills() -> list[str]:
    """Return findings for kshrc-link wiring issues (empty list = OK)."""
    findings: list[str] = []
    links_file = ROOT / "assets" / "links.jsonc"
    if not links_file.exists():
        findings.append(f"{display_path(str(links_file))}: missing links.jsonc")
        return findings

    links = load_jsonc_obj(links_file).get("links", {})

    skills_dir = ROOT / "skills"
    if not skills_dir.is_dir():
        return findings
    for skill_dir in sorted(skills_dir.iterdir()):
        if not skill_dir.is_dir():
            continue
        kshrc = skill_dir / "assets" / "kshrc"
        if not kshrc.exists():
            continue
        expected_target = f"$HOME/.agents/skills/{skill_dir.name}/assets/kshrc"
        has_kshrc = any(
            isinstance(entry, dict) and entry.get("target") == expected_target
            for entry in links.values()
        )
        if not has_kshrc:
            findings.append(
                f"assets/links.jsonc: skill '{skill_dir.name}' ships "
                f"assets/kshrc but no link targets {expected_target}."
            )
    return findings
