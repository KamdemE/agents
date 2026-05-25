"""Shared helpers for k-microsoft/scripts — do not run directly."""

from __future__ import annotations

import json
import subprocess
from typing import Any


def m365_run(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["m365", *args],
        capture_output=True,
        text=True,
    )


def parse_json_stdout(raw: str) -> Any:
    start = raw.find("{")
    if start < 0:
        bracket = raw.find("[")
        if bracket < 0:
            raise ValueError(f"No JSON in m365 output: {raw[:400]!r}")
        start = bracket
    return json.loads(raw[start:])
