"""humanize_lib.py — shared humanize / PROSE guards for .agents Python scripts.

Central place for the Tier PROSE bloquant dash checks and related helpers.
This mirrors libs/humanize/humanize_lib.sh EXACTLY, language apart — see
libs/AGENTS.md for the mandatory "keep the 3 twins in sync" rule.

Validated by the user — 4 PROSE regex (Tier PROSE bloquant):
  EM_DASH_TRIPLE     = /---/            LaTeX em-dash
  EM_DASH_UNICODE    = /\\u2014/         — U+2014
  EN_DASH_SPACED     = / \\u2013 /       – U+2013 spaced (blocked)
  DOUBLE_DASH_SPACED = / -- /           markdown substitut

Hardened: also blocks escaped/encoded forms: \\u2014, \\U00002014, \\xE2\\x80\\x94, \\N{EM DASH}, chr(8212)/chr(0x2014)
Alternative dure for EN DASH: block spaced en-dash ONLY,
allow interval form [0-9]–[0-9] or [A-Za-z]–[A-Za-z] collé.

Provided here:
  is_allowed_en_dash(text) -> bool              : True=allowed, False=blocked
  contains_blocked_dash(text) -> dict           : {blocked, pattern, snippet} (also blocks escapes)
  decode_unicode_escapes_for_check(text) -> str : decode escapes to real chars for second-pass check
  contains_blocked_dash_with_escapes(text) -> alias (compat)
  is_code_file(path) -> bool                : True if code (whitelisted)
  is_prose_file(path) -> bool               : True if prose extension
  strip_tmux_wrapper(cmd) -> str            : strip send-keys wrapper → payload
  extract_bash_payload(cmd) -> str          : alias of strip_tmux_wrapper

Caller convention (mirroring libs/humanize/humanize_lib.sh):
  - scripts/*/ import via sys.path insertion of $HOME/.agents/libs.

Usage:
  from humanize_lib import contains_blocked_dash, is_code_file
  result = contains_blocked_dash("hello --- world")
  # {"blocked": True, "pattern": "EM_DASH_TRIPLE", "snippet": "---"}

Reference:  validated — single source of truth for PROSE dash
Single source for SEND_KEYS_REGEX: skills/k-opencode/scripts/plugins/libs/tmux-patterns.js
"""

from __future__ import annotations

import re
from pathlib import Path

# --- Tier PROSE bloquant patterns ---
EM_DASH_TRIPLE = "---"
EM_DASH_UNICODE = "\u2014"  # —
EN_DASH_SPACED = " \u2013 "  # space–space
DOUBLE_DASH_SPACED = " -- "  # space--space

# Compiled regex for snippet extraction (mirrors shell grep patterns)
_EM_DASH_TRIPLE_RE = re.compile(r"---")
_EM_DASH_UNICODE_RE = re.compile("\u2014")
_DOUBLE_DASH_SPACED_RE = re.compile(r" -- ")
_EN_DASH_SPACED_RE = re.compile(" \u2013 ")

# --- Escaped / encoded bypasses (hardened, K\u03c0X) ---
_ESCAPED_U4_RE = re.compile(r"\\u201[2-5]", re.IGNORECASE)
_ESCAPED_U8_RE = re.compile(r"\\U0000201[2-5]", re.IGNORECASE)
_ESCAPED_X_RE = re.compile(r"\\xE2\\x80\\x9[2-5]", re.IGNORECASE)
_ESCAPED_N_RE = re.compile(
    r"\\N\{(?:EM DASH|EN DASH|FIGURE DASH|HORIZONTAL BAR)\}", re.IGNORECASE
)
_ESCAPED_CHR_RE = re.compile(r"chr\s*\(\s*(?:821[0-3]|0x201[2-5])\s*\)", re.IGNORECASE)

# SEND_KEYS_REGEX — mirrors tmux-patterns.js
SEND_KEYS_REGEX = re.compile(r"tmux\s+send-keys\s+(?:-l\s+|-p\s+)?-t\s+[%$@\w.:-]+")

# Interval form: alnum–alnum collé (no spaces) — allowed
_INTERVAL_RE = re.compile(r"[A-Za-z0-9]\u2013[A-Za-z0-9]")

