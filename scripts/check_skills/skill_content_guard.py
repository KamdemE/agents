"""Core: bundled-content coverage checks for KπX-owned skills."""

from __future__ import annotations

import json
from pathlib import Path

from settings import AGENTS_MD, display_path

_STANDARD_DIRS = ("scripts", "references", "assets")
_SPECIAL_DIRS = {
    "k-skill-creator": ("agents", "eval-viewer"),
}
_IGNORED_FILES = {"__init__.py"}


def _coverage_dirs(skill_dir: Path) -> tuple[str, ...]:
    return _STANDARD_DIRS + _SPECIAL_DIRS.get(skill_dir.name, ())


def _is_file_mentioned(skill_text: str, rel_path: str, file_name: str) -> bool:
    return (
        rel_path in skill_text
        or f"`{rel_path}`" in skill_text
        or f"`{file_name}`" in skill_text
    )


def validate_skill_content_text(skill_path: str, skill_text: str) -> list[str]:
    """Validate that bundled top-level files are surfaced in one KπX-owned skill payload."""
    path = Path(skill_path)
    skill_dir = path.parent
    if not skill_dir.name.startswith("k-"):
        return []

    errors: list[str] = []
    for directory_name in _coverage_dirs(skill_dir):
        directory = skill_dir / directory_name
        if not directory.is_dir():
            continue
        for file_path in sorted(
            child for child in directory.iterdir() if child.is_file()
        ):
            if file_path.name in _IGNORED_FILES:
                continue
            # references/log.md is the k-context-exclusive rotation archive
            # (rules/k-context-hygiene.md) — every other skill's own log.md
            # is an incidental historical artifact, not a mechanism KπX wants
            # to force a mention of. Only k-context is required to surface it.
            if (
                directory_name == "references"
                and file_path.name == "log.md"
                and skill_dir.name != "k-context"
            ):
                continue
            rel_path = str(file_path.relative_to(skill_dir))
            if not _is_file_mentioned(skill_text, rel_path, file_path.name):
                errors.append(
                    f"{display_path(str(path))}: bundled file `{rel_path}` is not mentioned in SKILL.md "
                    f"(see {AGENTS_MD} → '### Provenance & Quality')."
                )
    return errors


def validate_skill_content(skill_path: str) -> list[str]:
    """Validate that bundled top-level files are surfaced in KπX-owned SKILL.md files."""
    path = Path(skill_path)
    try:
        skill_text = path.read_text(encoding="utf-8")
    except OSError as exc:
        return [
            f"{display_path(str(path))}: unable to read SKILL.md for content coverage check: {exc}"
        ]
    return validate_skill_content_text(skill_path, skill_text)


def build_skill_content_violation_report(skill_paths: list[str]) -> str:
    """Return a human-readable report for bundled-content coverage issues."""
    relevant = [
        Path(path)
        for path in skill_paths
        if path.endswith("/SKILL.md") or path.endswith("\\SKILL.md")
    ]
    findings: list[str] = []
    for skill_path in relevant:
        try:
            findings.extend(validate_skill_content(str(skill_path)))
        except (json.JSONDecodeError, KeyError, TypeError, ValueError, OSError) as exc:
            findings.append(
                f"{display_path(str(skill_path))}: content coverage check failed unexpectedly: {exc}"
            )

    if not findings:
        return ""

    lines = ["SKILL CONTENT COVERAGE VIOLATIONS:"]
    lines.extend(f"  - {item}" for item in findings)
    lines.append(f"  Resolve per {AGENTS_MD} → '### Provenance & Quality'.")
    return "\n".join(lines)
