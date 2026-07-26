#!/usr/bin/env python3
"""List Google People connections for a gws profile (read-only)."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from _gws_common import PROFILES, gws_run, parse_json_stdout


def fetch_connections(profile: str, page_size: int) -> list[dict]:
    params = json.dumps(
        {
            "resourceName": "people/me",
            "pageSize": page_size,
            "personFields": "names,emailAddresses,phoneNumbers,organizations",
        }
    )
    r = gws_run(
        profile,
        "people",
        "people",
        "connections",
        "list",
        "--params",
        params,
    )
    if r.returncode != 0:
        raise RuntimeError(r.stderr or r.stdout[:500])
    data = parse_json_stdout(r.stdout)
    return data.get("connections", [])


def contact_row(c: dict) -> dict:
    names = c.get("names") or [{}]
    name = names[0].get("displayName") or names[0].get("unstructuredName") or "?"
    emails = [e.get("value") for e in c.get("emailAddresses", []) if e.get("value")]
    phones = [p.get("value") for p in c.get("phoneNumbers", []) if p.get("value")]
    orgs = [o.get("name") for o in c.get("organizations", []) if o.get("name")]
    return {
        "name": name,
        "emails": emails,
        "phones": phones,
        "orgs": orgs,
    }


def matches_filter(row: dict, flt: str) -> bool:
    blob = " ".join([row["name"], *row["emails"], *row["phones"], *row["orgs"]]).lower()
    if flt == "all":
        return True
    if flt == "email":
        return bool(row["emails"])
    if flt == "kamdem":
        return "kamdem" in blob or "pouokam" in blob
    if flt == "poly":
        return "polytechnique" in blob or "kes.eleves" in blob
    raise ValueError(f"Unknown filter: {flt}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--profile",
        choices=["kpihx", "labs", "both"],
        default="both",
        help="gws profile (default: both)",
    )
    parser.add_argument("--page-size", type=int, default=1000)
    parser.add_argument(
        "--filter",
        choices=["all", "email", "kamdem", "poly"],
        default="all",
    )
    parser.add_argument("--json", action="store_true", dest="as_json")
    args = parser.parse_args()

    profiles = list(PROFILES) if args.profile == "both" else [args.profile]
    out: dict[str, list[dict]] = {}

    for profile in profiles:
        conns = fetch_connections(profile, args.page_size)
        rows = [contact_row(c) for c in conns]
        if args.filter != "all":
            rows = [r for r in rows if matches_filter(r, args.filter)]
        out[profile] = rows

    if args.as_json:
        print(json.dumps(out, indent=2, ensure_ascii=False))
        return 0

    for profile, rows in out.items():
        label = PROFILES[profile]["label"]
        print(f"\n{'=' * 60}\nCONTACTS — {label} ({profile})\n{'=' * 60}")
        print(f"Shown: {len(rows)} (filter={args.filter})")
        for r in sorted(rows, key=lambda x: x["name"].lower()):
            line = f"  - {r['name']}"
            if r["emails"]:
                line += f" <{r['emails'][0]}>"
            elif r["phones"]:
                line += f" | {r['phones'][0]}"
            if r["orgs"]:
                line += f" [{r['orgs'][0]}]"
            print(line)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
