#!/usr/bin/env python3
"""
Hooks Audit
Single entry point to validate KπX hook wiring, KπX skill structure/content,
and runtime config references across supported agent CLIs.
"""

from __future__ import annotations

import ast
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
# make libs/jsonc/jsonc_lib.py + sibling guards importable
sys.path.insert(0, str(ROOT / "libs"))
sys.path.insert(0, str(ROOT / "libs" / "jsonc"))
sys.path.insert(0, str(Path(__file__).resolve().parent))

from settings import HOME, SKILLS_DIR
from skill_content_guard import validate_skill_content
from skill_infras_guard import check_infra_skills
from skill_structure_guard import validate_skill_structure


def _display(path: Path | str) -> str:
    return str(path).replace(HOME, "$HOME")


def _collect_skill_findings() -> list[str]:
    findings: list[str] = []
    for skill_path in sorted(Path(SKILLS_DIR).glob("**/SKILL.md")):
        findings.extend(validate_skill_structure(str(skill_path)))
        findings.extend(validate_skill_content(str(skill_path)))
    return findings


def _parse_python(paths: list[Path]) -> list[str]:
    findings: list[str] = []
    for path in paths:
        try:
            ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
        except SyntaxError as exc:
            findings.append(f"{_display(path)}: python syntax error: {exc}")
    return findings


def _parse_yaml_frontmatters(paths: list[Path]) -> list[str]:
    findings: list[str] = []
    ruby = (
        "require 'yaml'; "
        "ARGV.each do |p| "
        "txt = File.read(p); "
        'next unless txt.start_with?("---\\n"); '
        "m = txt.match(/\\A---\\n(.*?)\\n---\\n/m); "
        "YAML.safe_load(m[1]) if m; "
        "end"
    )
    try:
        subprocess.run(
            ["ruby", "-e", ruby, *[str(path) for path in paths]],
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as exc:
        findings.append(exc.stderr.strip() or "ruby YAML validation failed")
    return findings


def _collect_python_paths() -> list[Path]:
    audit_dir = ROOT / "scripts" / "audit"
    return sorted(audit_dir.glob("*.py"))


def _check_rules() -> list[str]:
    findings: list[str] = []
    agents_md = ROOT / "AGENTS.md"
    if not agents_md.exists():
        findings.append(f"{_display(agents_md)}: missing AGENTS.md")
        return findings
    text = agents_md.read_text(encoding="utf-8")
    rule_refs = re.findall(r"`rules/([a-z0-9-]+\.md)`", text)
    for ref in sorted(set(rule_refs)):
        rule_path = ROOT / "rules" / ref
        if not rule_path.exists():
            findings.append(
                f"{_display(rule_path)}: referenced in AGENTS.md but missing."
            )
            continue
        content = rule_path.read_text(encoding="utf-8").strip()
        if len(content) < 20:
            findings.append(f"{_display(rule_path)}: rule file is empty or too short.")
    return findings


def run_audit() -> list[str]:
    findings: list[str] = []
    print("  ├─ 🧩 1/4 Skill structure and bundled-content coverage")
    findings.extend(_collect_skill_findings())
    print("  ├─ 🐍 2/4 Python audit-source syntax")
    findings.extend(_parse_python(_collect_python_paths()))
    print("  ├─ 📜 3/4 Root rule references")
    findings.extend(_check_rules())
    print("  ├─ 🏗️ 4/4 Infrastructure wiring and YAML frontmatter")
    findings.extend(check_infra_skills())
    yaml_paths = [ROOT / "AGENTS.md"]
    yaml_paths.extend(sorted(Path(SKILLS_DIR).glob("**/SKILL.md")))
    findings.extend(_parse_yaml_frontmatters(yaml_paths))
    return findings


def main() -> int:
    findings = run_audit()
    if findings:
        for item in findings:
            print(item)
        return 1
    print("  └─ 📊 Summary: all skill-audit subchecks passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
