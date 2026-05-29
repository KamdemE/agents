#!/usr/bin/env python3
"""
Hooks Audit
Single entry point to validate KπX hook wiring, KπX skill structure/content,
and runtime config references across supported agent CLIs.
"""
from __future__ import annotations

import ast
import importlib.util
import json
import os
import re
import subprocess
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "hooks"))

from core.settings import AGENTS_DIR, HOME, SKILLS_DIR
from core.skill_content_guard import validate_skill_content
from core.skill_structure_guard import validate_skill_structure

HOOKS_DIR = ROOT / "hooks"
GEMINI_SETTINGS = Path(HOME) / ".gemini/settings.json"
CLAUDE_SETTINGS = Path(HOME) / ".claude/settings.json"
CODEX_CONFIG = Path(HOME) / ".codex/config.toml"
CODEX_HOOKS = Path(HOME) / ".codex/hooks.json"


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
        "next unless txt.start_with?(\"---\\n\"); "
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


def _extract_python_command_path(command: str) -> str | None:
    match = re.search(r"python3\s+([^\s]+\.py)", command)
    if not match:
        return None
    return os.path.expandvars(match.group(1))


def _check_json_hook_commands(config_path: Path, event_map: dict) -> list[str]:
    findings: list[str] = []
    for event_name, groups in event_map.items():
        if not isinstance(groups, list):
            findings.append(f"{_display(config_path)}: event `{event_name}` must be a list.")
            continue
        for group in groups:
            for hook in group.get("hooks", []):
                command = hook.get("command", "")
                script_path = _extract_python_command_path(command)
                if script_path and not Path(script_path).exists():
                    findings.append(
                        f"{_display(config_path)}: hook `{event_name}` references missing script `{script_path}`."
                    )
    return findings


def _check_gemini() -> list[str]:
    findings: list[str] = []
    if not GEMINI_SETTINGS.exists():
        return findings
    data = json.loads(GEMINI_SETTINGS.read_text(encoding="utf-8"))
    findings.extend(_check_json_hook_commands(GEMINI_SETTINGS, data.get("hooks", {})))
    for expected in ("SessionStart", "BeforeAgent", "AfterAgent", "BeforeTool", "SessionEnd"):
        if expected not in data.get("hooks", {}):
            findings.append(f"{_display(GEMINI_SETTINGS)}: missing expected Gemini hook `{expected}`.")
    return findings


def _check_claude() -> list[str]:
    findings: list[str] = []
    if not CLAUDE_SETTINGS.exists():
        return findings
    data = json.loads(CLAUDE_SETTINGS.read_text(encoding="utf-8"))
    findings.extend(_check_json_hook_commands(CLAUDE_SETTINGS, data.get("hooks", {})))
    for expected in ("SessionStart", "UserPromptSubmit", "PreToolUse", "Stop", "SessionEnd"):
        if expected not in data.get("hooks", {}):
            findings.append(f"{_display(CLAUDE_SETTINGS)}: missing expected Claude hook `{expected}`.")
    return findings


def _check_codex() -> list[str]:
    findings: list[str] = []
    if not CODEX_CONFIG.exists():
        findings.append(f"{_display(CODEX_CONFIG)}: missing Codex config file.")
        return findings
    config = tomllib.loads(CODEX_CONFIG.read_text(encoding="utf-8"))
    if not config.get("features", {}).get("codex_hooks", False):
        findings.append(f"{_display(CODEX_CONFIG)}: `features.codex_hooks` must be enabled.")
    if not CODEX_HOOKS.exists():
        findings.append(f"{_display(CODEX_HOOKS)}: missing deployed Codex hooks file.")
        return findings
    data = json.loads(CODEX_HOOKS.read_text(encoding="utf-8"))
    findings.extend(_check_json_hook_commands(CODEX_HOOKS, data.get("hooks", {})))
    for expected in ("SessionStart", "UserPromptSubmit", "Stop"):
        if expected not in data.get("hooks", {}):
            findings.append(f"{_display(CODEX_HOOKS)}: missing expected Codex hook `{expected}`.")
    return findings


