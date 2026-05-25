#!/usr/bin/env python3
"""List recent Gmail messages (metadata only, read-only)."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from _gws_common import PROFILES, gws_run, parse_json_stdout


def list_message_ids(profile: str, count: int) -> list[str]:
    params = json.dumps({"userId": "me", "maxResults": count})
    r = gws_run(profile, "gmail", "users", "messages", "list", "--params", params)
    if r.returncode != 0:
        raise RuntimeError(r.stderr or r.stdout[:500])
    data = parse_json_stdout(r.stdout)
    return [m["id"] for m in data.get("messages", [])]


def get_headers(profile: str, msg_id: str) -> dict[str, str]:
    params = json.dumps(
        {
            "userId": "me",
            "id": msg_id,
            "format": "metadata",
            "metadataHeaders": ["Subject", "From", "Date"],
        }
    )
    r = gws_run(profile, "gmail", "users", "messages", "get", "--params", params)
    if r.returncode != 0:
        raise RuntimeError(r.stderr or r.stdout[:500])
    data = parse_json_stdout(r.stdout)
    return {
        h["name"]: h["value"]
        for h in data.get("payload", {}).get("headers", [])
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--profile",
        choices=["kpihx", "labs", "both"],
        default="both",
    )
    parser.add_argument("--count", type=int, default=15)
    parser.add_argument("--json", action="store_true", dest="as_json")
    args = parser.parse_args()

    profiles = list(PROFILES) if args.profile == "both" else [args.profile]
    out: dict[str, list[dict]] = {}

    for profile in profiles:
        rows = []
        for mid in list_message_ids(profile, args.count):
            h = get_headers(profile, mid)
            rows.append(
                {
                    "date": h.get("Date", ""),
                    "from": h.get("From", ""),
                    "subject": h.get("Subject", "(no subject)"),
                }
            )
        out[profile] = rows

    if args.as_json:
        print(json.dumps(out, indent=2, ensure_ascii=False))
        return 0

    for profile, rows in out.items():
        label = PROFILES[profile]["label"]
        print(f"\n{'=' * 60}\nRECENT MAIL — {label}\n{'=' * 60}")
        for row in rows:
            print(f"  {row['date'][:45]}")
            print(f"    From: {row['from'][:80]}")
            print(f"    Subject: {row['subject'][:90]}")
            print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
