#!/usr/bin/env python3
"""List Outlook contacts via Microsoft Graph (read-only m365 request)."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from _m365_common import m365_run, parse_json_stdout


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--top", type=int, default=50, help="Graph $top page size")
    parser.add_argument("--json", action="store_true", dest="as_json")
    args = parser.parse_args()

    url = f"https://graph.microsoft.com/v1.0/me/contacts?$top={args.top}"
    r = m365_run(
        "request",
        "--url",
        url,
        "--method",
        "get",
        "--output",
        "json",
    )
    if r.returncode != 0:
        print(r.stderr or r.stdout[:500], file=sys.stderr)
        return r.returncode

    data = parse_json_stdout(r.stdout)
    items = data.get("value", []) if isinstance(data, dict) else data

    rows = []
    for c in items:
        emails = [
            e.get("address", "")
            for e in (c.get("emailAddresses") or [])
            if e.get("address")
        ]
        rows.append(
            {
                "name": c.get("displayName", "?"),
                "emails": emails,
            }
        )

    if args.as_json:
        print(json.dumps(rows, indent=2, ensure_ascii=False))
        return 0

    print(f"Contacts (top {args.top}): {len(rows)}\n")
    for row in sorted(rows, key=lambda x: x["name"].lower()):
        line = f"  - {row['name']}"
        if row["emails"]:
            line += f" <{row['emails'][0]}>"
        print(line)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