# --- Code extensions whitelisted (is_code_file → True = skip) ---
_CODE_EXTS: frozenset[str] = frozenset(
    {
        "py",
        "js",
        "ts",
        "tsx",
        "jsx",
        "go",
        "rs",
        "java",
        "c",
        "cpp",
        "h",
        "hpp",
        "sh",
        "bash",
        "zsh",
        "json",
        "yaml",
        "yml",
        "toml",
        "lock",
        "svg",
        "png",
        "jpg",
        "jpeg",
        "pdf",
        "pyc",
        "class",
        "o",
        "so",
        "dylib",
        "db",
        "sqlite",
    }
)

_PROSE_EXTS: frozenset[str] = frozenset(
    {
        "md",
        "tex",
        "txt",
        "rst",
        "adoc",
        "mdx",
        "html",
    }
)


def _ext(path: str | Path) -> str:
    """Return lowercased extension without dot, or '' if none."""
    p = Path(path)
    suffix = p.suffix  # includes dot, e.g. ".md"
    if not suffix:
        return ""
    return suffix[1:].lower()


def is_code_file(path: str | Path) -> bool:
    """Return True if path has a code whitelisted extension (should be skipped).

    Mirrors humanize_lib.sh:is_code_file — same extension list.
    """
    ext = _ext(path)
    if not ext:
        return False
    return ext in _CODE_EXTS


def is_prose_file(path: str | Path) -> bool:
    """Return True if path has a prose extension (md, tex, txt, ...).

    Note: extensionless files return False — caller should use
    ``not is_code_file(path)`` for prose-candidate gating.
    """
    ext = _ext(path)
    return ext in _PROSE_EXTS


def is_allowed_en_dash(text: str) -> bool:
    """Return True if en-dash usage is allowed, False if blocked.

    Logic (dure alternative):
      - " – " (space–space) → blocked → False
      - "–" with no surrounding spaces AND alnum on both sides (interval) → allowed → True
      - no en-dash → allowed → True
      - any other en-dash without spaced form → allowed (only spaced is bloquant)
    Mirrors humanize_lib.sh:is_allowed_en_dash.
    """
    if EN_DASH_SPACED in text:
        return False
    if "\u2013" not in text:
        return True
    # Has en-dash but not spaced → allowed per dure alternative
    # (only spaced form is bloquant; interval form explicitly allowed)
    return True


def decode_unicode_escapes_for_check(text: str) -> str:
    """Decode escaped / encoded dash forms to literal unicode for second-pass check.

    Replaces: \\u2012..\\u2015, \\U00002012.., \\xE2\\x80\\x92..95, \\N{EM DASH}/etc, chr(8210..)
    Returns decoded string. Used as defense-in-depth after raw escaped check.
    """
    s = text
    s = re.sub(
        r"\\u201[2-5]",
        lambda m: chr(int(m.group(0)[2:], base=16)),  # noqa: FURB166 — base=0 fails on bare hex strings without 0x prefix
        s,
        flags=re.IGNORECASE,
    )
    s = re.sub(
        r"\\U0000201[2-5]",
        lambda m: chr(int(m.group(0)[2:].lstrip("0") or "0", base=16)),
        s,
        flags=re.IGNORECASE,
    )

    def _repl_x(m: re.Match[str]) -> str:
        tail = m.group(0)[-2:].lower()
        mp: dict[str, str] = {
            "92": "\u2012",
            "93": "\u2013",
            "94": "\u2014",
            "95": "\u2015",
        }
        return mp.get(tail, m.group(0))

    s = re.sub(r"\\xE2\\x80\\x9[2-5]", _repl_x, s, flags=re.IGNORECASE)
    s = re.sub(r"\\N\{(?:EM DASH|HORIZONTAL BAR)\}", "\u2014", s, flags=re.IGNORECASE)
    s = re.sub(r"\\N\{EN DASH\}", "\u2013", s, flags=re.IGNORECASE)
    s = re.sub(r"\\N\{FIGURE DASH\}", "\u2012", s, flags=re.IGNORECASE)
    s = re.sub(
        r"chr\s*\(\s*(821[0-3])\s*\)",
        lambda m: chr(int(re.search(r"821[0-3]", m.group(0)).group(0))),  # pyright: ignore[reportOptionalMemberAccess] — inner regex guaranteed to match
        s,
        flags=re.IGNORECASE,
    )
    s = re.sub(
        r"chr\s*\(\s*0x201[2-5]\s*\)",
        lambda m: chr(
            int(re.search(r"0x201[2-5]", m.group(0), re.IGNORECASE).group(0), base=0)  # pyright: ignore[reportOptionalMemberAccess] — inner regex guaranteed to match
        ),
        s,
        flags=re.IGNORECASE,
    )
    return s


