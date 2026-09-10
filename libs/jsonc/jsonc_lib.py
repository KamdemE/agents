"""jsonc_lib.py — shared JSONC helpers for .agents Python scripts.

Central place for everything common to .agents Python scripts that deal with
JSONC assets (config-with-comments — the standard, see k-project and
`libs/jsonc_lib.sh` for the shell twin). Python callers import this module
instead of re-implementing comment-stripping + loading.

Provided here:
  strip_jsonc(src)   -> str    : remove // and /* */ comments (respects strings)
  load_jsonc(path)   -> obj    : parse a JSONC file into its JSON value
  load_jsonc_obj(path) -> dict : same but always returns a dict ({} on failure)

Caller convention (mirroring libs/jsonc_lib.sh):
  - scripts/*/ import this module via sys.path insertion of $HOME/.agents/libs.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def strip_jsonc(src: str) -> str:
    """Remove // and /* */ comments from a JSONC string, respecting string literals."""
    out: list[str] = []
    in_str = False
    i = 0
    n = len(src)
    while i < n:
        c = src[i]
        nxt = src[i + 1] if i + 1 < n else ""
        if in_str:
            out.append(c)
            if c == "\\" and nxt:
                out.append(nxt)
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            out.append(c)
            i += 1
            continue
        if c == "/" and nxt == "/":
            while i < n and src[i] != "\n":
                i += 1
            continue
        if c == "/" and nxt == "*":
            i += 2
            while i + 1 < n and not (src[i] == "*" and src[i + 1] == "/"):
                i += 1
            i += 2
            continue
        out.append(c)
        i += 1
    return "".join(out)


def load_jsonc(path: Path | str) -> Any:
    """Parse a JSONC file (comments stripped) and return its JSON value.

    Returns None on any error (missing file, invalid JSON after stripping).
    """
    try:
        return json.loads(strip_jsonc(Path(path).read_text(encoding="utf-8")))
    except (OSError, json.JSONDecodeError, UnicodeDecodeError):
        return None


def load_jsonc_obj(path: Path | str) -> dict:
    """Return a dict from a JSONC file, or {} on any failure."""
    value = load_jsonc(path)
    return value if isinstance(value, dict) else {}


if __name__ == "__main__":
    import sys

    # Tiny self-test when run directly.
    sample = '{\n  // a comment\n  "a": 1, /* block */ "b": "// not a comment"\n}'
    stripped = strip_jsonc(sample)
    # the // comment and /* block */ are gone, but the // inside the string stays
    assert "// a comment" not in stripped
    assert "/* block */" not in stripped
    assert '"b": "// not a comment"' in stripped
    parsed = json.loads(stripped)
    assert parsed == {"a": 1, "b": "// not a comment"}
    print("jsonc_lib.py self-test OK")
    sys.exit(0)
