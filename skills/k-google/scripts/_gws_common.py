"""Shared helpers for k-google/scripts — do not run directly."""

from __future__ import annotations

import json
import os
import subprocess
from typing import Any


def _cfg(subdir: str) -> str:
    return os.path.join(os.path.expanduser("~"), ".config", "gws", subdir)


PROFILES: dict[str, dict[str, str]] = {
    "kpihx": {
        "label": "KpihX (kapoivha)",
        "config_dir": _cfg("kpihx"),
        "project_id": "kpihx-489121",
    },
    "labs": {
        "label": "KpihX-Labs (kpihx.labs)",
        "config_dir": _cfg("kpihx-labs"),
        "project_id": "kpihx-labs",
    },
}


def gws_env(profile: str) -> dict[str, str]:
    if profile not in PROFILES:
        raise ValueError(f"Unknown profile {profile!r}; use: {', '.join(PROFILES)}")
    p = PROFILES[profile]
    env = os.environ.copy()
    env["GOOGLE_WORKSPACE_CLI_CONFIG_DIR"] = p["config_dir"]
    env["GOOGLE_WORKSPACE_PROJECT_ID"] = p["project_id"]
    return env


def gws_run(profile: str, *args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["gws", *args],
        capture_output=True,
        text=True,
        env=gws_env(profile),
        check=False,
    )


def parse_json_stdout(raw: str) -> dict[str, Any]:
    start = raw.find("{")
    if start < 0:
        raise ValueError(f"No JSON object in gws output: {raw[:400]!r}")
    return json.loads(raw[start:])