def _check_escaped(text: str) -> dict | None:
    """Check raw escaped patterns. Returns blocked dict or None."""
    m = _ESCAPED_U4_RE.search(text)
    if m:
        hexpart = m.group(0)[2:].upper()
        return {
            "blocked": True,
            "pattern": f"ESCAPED_U{hexpart}",
            "snippet": m.group(0),
        }
    m = _ESCAPED_U8_RE.search(text)
    if m:
        hexpart = re.sub(r"^\\U0*", "", m.group(0), flags=re.IGNORECASE).upper()
        return {
            "blocked": True,
            "pattern": f"ESCAPED_U{hexpart}",
            "snippet": m.group(0),
        }
    m = _ESCAPED_X_RE.search(text)
    if m:
        tail = m.group(0)[-2:].lower()
        mp = {"92": "2012", "93": "2013", "94": "2014", "95": "2015"}
        code = mp.get(tail, "2014")
        return {"blocked": True, "pattern": f"ESCAPED_X_{code}", "snippet": m.group(0)}
    m = _ESCAPED_N_RE.search(text)
    if m:
        up = m.group(0).upper()
        if "EM DASH" in up:
            tag = "EM_DASH"
        elif "EN DASH" in up:
            tag = "EN_DASH"
        elif "FIGURE" in up:
            tag = "FIGURE_DASH"
        else:
            tag = "HORIZONTAL_BAR"
        return {"blocked": True, "pattern": f"ESCAPED_N_{tag}", "snippet": m.group(0)}
    m = _ESCAPED_CHR_RE.search(text)
    if m:
        inner = re.sub(r"chr\s*\(\s*", "", m.group(0), flags=re.IGNORECASE)
        inner = re.sub(r"\s*\)", "", inner)
        code = inner.upper() if inner.lower().startswith("0x") else inner
        return {
            "blocked": True,
            "pattern": f"ESCAPED_CHR_{code}",
            "snippet": m.group(0),
        }
    return None


def contains_blocked_dash(text: str) -> dict:
    """Check text for any Tier PROSE bloquant dash pattern.

    Returns dict with:
      blocked: bool  — True if any pattern matched
      pattern: str | None — which pattern matched (priority order)
      snippet: str | None — matched snippet (first occurrence, ~30 chars context if available)

    Priority: ESCAPED_* -> EM_DASH_TRIPLE -> EM_DASH_UNICODE -> DOUBLE_DASH_SPACED -> EN_DASH_SPACED -> decoded
    Mirrors humanize_lib.sh:contains_blocked_dash and humanize_lib.js:containsBlockedDash.
    """
    esc = _check_escaped(text)
    if esc:
        return esc

    # EM_DASH_TRIPLE: a `---` INSIDE a line is the LaTeX em-dash (blocked);
    # a line that IS exactly `---` is the YAML front-matter delimiter /
    # markdown HR (allowed) — mirrors the standalone-HR exemption that
    # scripts/check-dashes.sh already applies line by line. Fixed 2026-08-08:
    # the raw regex used to block every YAML front-matter block.
    for line in text.splitlines():
        if line.strip() != EM_DASH_TRIPLE and EM_DASH_TRIPLE in line:
            return {
                "blocked": True,
                "pattern": "EM_DASH_TRIPLE",
                "snippet": EM_DASH_TRIPLE,
            }

    m = _EM_DASH_UNICODE_RE.search(text)
    if m:
        return {"blocked": True, "pattern": "EM_DASH_UNICODE", "snippet": m.group(0)}

    m = _DOUBLE_DASH_SPACED_RE.search(text)
    if m:
        return {"blocked": True, "pattern": "DOUBLE_DASH_SPACED", "snippet": m.group(0)}

    m = _EN_DASH_SPACED_RE.search(text)
    if m:
        return {"blocked": True, "pattern": "EN_DASH_SPACED", "snippet": m.group(0)}

    decoded = decode_unicode_escapes_for_check(text)
    if decoded != text:
        m = _EM_DASH_UNICODE_RE.search(decoded)
        if m:
            return {
                "blocked": True,
                "pattern": "ESCAPED_DECODED_EM_DASH",
                "snippet": m.group(0),
            }
        m = _EN_DASH_SPACED_RE.search(decoded)
        if m:
            return {
                "blocked": True,
                "pattern": "ESCAPED_DECODED_EN_DASH_SPACED",
                "snippet": m.group(0),
            }
        if "\u2012" in decoded or "\u2015" in decoded:
            ch = "\u2012" if "\u2012" in decoded else "\u2015"
            return {"blocked": True, "pattern": "ESCAPED_DECODED_DASH", "snippet": ch}

    return {"blocked": False, "pattern": None, "snippet": None}


