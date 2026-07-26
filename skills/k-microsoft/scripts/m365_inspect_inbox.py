#!/usr/bin/env python3
"""List recent Outlook inbox messages via m365 (read-only)."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from _m365_common import m365_run, parse_json_stdout


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--folder", default="Inbox", help="Outlook folder name")
    parser.add_argument("--json", action="store_true", dest="as_json")
    args = parser.parse_args()

    cmd = [
        "outlook",
        "message",
        "list",
        "--folderName",
        args.folder,
        "--output",
        "json",
    ]
    r = m365_run(*cmd)
    if r.returncode != 0:
        print(r.stderr or r.stdout[:500], file=sys.stderr)
        return r.returncode

    data = parse_json_stdout(r.stdout)
    if not isinstance(data, list):
        data = [data]

    rows = []
    for item in data:
        rows.append(
            {
                "subject": item.get("subject", ""),
                "from": (item.get("from") or {})
                .get("emailAddress", {})
                .get("address", ""),
                "received": item.get("receivedDateTime", ""),
                "id": item.get("id", ""),
            }
        )

    if args.as_json:
        print(json.dumps(rows, indent=2, ensure_ascii=False))
        return 0

    print(f"Folder: {args.folder} — {len(rows)} message(s)\n")
    for row in rows:
        print(f"  {row['received'][:30]}")
        print(f"    From: {row['from'][:80]}")
        print(f"    Subject: {row['subject'][:90]}")
        print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
