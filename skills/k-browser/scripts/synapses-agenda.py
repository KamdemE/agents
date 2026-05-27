#!/usr/bin/env python3
"""Affiche l'emploi du temps SynapseS depuis l'URL iCal de synchronisation.

Usage:
  python3 synapses-agenda.py --url 'https://synapses.polytechnique.fr/calendar/ical/TOKEN'
  python3 synapses-agenda.py --ics ~/synapses.ics --from 2026-05-25 --to 2026-06-14

L'URL se trouve sur SynapseS → bas de page → #input-url-sync-agenda (ne pas commiter le token).
"""
from __future__ import annotations

import argparse
import re
import sys
import urllib.request
from collections import defaultdict
from datetime import date, datetime
from pathlib import Path

DAYS_FR = ["lun", "mar", "mer", "jeu", "ven", "sam", "dim"]


def unfold_ics(text: str) -> list[str]:
    lines: list[str] = []
    for line in text.splitlines():
        if line.startswith((" ", "\t")) and lines:
            lines[-1] += line[1:]
        else:
            lines.append(line)
    return lines


def parse_events(ics_text: str) -> list[dict]:
    events: list[dict] = []
    cur: dict[str, str] = {}
    for line in unfold_ics(ics_text):
        if line == "BEGIN:VEVENT":
            cur = {}
        elif line == "END:VEVENT":
            if cur.get("DTSTART"):
                events.append(cur)
            cur = {}
        elif line.startswith("DTSTART"):
            cur["DTSTART"] = line.split(":", 1)[1]
        elif line.startswith("DTEND"):
            cur["DTEND"] = line.split(":", 1)[1]
        elif line.startswith("SUMMARY:"):
            cur["SUMMARY"] = line[8:]
        elif line.startswith("LOCATION:"):
            cur["LOCATION"] = line[9:]
        elif line.startswith("DESCRIPTION:"):
            cur["DESCRIPTION"] = line[12:].replace("\\n", "\n")
    return events


def parse_dt(raw: str) -> datetime:
    if ":" in raw and "TZID" in raw:
        raw = raw.split(":", 1)[1]
    if raw.endswith("Z"):
        return datetime.strptime(raw, "%Y%m%dT%H%M%SZ")
    return datetime.strptime(raw[:15], "%Y%m%dT%H%M%S")


def event_type(desc: str, summary: str) -> str:
    blob = f"{summary} {desc}".lower()
    if "contrôle classant" in blob or "controle classant" in blob:
        return "CC"
    if "petite classe" in blob:
        return "PC"
    if "cours magistral" in blob:
        return "CM"
    return "—"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--url", help="URL iCal SynapseS (sync agenda)")
    ap.add_argument("--ics", type=Path, help="Fichier .ics local")
    ap.add_argument("--from", dest="date_from", default=date.today().isoformat())
    ap.add_argument("--to", dest="date_to", default=None)
    args = ap.parse_args()

    if args.ics:
        ics_text = args.ics.read_text(encoding="utf-8", errors="replace")
    elif args.url:
        with urllib.request.urlopen(args.url, timeout=60) as resp:
            ics_text = resp.read().decode("utf-8", errors="replace")
    else:
        ap.error("Indiquer --url ou --ics")

    d0 = date.fromisoformat(args.date_from)
    d1 = date.fromisoformat(args.date_to) if args.date_to else d0

    filtered: list[dict] = []
    for e in parse_events(ics_text):
        try:
            start = parse_dt(e["DTSTART"])
        except (KeyError, ValueError):
            continue
        d = start.date()
        if d0 <= d <= d1:
            try:
                end = parse_dt(e["DTEND"])
            except (KeyError, ValueError):
                end = start
            filtered.append(
                {
                    "date": d,
                    "day": DAYS_FR[d.weekday()],
                    "start": start.strftime("%H:%M"),
                    "end": end.strftime("%H:%M"),
                    "summary": e.get("SUMMARY", ""),
                    "location": e.get("LOCATION", ""),
                    "type": event_type(e.get("DESCRIPTION", ""), e.get("SUMMARY", "")),
                }
            )

    filtered.sort(key=lambda x: (x["date"], x["start"]))

    by_week: dict[int, list] = defaultdict(list)
    for ev in filtered:
        by_week[ev["date"].isocalendar()[1]].append(ev)

    if not filtered:
        print(f"Aucun événement entre {d0} et {d1}.", file=sys.stderr)
        return 1

    for wk in sorted(by_week):
        print(f"\n=== Semaine {wk} ===")
        cur_d = None
        for ev in by_week[wk]:
            if ev["date"] != cur_d:
                cur_d = ev["date"]
                print(f"\n{ev['day'].capitalize()} {ev['date'].strftime('%d/%m/%Y')}")
            loc = f" — {ev['location']}" if ev["location"] else ""
            print(f"  {ev['start']}-{ev['end']}  [{ev['type']}]  {ev['summary']}{loc}")

    print(f"\nTotal: {len(filtered)} créneau(x)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