def contains_blocked_dash_with_escapes(text: str) -> dict:
    """Alias for compat."""
    return contains_blocked_dash(text)


def strip_tmux_wrapper(cmd: str) -> str:
    """Strip outer tmux send-keys wrapper and return inner payload.

    If cmd matches SEND_KEYS_REGEX, extracts the first quoted payload
    (single or double quotes) before Enter. Otherwise returns cmd unchanged.
    Crude extraction for hook reuse — mirrors humanize_lib.sh:strip_tmux_wrapper.
    """
    if not SEND_KEYS_REGEX.search(cmd):
        return cmd

    # Try single-quoted payload first
    m = re.search(r"send-keys[^']*'([^']*)'", cmd)
    if m:
        return m.group(1)

    # Then double-quoted
    m = re.search(r'send-keys[^"]*"([^"]*)"', cmd)
    if m:
        return m.group(1)

    return cmd


def extract_bash_payload(cmd: str) -> str:
    """Alias of strip_tmux_wrapper — crude heredoc/quoted payload extraction.

    For now just delegates to strip_tmux_wrapper (SEND_KEYS_REGEX detection).
    Kept as separate name for caller convenience / future heredoc support.
    """
    return strip_tmux_wrapper(cmd)


if __name__ == "__main__":
    # Tiny self-test when run directly — mirrors humanize_lib.sh logic
    assert is_code_file("foo.py") is True
    assert is_code_file("doc.md") is False
    assert is_code_file("image.png") is True
    assert is_code_file("AGENTS.md") is False
    assert is_prose_file("doc.md") is True
    assert is_prose_file("foo.py") is False

    assert is_allowed_en_dash("hello – world") is False  # spaced → blocked
    assert is_allowed_en_dash("2024–2025") is True  # interval → allowed
    assert is_allowed_en_dash("pages 10–20") is True  # digit interval collé → allowed
    assert is_allowed_en_dash("pages 10 – 20") is False  # spaced → blocked
    assert is_allowed_en_dash("no dash here") is True
    assert is_allowed_en_dash("a–b") is True  # alpha interval → allowed

    assert contains_blocked_dash("hello --- world")["pattern"] == "EM_DASH_TRIPLE"
    # YAML front-matter delimiter / markdown HR: a line that IS `---` is allowed
    fm = "-" * 3
    fm_block = fm + "\nlayout: X\npart: Y\n" + fm + "\nbody text"
    assert contains_blocked_dash(fm_block)["blocked"] is False
    assert contains_blocked_dash(fm)["blocked"] is False
    # inline triple (any line containing it, but not equal to it) stays blocked
    assert contains_blocked_dash(fm + " inline")["pattern"] == "EM_DASH_TRIPLE"
    assert contains_blocked_dash("hello — world")["pattern"] == "EM_DASH_UNICODE"
    assert contains_blocked_dash("hello -- world")["pattern"] == "DOUBLE_DASH_SPACED"
    assert contains_blocked_dash("hello – world")["pattern"] == "EN_DASH_SPACED"
    assert contains_blocked_dash("2024–2025")["blocked"] is False  # interval allowed
    assert contains_blocked_dash("clean text")["blocked"] is False

    assert strip_tmux_wrapper("tmux send-keys -t foo:0.1 'echo hi' Enter") == "echo hi"
    assert strip_tmux_wrapper('tmux send-keys -t foo:0.1 "echo hi" Enter') == "echo hi"
    assert strip_tmux_wrapper("echo hi") == "echo hi"
    assert (
        extract_bash_payload("tmux send-keys -t foo:0.1 'echo hi' Enter") == "echo hi"
    )

    print("humanize_lib.py self-test OK")
