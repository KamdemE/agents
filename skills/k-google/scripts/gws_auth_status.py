#!/usr/bin/env python3
"""Print gws auth/config hints per profile (read-only, no secrets)."""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from _gws_common import PROFILES


def profile_status(profile: str) -> dict:
    cfg = PROFILES[profile]["config_dir"]
    secret = Path(cfg) / "client_secret.json"
    cred = Path(cfg) / "credentials.json"
    return {
        "profile": profile,
        "label": PROFILES[profile]["label"],
        "config_dir": cfg,
        "project_id": PROFILES[profile]["project_id"],
        "client_secret_json": secret.is_file(),
        "credentials_json": cred.is_file(),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--profile",
        choices=["kpihx", "labs", "both"],
        default="both",
    )
    parser.add_argument("--json", action="store_true", dest="as_json")
    args = parser.parse_args()

    profiles = list(PROFILES) if args.profile == "both" else [args.profile]
    rows = [profile_status(p) for p in profiles]

    if args.as_json:
        print(json.dumps(rows, indent=2))
        return 0

    for row in rows:
        print(f"\n{row['label']} ({row['profile']})")
        print(f"  config_dir: {row['config_dir']}")
        print(f"  project_id: {row['project_id']}")
        print(f"  client_secret.json: {'yes' if row['client_secret_json'] else 'NO'}")
        print(f"  credentials.json: {'yes' if row['credentials_json'] else 'NO (run gws auth login)'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
