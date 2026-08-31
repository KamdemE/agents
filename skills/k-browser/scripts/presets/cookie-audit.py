#!/usr/bin/env python3
"""Preset: summarize `cookie-list`'s full envelope by domain — the raw list is often 100+ cookies,
too long to read directly. Usage:

    browser-proxy do cookie-list '{"profile":"default"}' >/dev/null 2>&1
    f=$(ls -t /tmp/browser-proxy-autosave/cookie-list_*.json | head -1)
    python3 ~/.agents/skills/k-browser/scripts/presets/cookie-audit.py "$f"
"""

import json
import sys
from collections import defaultdict

if len(sys.argv) != 2:
    print("usage: cookie-audit.py <cookie-list-envelope.json>", file=sys.stderr)
    raise SystemExit(1)

with open(sys.argv[1]) as f:
    envelope = json.load(f)
cookies = envelope["data"]["cookies"]

by_domain: dict[str, list] = defaultdict(list)
for cookie in cookies:
    by_domain[cookie["domain"]].append(cookie)

print(f"Total: {len(cookies)} cookies | {len(by_domain)} domains\n")
print(f"{'Domain':<40} {'Count':>5}  Examples")
print("-" * 90)
for domain in sorted(by_domain):
    entries = by_domain[domain]
    names = [c["name"] for c in entries[:3]]
    suffix = f" +{len(entries) - 3}+" if len(entries) > 3 else ""
    print(f"{domain:<40} {len(entries):>5}  {', '.join(names)}{suffix}")
