"""env_lib.py — shared .env helpers for .agents Python scripts.

Central place for everything common to .agents Python scripts that deal with
.env / .env.example files (secrets — KπX NEVER prints or returns values, only key
names + whether a value is present/empty). This mirrors libs/env/env_lib.sh
EXACTLY, language apart — see libs/AGENTS.md for the "keep the 3 twins in
sync" rule. Python callers import this module instead of re-implementing.

Provided here (functions expose key NAMES and presence, never values):
  env_keys(path)              -> list[str] : non-commented KEY names (sorted, unique)
   env_has_value(path, key)    -> bool      : True if <key> has a non-empty value
   env_has_exact_empty_value(path, key) -> bool : True if <key>'s final value is exactly empty
  env_validate_format(path)   -> bool      : True if every line is blank/comment/KEY=...
  env_keys_not_in_example(env, example) -> list[str] : KEYs present in env but
                                           absent from example (names only)
   env_is_missing_key(env, example)      -> bool : True if some KEY of env has
                                            no (even empty) counterpart in example
   env_load(path)                         -> bool : load strict KEY=value data safely

SECURITY: these helpers ONLY ever return KEY NAMES or present/empty booleans.
They NEVER return VALUES. They may inspect values internally only to determine
presence or load a value into the caller environment.

Caller convention (mirroring libs/jsonc/jsonc_lib.sh):
  - scripts/*/ import this module via sys.path insertion of $HOME/.agents/libs.
"""

from __future__ import annotations

import os
import re
from pathlib import Path
from typing import Iterable

_KEY_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$")
_KEY_NAME_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def _non_comment_lines(text: str) -> Iterable[str]:
    """Yield raw lines that are neither blank nor full-line comments."""
    for line in text.splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        yield line


def env_keys(path: str | Path) -> list[str]:
    """Return the sorted, unique, non-commented KEY names of an env file."""
    try:
        text = Path(path).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return []
    keys: set[str] = set()
    for line in _non_comment_lines(text):
        m = _KEY_RE.match(line)
        if m:
            keys.add(m.group(1))
    return sorted(keys)


def env_has_value(path: str | Path, key: str) -> bool:
    """Return True if <key>'s final assignment has a non-empty value."""
    if not _KEY_NAME_RE.fullmatch(key):
        return False
    try:
        text = Path(path).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return False
    raw_value: str | None = None
    for line in _non_comment_lines(text):
        match = _KEY_RE.fullmatch(line)
        if match and match.group(1) == key:
            raw_value = match.group(2)
    return raw_value not in (None, "", '""', "''")


def env_has_exact_empty_value(path: str | Path, key: str) -> bool:
    """Return True if <key>'s final assignment is exactly ``KEY=``."""
    if not _KEY_NAME_RE.fullmatch(key):
        return False
    try:
        text = Path(path).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return False
    raw_value: str | None = None
    for line in _non_comment_lines(text):
        match = _KEY_RE.fullmatch(line)
        if match and match.group(1) == key:
            raw_value = match.group(2)
    return raw_value == ""


def env_validate_format(path: str | Path) -> bool:
    """Return True if every non-blank, non-comment line looks like KEY=value."""
    try:
        text = Path(path).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return False
    for line in _non_comment_lines(text):
        if not _KEY_RE.fullmatch(line):
            return False
    return True


def env_keys_not_in_example(env: str | Path, example: str | Path) -> list[str]:
    """Return KEY names present in <env> but missing (even as empty) from <example>."""
    env_keys_set = set(env_keys(env))
    example_keys = set(env_keys(example))
    return sorted(env_keys_set - example_keys)


def env_is_missing_key(env: str | Path, example: str | Path) -> bool:
    """Return True if some KEY of <env> has NO counterpart (even empty) in <example>."""
    return bool(env_keys_not_in_example(env, example))


def env_load(path: str | Path) -> bool:
    """Load strict KEY=value data without evaluating shell syntax.

    The whole file is validated before changing ``os.environ``. Paired simple
    quotes are unwrapped; all other content stays literal.
    """
    try:
        text = Path(path).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return False

    assignments: list[tuple[str, str]] = []
    for line in _non_comment_lines(text):
        match = _KEY_RE.fullmatch(line)
        if not match:
            return False
        key, value = match.groups()
        if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
            value = value[1:-1]
        assignments.append((key, value))

    for key, value in assignments:
        os.environ[key] = value
    return True


if __name__ == "__main__":
    import sys

    # Tiny self-test when run directly (operates on a sample without secrets).
    sample = "A=1\n# comment\nB=\nBAD LINE\n"
    p = "/tmp/env_lib_sample.env"
    Path(p).write_text(sample, encoding="utf-8")
    assert env_keys(p) == ["A", "B"]
    assert env_has_value(p, "A") is True
    assert env_has_value(p, "B") is False
    assert env_validate_format(p) is False  # "BAD LINE" breaks format
    good = "/tmp/env_lib_good.env"
    Path(good).write_text("A=1\nB=\n", encoding="utf-8")
    assert env_validate_format(good) is True
    assert env_is_missing_key(good, p) is False  # B present (even empty) in both
    print("env_lib.py self-test OK")
    sys.exit(0)
