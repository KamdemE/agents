"""env_lib.py — shared .env helpers for .agents Python scripts.

Central place for everything common to .agents Python scripts that deal with
.env / .env.example files (secrets — KπX NEVER reads/prints values, only key
names + whether a value is present/empty). This mirrors libs/env/env_lib.sh
EXACTLY, language apart — see libs/AGENTS.md for the "keep the 3 twins in
sync" rule. Python callers import this module instead of re-implementing.

Provided here (functions operate on key NAMES and presence, never values):
  env_keys(path)              -> list[str] : non-commented KEY names (sorted, unique)
  env_has_value(path, key)    -> bool      : True if <key> has a non-empty value
  env_validate_format(path)   -> bool      : True if every line is blank/comment/KEY=...
  env_keys_not_in_example(env, example) -> list[str] : KEYs present in env but
                                           absent from example (names only)
  env_is_missing_key(env, example)      -> bool : True if some KEY of env has
                                           no (even empty) counterpart in example

SECURITY: these helpers ONLY ever return KEY NAMES or present/empty booleans.
They NEVER return or read the VALUES. Keep it that way (secrets zero-touch).

Caller convention (mirroring libs/jsonc/jsonc_lib.sh):
  - scripts/*/ import this module via sys.path insertion of $HOME/.agents/libs.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Iterable

_KEY_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)=.*$")


def _non_comment_lines(text: str) -> Iterable[str]:
    """Yield trimmed lines that are neither blank nor full-line comments."""
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
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
    """Return True if <key> exists AND has a non-empty value (starts with KEY=...)."""
    try:
        text = Path(path).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return False
    # a line "KEY=value" with something after the '='
    return any(
        line.startswith(f"{key}=") and line[len(key) + 1 :]
        for line in _non_comment_lines(text)
    )


def env_validate_format(path: str | Path) -> bool:
    """Return True if every non-blank, non-comment line looks like KEY=value."""
    try:
        text = Path(path).read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return False
    for line in _non_comment_lines(text):
        if not _KEY_RE.match(line):
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
