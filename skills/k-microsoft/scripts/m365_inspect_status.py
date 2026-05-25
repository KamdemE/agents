#!/usr/bin/env python3
"""Print m365 login status (read-only). Agents must never run m365 login/logout."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from _m365_common import m365_run


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--json",
        action="store_true",
        help="Use m365 --output json when supported",
    )
    args = parser.parse_args()

    cmd = ["status"]
    if args.json:
        cmd.append("--output")
        cmd.append("json")
    r = m365_run(*cmd)
    if r.returncode != 0:
        print(r.stderr or r.stdout, file=sys.stderr)
        return r.returncode
    print(r.stdout)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
