"""
Core: Skill Structure Guard
Validates KπX skill files against the structural rules defined in AGENTS.md.
Single source of truth for reusable skill-structure checks used by other hooks.
"""
from __future__ import annotations

import os
import re

from core.settings import AGENTS_MD_DISPLAY, HOME

_AGENTS_MD = AGENTS_MD_DISPLAY
_DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
_AGENT_TAG_RE = re.compile(r"^\[[A-Z0-9_-]+\]$")


def _display_path(path: str) -> str:
    return path.replace(HOME, "$HOME")


def _read_text(path: str) -> str:
    with open(path, encoding="utf-8") as handle:
        return handle.read()


def _extract_frontmatter(text: str) -> str | None:
    match = re.match(r"\A---\n(.*?)\n---\n", text, re.DOTALL)
    return match.group(1) if match else None


def _extract_table_after_heading(text: str, heading: str) -> list[str]:
    pattern = rf"^## {re.escape(heading)}\n"
    match = re.search(pattern, text, re.MULTILINE)
    if not match:
        return []

    lines = text[match.end():].splitlines()
    table_lines: list[str] = []
    for line in lines:
        if not line.strip():
            if table_lines:
                break
            continue
        if line.startswith("|"):
            table_lines.append(line)
            continue
        if table_lines:
            break
    return table_lines


def _parse_table_rows(table_lines: list[str]) -> list[list[str]]:
    rows: list[list[str]] = []
    for line in table_lines:
        stripped = line.strip()
        if not stripped.startswith("|") or not stripped.endswith("|"):
            continue
        cells = [cell.strip() for cell in stripped.strip("|").split("|")]
        rows.append(cells)
    return rows


def _validate_changelog_rows(rows: list[list[str]], skill_path: str) -> list[str]:
    errors: list[str] = []

    if len(rows) < 3:
        return [f"{_display_path(skill_path)}: `## Changelog` must contain a header, separator, and body rows."]

    body = rows[2:]
    summary_indices = [idx for idx, row in enumerate(body) if row and row[0] == "[SUMMARY]"]
    if len(summary_indices) != 1:
        errors.append(
            f"{_display_path(skill_path)}: changelog must contain exactly one `[SUMMARY]` row "
            f"(see {_AGENTS_MD} → '### Provenance & Quality')."
        )
        return errors

    summary_idx = summary_indices[0]
    if summary_idx != len(body) - 1:
        errors.append(f"{_display_path(skill_path)}: `[SUMMARY]` must be the last changelog row.")

    explicit_rows = body[:summary_idx]
    if len(explicit_rows) > 2:
        errors.append(f"{_display_path(skill_path)}: changelog may contain at most 2 explicit rows before `[SUMMARY]`.")

    previous_date: str | None = None
    for row in explicit_rows:
        if len(row) < 3:
            errors.append(f"{_display_path(skill_path)}: changelog rows must have 3 columns: Date, Agent, Action.")
            continue
        date_value, agent_value = row[0], row[1]
        if not _DATE_RE.match(date_value):
            errors.append(f"{_display_path(skill_path)}: invalid changelog date `{date_value}`; expected `YYYY-MM-DD`.")
        if not _AGENT_TAG_RE.match(agent_value):
            errors.append(
                f"{_display_path(skill_path)}: invalid agent provenance `{agent_value}`; expected `[AGENT]`."
            )
        if previous_date is not None and date_value > previous_date:
            errors.append(f"{_display_path(skill_path)}: changelog rows must be newest-first.")
        previous_date = date_value

    return errors


def validate_skill_structure(skill_path: str) -> list[str]:
    """Validate frontmatter and footer structure for one KπX-owned SKILL.md file."""
    errors: list[str] = []
    skill_dir_name = os.path.basename(os.path.dirname(skill_path))
    if not skill_dir_name.startswith("k-"):
        return errors

    text = _read_text(skill_path)
    display = _display_path(skill_path)

    frontmatter = _extract_frontmatter(text)
    if frontmatter is None:
        return [f"{display}: missing YAML frontmatter header."]

    for required_key in ("name:", "description:", "metadata:"):
        if required_key not in frontmatter:
            errors.append(f"{display}: missing frontmatter field `{required_key[:-1]}`.")
    if 'version:' not in frontmatter:
        errors.append(f"{display}: missing `metadata.version` in frontmatter.")

    body = re.sub(r"\A---\n.*?\n---\n", "", text, count=1, flags=re.DOTALL)
    h1_match = re.search(r"^#\s+.+$", body, re.MULTILINE)
    if not h1_match:
        errors.append(f"{display}: missing top-level H1 heading after frontmatter.")
    else:
        after_h1 = body[h1_match.end():]
        reminder_match = re.match(r"\n\n\*\*⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER \(VERSION, ETC\.\) AND THE FOOTER \(CHANGELOG\)\.\*\*", after_h1)
        if reminder_match is None:
            errors.append(
                f"{display}: missing mandatory edit reminder directly under the H1 heading."
            )

    changelog_table = _extract_table_after_heading(text, "Changelog")
    if not changelog_table:
        errors.append(f"{display}: missing `## Changelog` footer table.")
    else:
        errors.extend(_validate_changelog_rows(_parse_table_rows(changelog_table), skill_path))

    if skill_dir_name == "k-context":
        session_log_table = _extract_table_after_heading(text, "Session Log")
        if not session_log_table:
            errors.append(f"{display}: `k-context` must contain a `## Session Log` table.")
        else:
            rows = _parse_table_rows(session_log_table)
            body = rows[2:] if len(rows) > 2 else []
            summary_count = sum(1 for row in body if row and row[0] == "[SUMMARY]")
            explicit_rows = [row for row in body if row and row[0] != "[SUMMARY]"]
            if summary_count != 1:
                errors.append(f"{display}: `k-context` session log must contain exactly one `[SUMMARY]` row.")
            if len(explicit_rows) > 10:
                errors.append(f"{display}: `k-context` session log may contain at most 10 explicit rows.")
            if body and not (body[-1] and body[-1][0] == "[SUMMARY]"):
                errors.append(f"{display}: `k-context` session log must end with `[SUMMARY]`.")
            for row in explicit_rows:
                if len(row) < 3:
                    errors.append(f"{display}: malformed `k-context` session log row; expected 3 columns.")
                    continue
                if not _DATE_RE.match(row[0]):
                    errors.append(f"{display}: invalid `k-context` session log date `{row[0]}`.")
                if not _AGENT_TAG_RE.match(row[1]):
                    errors.append(f"{display}: invalid `k-context` session log provenance `{row[1]}`.")

    return errors


def build_skill_structure_violation_report(skill_paths: list[str]) -> str:
    """Return a human-readable report for all invalid KπX skill structures."""
    relevant = [path for path in skill_paths if path.endswith("/SKILL.md") or path.endswith("\\SKILL.md")]
    findings: list[str] = []

    for skill_path in relevant:
        try:
            findings.extend(validate_skill_structure(skill_path))
        except Exception as exc:
            findings.append(f"{_display_path(skill_path)}: structure check failed unexpectedly: {exc}")

    if not findings:
        return ""

    lines = ["SKILL STRUCTURE VIOLATIONS:"]
    lines.extend(f"  - {item}" for item in findings)
    lines.append(f"  Resolve per {_AGENTS_MD} → '### Provenance & Quality'.")
    return "\n".join(lines)
