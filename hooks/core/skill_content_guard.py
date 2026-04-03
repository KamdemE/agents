"""
Core: Skill Content Guard
Checks whether a skill's bundled files are actually surfaced in its SKILL.md.
Single source of truth for bundled-content coverage checks.
"""
from __future__ import annotations

from pathlib import Path

from core.settings import AGENTS_MD_DISPLAY, HOME

_AGENTS_MD = AGENTS_MD_DISPLAY
_STANDARD_DIRS = ("scripts", "references", "assets")
_SPECIAL_DIRS = {
    "k-skill-creator": ("agents", "eval-viewer"),
}
_IGNORED_FILES = {"__init__.py"}


def _display_path(path: Path) -> str:
    return str(path).replace(HOME, "$HOME")


def _coverage_dirs(skill_dir: Path) -> tuple[str, ...]:
    return _STANDARD_DIRS + _SPECIAL_DIRS.get(skill_dir.name, ())


def _is_file_mentioned(skill_text: str, rel_path: str, file_name: str) -> bool:
    return rel_path in skill_text or f"`{rel_path}`" in skill_text or f"`{file_name}`" in skill_text


def validate_skill_content(skill_path: str) -> list[str]:
    """Validate that bundled top-level files are surfaced in KπX-owned SKILL.md files."""
    path = Path(skill_path)
    skill_dir = path.parent
    if not skill_dir.name.startswith("k-"):
        return []

    try:
        skill_text = path.read_text(encoding="utf-8")
    except OSError as exc:
        return [f"{_display_path(path)}: unable to read SKILL.md for content coverage check: {exc}"]

    errors: list[str] = []
    for directory_name in _coverage_dirs(skill_dir):
        directory = skill_dir / directory_name
        if not directory.is_dir():
            continue
        for file_path in sorted(child for child in directory.iterdir() if child.is_file()):
            if file_path.name in _IGNORED_FILES:
                continue
            rel_path = str(file_path.relative_to(skill_dir))
            if not _is_file_mentioned(skill_text, rel_path, file_path.name):
                errors.append(
                    f"{_display_path(path)}: bundled file `{rel_path}` is not mentioned in SKILL.md "
                    f"(see {_AGENTS_MD} → '### Provenance & Quality')."
                )
    return errors


def build_skill_content_violation_report(skill_paths: list[str]) -> str:
    """Return a human-readable report for bundled-content coverage issues."""
    relevant = [Path(path) for path in skill_paths if path.endswith("/SKILL.md") or path.endswith("\\SKILL.md")]
    findings: list[str] = []
    for skill_path in relevant:
        try:
            findings.extend(validate_skill_content(str(skill_path)))
        except Exception as exc:
            findings.append(f"{_display_path(skill_path)}: content coverage check failed unexpectedly: {exc}")

    if not findings:
        return ""

    lines = ["SKILL CONTENT COVERAGE VIOLATIONS:"]
    lines.extend(f"  - {item}" for item in findings)
    lines.append(f"  Resolve per {_AGENTS_MD} → '### Provenance & Quality'.")
    return "\n".join(lines)