def _collect_python_paths() -> list[Path]:
    paths = [HOOKS_DIR / "audit.py"]
    paths.extend(sorted(HOOKS_DIR.glob("core/*.py")))
    paths.extend(sorted(HOOKS_DIR.glob("gemini/*.py")))
    paths.extend(sorted(HOOKS_DIR.glob("codex/*.py")))
    paths.extend(sorted(HOOKS_DIR.glob("claude/*.py")))
    return paths


def _load_module(path: Path, module_name: str):
    spec = importlib.util.spec_from_file_location(module_name, path)
    if spec is None or spec.loader is None:
        raise ImportError(f"unable to load module spec for {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _wrapper_smoke_tests() -> list[str]:
    findings: list[str] = []
    valid_response = (
        "## Commentaires:\n"
        "ok\n\n"
        "## Remarques:\n"
        "vide\n\n"
        "## TODOs\n"
        "| Task | Urgent | Important |\n"
        "| :--- | :--- | :--- |\n"
        "| Optimize bw-env | NO | YES |\n\n"
        "## Suggestions Proactives :\n"
        "1. one\n"
        "2. two\n"
        "3. three\n"
    )
    invalid_response = (
        "## Commentaires:\n"
        "ok\n\n"
        "## Remarques:\n"
        "- x\n\n"
        "## TODOs\n"
        "| Task | Urgent | Important |\n"
        "| :--- | :--- | :--- |\n"
        "| Optimize bw-env | NO | YES |\n\n"
        "## Suggestions Proactives :\n"
        "1. one\n"
        "2. two\n"
    )

    try:
        gemini_start = _load_module(HOOKS_DIR / "gemini/session_start.py", "audit_gemini_start")
        result = gemini_start.handle_session_start("GEMINI")
        if result and "hookSpecificOutput" not in result:
            findings.append(
                f"{_display(HOOKS_DIR / 'gemini/session_start.py')}: invalid startup payload shape in smoke test."
            )
    except Exception as exc:
        findings.append(f"{_display(HOOKS_DIR / 'gemini/session_start.py')}: smoke test failed: {exc}")

    try:
        gemini_before = _load_module(HOOKS_DIR / "gemini/before_agent.py", "audit_gemini_before")
        result = gemini_before.handle_before_agent("GEMINI", cwd=HOME)
        if result and "hookSpecificOutput" not in result:
            findings.append(
                f"{_display(HOOKS_DIR / 'gemini/before_agent.py')}: invalid prompt-injection payload shape in smoke test."
            )
    except Exception as exc:
        findings.append(f"{_display(HOOKS_DIR / 'gemini/before_agent.py')}: smoke test failed: {exc}")

    try:
        response_validator = _load_module(HOOKS_DIR / "core/response_validator.py", "audit_response_validator")
        result = response_validator.validate_response(valid_response)
        if not result.get("passed"):
            findings.append(
                f"{_display(HOOKS_DIR / 'core/response_validator.py')}: valid Markdown-heading response failed smoke test."
            )
    except Exception as exc:
        findings.append(f"{_display(HOOKS_DIR / 'core/response_validator.py')}: smoke test failed: {exc}")

    try:
        gemini_after = _load_module(HOOKS_DIR / "gemini/after_agent.py", "audit_gemini_after")
        result = gemini_after.handle_after_agent({"prompt_response": invalid_response})
        if result.get("decision") != "deny":
            findings.append(
                f"{_display(HOOKS_DIR / 'gemini/after_agent.py')}: malformed response was not denied."
            )
    except Exception as exc:
        findings.append(f"{_display(HOOKS_DIR / 'gemini/after_agent.py')}: smoke test failed: {exc}")

    try:
        claude_start = _load_module(HOOKS_DIR / "claude/session_start.py", "audit_claude_start")
        result = claude_start.handle_session_start("CLAUDE")
        if result:
            hook_output = result.get("hookSpecificOutput", {})
            if hook_output.get("hookEventName") != "SessionStart":
                findings.append(
                    f"{_display(HOOKS_DIR / 'claude/session_start.py')}: missing `hookEventName=SessionStart` in smoke test."
                )
    except Exception as exc:
        findings.append(f"{_display(HOOKS_DIR / 'claude/session_start.py')}: smoke test failed: {exc}")

    try:
        claude_prompt = _load_module(HOOKS_DIR / "claude/user_prompt_submit.py", "audit_claude_prompt")
        result = claude_prompt.handle_user_prompt_submit("CLAUDE", cwd=HOME)
        if result:
            hook_output = result.get("hookSpecificOutput", {})
            if hook_output.get("hookEventName") != "UserPromptSubmit":
                findings.append(
                    f"{_display(HOOKS_DIR / 'claude/user_prompt_submit.py')}: missing `hookEventName=UserPromptSubmit` in smoke test."
                )
    except Exception as exc:
        findings.append(f"{_display(HOOKS_DIR / 'claude/user_prompt_submit.py')}: smoke test failed: {exc}")

    try:
        codex_start = _load_module(HOOKS_DIR / "codex/session_start.py", "audit_codex_start")
        result = codex_start.handle_session_start("CODEX")
        hook_output = result.get("hookSpecificOutput", {})
        if hook_output.get("hookEventName") != "SessionStart":
            findings.append(
                f"{_display(HOOKS_DIR / 'codex/session_start.py')}: missing `hookEventName=SessionStart` in smoke test."
            )
        if "additionalContext" not in hook_output:
            findings.append(
                f"{_display(HOOKS_DIR / 'codex/session_start.py')}: missing `hookSpecificOutput.additionalContext` in smoke test."
            )
    except Exception as exc:
        findings.append(f"{_display(HOOKS_DIR / 'codex/session_start.py')}: smoke test failed: {exc}")

    try:
        codex_user = _load_module(HOOKS_DIR / "codex/user_prompt_submit.py", "audit_codex_prompt")
        result = codex_user.handle_user_prompt_submit("CODEX", cwd=HOME)
        hook_output = result.get("hookSpecificOutput", {})
        if hook_output.get("hookEventName") != "UserPromptSubmit":
            findings.append(
                f"{_display(HOOKS_DIR / 'codex/user_prompt_submit.py')}: missing `hookEventName=UserPromptSubmit` in smoke test."
            )
        if "additionalContext" not in hook_output:
            findings.append(
                f"{_display(HOOKS_DIR / 'codex/user_prompt_submit.py')}: missing `hookSpecificOutput.additionalContext` in smoke test."
            )
    except Exception as exc:
        findings.append(f"{_display(HOOKS_DIR / 'codex/user_prompt_submit.py')}: smoke test failed: {exc}")

    try:
        claude_stop = _load_module(HOOKS_DIR / "claude/stop.py", "audit_claude_stop")
        result = claude_stop.handle_stop(last_assistant_message=invalid_response, stop_hook_active=False)
        if result.get("decision") != "block":
            findings.append(
                f"{_display(HOOKS_DIR / 'claude/stop.py')}: malformed response was not blocked."
            )
    except Exception as exc:
        findings.append(f"{_display(HOOKS_DIR / 'claude/stop.py')}: smoke test failed: {exc}")

    return findings


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
            findings.append(f"{_display(rule_path)}: referenced in AGENTS.md but missing.")
            continue
        content = rule_path.read_text(encoding="utf-8").strip()
        if len(content) < 20:
            findings.append(f"{_display(rule_path)}: rule file is empty or too short.")
    return findings


def run_audit() -> list[str]:
    findings: list[str] = []
    findings.extend(_collect_skill_findings())
    findings.extend(_parse_python(_collect_python_paths()))
    findings.extend(_wrapper_smoke_tests())
    findings.extend(_check_rules())
    yaml_paths = [ROOT / "AGENTS.md"]
    yaml_paths.extend(sorted(Path(SKILLS_DIR).glob("**/SKILL.md")))
    findings.extend(_parse_yaml_frontmatters(yaml_paths))
    findings.extend(_check_gemini())
    # Claude and Codex runtime config checks are intentionally decoupled from
    # the shared `.agents` audit so local-install/runtime drift does not block
    # kernel commits. Their respective runtime skills remain the source of truth.
    return findings


def main() -> int:
    findings = run_audit()
    if findings:
        for item in findings:
            print(item)
        return 1
    print("ALL_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
