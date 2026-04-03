"""Core: structure validation for KπX-owned skill files."""
from __future__ import annotations

import os
import re

from core.settings import AGENTS_MD, display_path

_DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
_AGENT_TAG_RE = re.compile(r"^\[[A-Z0-9_-]+\]$")


def _read_text(path: str) -> str:
    with open(path, encoding="utf-8") as handle:
        return handle.read()


def extract_frontmatter(text: str) -> str | None:
    match = re.match(r"\A---\n(.*?)\n---\n", text, re.DOTALL)
    return match.group(1) if match else None


def extract_table_after_heading(text: str, heading: str) -> list[str]:
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


def parse_table_rows(table_lines: list[str]) -> list[list[str]]:
    rows: list[list[str]] = []
    for line in table_lines:
        stripped = line.strip()
        if not stripped.startswith("|") or not stripped.endswith("|"):
            continue
        rows.append([cell.strip() for cell in stripped.strip("|").split("|")])
    return rows


def _validate_changelog_rows(rows: list[list[str]], skill_path: str) -> list[str]:
    errors: list[str] = []
    path = display_path(skill_path)

    if len(rows) < 3:
        return [f"{path}: `## Changelog` must contain a header, separator, and body rows."]

    body = rows[2:]
    summary_indices = [idx for idx, row in enumerate(body) if row and row[0] == "[SUMMARY]"]
    if len(summary_indices) != 1:
        return [
            f"{path}: changelog must contain exactly one `[SUMMARY]` row "
            f"(see {AGENTS_MD} → '### Provenance & Quality')."
        ]

    summary_idx = summary_indices[0]
    if summary_idx != len(body) - 1:
        errors.append(f"{path}: `[SUMMARY]` must be the last changelog row.")

    explicit_rows = body[:summary_idx]
    if len(explicit_rows) > 2:
        errors.append(f"{path}: changelog may contain at most 2 explicit rows before `[SUMMARY]`.")

    previous_date: str | None = None
    for row in explicit_rows:
        if len(row) < 3:
            errors.append(f"{path}: changelog rows must have 3 columns: Date, Agent, Action.")
            continue

        date_value, agent_value = row[0], row[1]
        if not _DATE_RE.match(date_value):
            errors.append(f"{path}: invalid changelog date `{date_value}`; expected `YYYY-MM-DD`.")
        if not _AGENT_TAG_RE.match(agent_value):
            errors.append(f"{path}: invalid agent provenance `{agent_value}`; expected `[AGENT]`.")
        if previous_date is not None and date_value > previous_date:
            errors.append(f"{path}: changelog rows must be newest-first.")
        previous_date = date_value

    return errors


def validate_skill_structure_text(skill_path: str, text: str) -> list[str]:
    """Validate frontmatter and footer structure for one KπX-owned SKILL.md payload."""
    errors: list[str] = []
    skill_dir_name = os.path.basename(os.path.dirname(skill_path))
    if not skill_dir_name.startswith("k-"):
        return errors

    path = display_path(skill_path)
    frontmatter = extract_frontmatter(text)
    if frontmatter is None:
        return [f"{path}: missing YAML frontmatter header."]

    for required_key in ("name:", "description:", "metadata:"):
        if required_key not in frontmatter:
            errors.append(f"{path}: missing frontmatter field `{required_key[:-1]}`.")
    if "version:" not in frontmatter:
        errors.append(f"{path}: missing `metadata.version` in frontmatter.")

    body = re.sub(r"\A---\n.*?\n---\n", "", text, count=1, flags=re.DOTALL)
    h1_match = re.search(r"^#\s+.+$", body, re.MULTILINE)
    if not h1_match:
        errors.append(f"{path}: missing top-level H1 heading after frontmatter.")
    else:
        after_h1 = body[h1_match.end():]
        reminder_match = re.match(
            r"\n\n\*\*⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER "
            r"\(VERSION, ETC\.\) AND THE FOOTER \(CHANGELOG\)\.\*\*",
            after_h1,
        )
        if reminder_match is None:
            errors.append(f"{path}: missing mandatory edit reminder directly under the H1 heading.")

    changelog_table = extract_table_after_heading(text, "Changelog")
    if not changelog_table:
        errors.append(f"{path}: missing `## Changelog` footer table.")
    else:
        errors.extend(_validate_changelog_rows(parse_table_rows(changelog_table), skill_path))

    if skill_dir_name == "k-context":
        session_log_table = extract_table_after_heading(text, "Session Log")
        if not session_log_table:
            errors.append(f"{path}: `k-context` must contain a `## Session Log` table.")
        else:
            rows = parse_table_rows(session_log_table)
            body_rows = rows[2:] if len(rows) > 2 else []
            summary_count = sum(1 for row in body_rows if row and row[0] == "[SUMMARY]")
            explicit_rows = [row for row in body_rows if row and row[0] != "[SUMMARY]"]
            if summary_count != 1:
                errors.append(f"{path}: `k-context` session log must contain exactly one `[SUMMARY]` row.")
            if len(explicit_rows) > 10:
                errors.append(f"{path}: `k-context` session log may contain at most 10 explicit rows.")
            if body_rows and not (body_rows[-1] and body_rows[-1][0] == "[SUMMARY]"):
                errors.append(f"{path}: `k-context` session log must end with `[SUMMARY]`.")
            for row in explicit_rows:
                if len(row) < 3:
                    errors.append(f"{path}: malformed `k-context` session log row; expected 3 columns.")
                    continue
                if not _DATE_RE.match(row[0]):
                    errors.append(f"{path}: invalid `k-context` session log date `{row[0]}`.")
                if not _AGENT_TAG_RE.match(row[1]):
                    errors.append(f"{path}: invalid `k-context` session log provenance `{row[1]}`.")

    return errors


def validate_skill_structure(skill_path: str) -> list[str]:
    """Validate frontmatter and footer structure for one KπX-owned SKILL.md file."""
    return validate_skill_structure_text(skill_path, _read_text(skill_path))


def build_skill_structure_violation_report(skill_paths: list[str]) -> str:
    """Return a human-readable report for all invalid KπX skill structures."""
    relevant = [path for path in skill_paths if path.endswith("/SKILL.md") or path.endswith("\\SKILL.md")]
    findings: list[str] = []

    for skill_path in relevant:
        try:
            findings.extend(validate_skill_structure(skill_path))
        except Exception as exc:
            findings.append(f"{display_path(skill_path)}: structure check failed unexpectedly: {exc}")

    if not findings:
        return ""

    lines = ["SKILL STRUCTURE VIOLATIONS:"]
    lines.extend(f"  - {item}" for item in findings)
    lines.append(f"  Resolve per {AGENTS_MD} → '### Provenance & Quality'.")
    return "\n".join(lines)
