#!/usr/bin/env python3
"""Deep cleanup + long-term filters for kapoivha Gmail (gws kpihx profile).

Dry-run:  --dry-run
Execute:  python3 gws_gmail_deep_cleanup.py
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from _gws_common import gws_run, parse_json_stdout

PROFILE = "kpihx"
BATCH = 1000

# Gmail allowed palette only (see users.labels.create color docs)
LABELS = {
    "KpihX/TickTick": {"backgroundColor": "#4986e7", "textColor": "#ffffff"},
    "KpihX/LinkedIn": {"backgroundColor": "#3c78d8", "textColor": "#ffffff"},
    "KpihX/GitHub": {"backgroundColor": "#434343", "textColor": "#ffffff"},
    "KpihX/DMARC": {"backgroundColor": "#666666", "textColor": "#ffffff"},
    "KpihX/Homelab": {"backgroundColor": "#0b804b", "textColor": "#ffffff"},
    "KpihX/Notifications": {"backgroundColor": "#ffad47", "textColor": "#000000"},
}

FILTERS = [
    {
        "criteria": {"from": "mail.ticktick.com"},
        "action": {
            "addLabelIds": ["KpihX/TickTick"],
            "removeLabelIds": ["INBOX", "UNREAD"],
        },
    },
    {
        "criteria": {"from": "linkedin.com"},
        "action": {
            "addLabelIds": ["KpihX/LinkedIn"],
            "removeLabelIds": ["INBOX", "UNREAD"],
        },
    },
    {
        "criteria": {"from": "notifications@github.com"},
        "action": {
            "addLabelIds": ["KpihX/GitHub"],
            "removeLabelIds": ["INBOX", "UNREAD"],
        },
    },
    {
        "criteria": {"from": "noreply@github.com"},
        "action": {
            "addLabelIds": ["KpihX/GitHub"],
            "removeLabelIds": ["INBOX", "UNREAD"],
        },
    },
    {
        "criteria": {"from": "noreply-dmarc-support@google.com"},
        "action": {
            "addLabelIds": ["KpihX/DMARC"],
            "removeLabelIds": ["INBOX", "UNREAD"],
        },
    },
    {
        "criteria": {"query": "to:@kpihx-labs.com"},
        "action": {
            "addLabelIds": ["KpihX/Homelab"],
            "removeLabelIds": ["INBOX", "UNREAD"],
        },
    },
    {
        "criteria": {"from": "deliveroo.com"},
        "action": {
            "addLabelIds": ["KpihX/Notifications"],
            "removeLabelIds": ["INBOX", "UNREAD"],
        },
    },
    {
        "criteria": {"from": "t.deliveroo.com"},
        "action": {
            "addLabelIds": ["KpihX/Notifications"],
            "removeLabelIds": ["INBOX", "UNREAD"],
        },
    },
    {
        "criteria": {"from": "news@communications.socgen.com"},
        "action": {"removeLabelIds": ["INBOX", "UNREAD"]},
    },
    {
        "criteria": {"from": "carrefour@email.carrefour.fr"},
        "action": {"removeLabelIds": ["INBOX", "UNREAD"]},
    },
    {
        "criteria": {"from": "no-reply@email.lebara.fr"},
        "action": {"removeLabelIds": ["INBOX", "UNREAD"]},
    },
    {
        "criteria": {"query": "subject:(OUT-E2E OR E2E-)"},
        "action": {"removeLabelIds": ["INBOX"], "addLabelIds": ["TRASH"]},
    },
]

# (mode, query) — delete = permanent; trash = TRASH label; archive = remove INBOX+UNREAD
CLEANUP_OPS = [
    ("delete", "subject:(OUT-E2E OR E2E-)"),
    ("delete", "in:spam"),
    ("archive", "category:promotions older_than:90d"),
    ("archive", "category:updates older_than:90d"),
    ("archive", "from:mail.ticktick.com"),
    ("archive", "from:linkedin.com"),
    ("archive", "from:noreply-dmarc-support@google.com"),
    ("archive", "from:notifications@github.com older_than:30d"),
    ("archive", "from:noreply@github.com older_than:30d"),
    ("delete", "from:uber.com older_than:365d"),
    ("delete", "from:medium.com older_than:365d"),
    ("delete", "from:notifications.freelancer.com older_than:365d"),
    ("delete", "from:freelancer.com older_than:365d"),
    ("delete", "from:french-personalized-digest@quora.com older_than:365d"),
    ("delete", "from:actualite@lci.fr older_than:365d"),
    ("archive", "from:carrefour@email.carrefour.fr"),
    ("archive", "from:no-reply@email.lebara.fr"),
    ("archive", "from:news@communications.socgen.com"),
    ("archive", "from:noreply@t.deliveroo.com older_than:14d"),
    ("archive", "from:account-security-noreply@accountprotection.microsoft.com older_than:30d"),
    ("archive", "from:no-reply@accounts.google.com older_than:30d"),
    ("archive", "is:unread older_than:180d"),
]


def api(*args: str) -> dict:
    r = gws_run(PROFILE, "gmail", "users", *args)
    if r.returncode != 0:
        raise RuntimeError((r.stderr or r.stdout)[:800])
    raw = (r.stdout or "").strip()
    if not raw or not raw.lstrip().startswith("{"):
        return {}
    return parse_json_stdout(r.stdout)


def label_stats() -> dict[str, int]:
    out = {}
    for lid in (
        "INBOX",
        "SPAM",
        "TRASH",
        "UNREAD",
        "CATEGORY_PROMOTIONS",
        "CATEGORY_UPDATES",
    ):
        d = api("labels", "get", "--params", json.dumps({"userId": "me", "id": lid}))
        out[d["name"]] = int(d.get("messagesTotal") or 0)
    p = api("getProfile", "--params", '{"userId":"me"}')
    out["_total"] = int(p.get("messagesTotal") or 0)
    return out


def list_all_ids(q: str, max_messages: int | None = None) -> list[str]:
    ids: list[str] = []
    token = None
    while True:
        params: dict = {"userId": "me", "q": q, "maxResults": 500}
        if token:
            params["pageToken"] = token
        data = api("messages", "list", "--params", json.dumps(params))
        batch = [m["id"] for m in data.get("messages", [])]
        if not batch:
            break
        ids.extend(batch)
        if max_messages and len(ids) >= max_messages:
            return ids[:max_messages]
        token = data.get("nextPageToken")
        if not token:
            break
    return ids


def batch_modify(ids: list[str], add: list[str], remove: list[str], dry_run: bool) -> int:
    n = 0
    for i in range(0, len(ids), BATCH):
        chunk = ids[i : i + BATCH]
        body = {"ids": chunk, "addLabelIds": add, "removeLabelIds": remove}
        if dry_run:
            n += len(chunk)
            continue
        api(
            "messages",
            "batchModify",
            "--params",
            '{"userId":"me"}',
            "--json",
            json.dumps(body),
        )
        n += len(chunk)
        time.sleep(0.15)
    return n


def batch_trash(ids: list[str], dry_run: bool) -> int:
    """Move to Trash via batchModify (works with gmail.modify; permanent delete may lack scope)."""
    return batch_modify(ids, ["TRASH"], ["INBOX", "UNREAD"], dry_run)


def ensure_labels(dry_run: bool) -> dict[str, str]:
    existing = api("labels", "list", "--params", '{"userId":"me"}')
    by_name = {l["name"]: l["id"] for l in existing.get("labels", [])}
    for name, color in LABELS.items():
        if name in by_name:
            continue
        body = {
            "name": name,
            "labelListVisibility": "labelShow",
            "messageListVisibility": "hide",
            "color": color,
        }
        print(f"  create label: {name}", flush=True)
        if not dry_run:
            created = api("labels", "create", "--params", '{"userId":"me"}', "--json", json.dumps(body))
            by_name[name] = created["id"]
    return by_name


def filter_signature(criteria: dict, action: dict) -> str:
    return json.dumps({"c": criteria, "a": action}, sort_keys=True)


def _resolve_action(action: dict, name_to_id: dict[str, str]) -> dict:
    out = dict(action)
    add = []
    for lid_name in action.get("addLabelIds", []):
        add.append(name_to_id.get(lid_name, lid_name))
    if add:
        out["addLabelIds"] = add
    return out


def ensure_filters(name_to_id: dict[str, str], dry_run: bool) -> int:
    existing = api("settings", "filters", "list", "--params", '{"userId":"me"}')
    sigs = set()
    for f in existing.get("filter", []):
        sigs.add(filter_signature(f.get("criteria", {}), f.get("action", {})))

    created = 0
    for spec in FILTERS:
        criteria = spec["criteria"]
        action = _resolve_action(spec["action"], name_to_id)
        sig = filter_signature(criteria, action)
        if sig in sigs:
            continue
        body = {"criteria": criteria, "action": action}
        print(f"  create filter: {criteria}", flush=True)
        if not dry_run:
            try:
                api(
                    "settings",
                    "filters",
                    "create",
                    "--params",
                    '{"userId":"me"}',
                    "--json",
                    json.dumps(body),
                )
            except RuntimeError as e:
                if "already exists" in str(e).lower():
                    continue
                raise
        created += 1
    return created


def run_cleanup(dry_run: bool) -> dict[str, int]:
    results: dict[str, int] = {}
    for mode, q in CLEANUP_OPS:
        print(f"\n[{mode}] {q}", flush=True)
        ids = list_all_ids(q)
        print(f"  matched: {len(ids)}", flush=True)
        if not ids:
            results[f"{mode}:{q[:40]}"] = 0
            continue
        if mode in ("delete", "trash"):
            n = batch_trash(ids, dry_run)
        else:
            n = batch_modify(ids, [], ["INBOX", "UNREAD"], dry_run)
        results[f"{mode}:{q[:50]}"] = n
        print(f"  applied: {n}", flush=True)
    return results


def empty_trash(dry_run: bool) -> None:
    print("\n[empty_trash]", flush=True)
    if dry_run:
        return
    try:
        api("trash", "empty", "--params", '{"userId":"me"}')
    except Exception:
        try:
            api("messages", "emptyTrash", "--params", '{"userId":"me"}')
        except Exception as e:
            print(f"  skip emptyTrash (scope or API): {e}", flush=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    dry = args.dry_run

    print("=== BEFORE ===", flush=True)
    before = label_stats()
    for k, v in sorted(before.items()):
        print(f"  {k}: {v}", flush=True)

    print("\n=== LABELS ===", flush=True)
    name_to_id = ensure_labels(dry)

    print("\n=== FILTERS ===", flush=True)
    n_filters = ensure_filters(name_to_id, dry)
    print(f"  new filters: {n_filters}", flush=True)

    print("\n=== CLEANUP ===", flush=True)
    run_cleanup(dry)
    empty_trash(dry)

    if not dry:
        print("\n=== RE-APPLY FILTERS TO EXISTING (batch archive inbox stragglers) ===", flush=True)
        for q in [
            "in:inbox from:mail.ticktick.com",
            "in:inbox from:linkedin.com",
            "in:inbox category:promotions",
            "in:inbox category:updates older_than:7d",
        ]:
            ids = list_all_ids(q)
            if ids:
                batch_modify(ids, [], ["INBOX", "UNREAD"], dry_run=False)
                print(f"  swept {len(ids)} for {q}", flush=True)

    print("\n=== AFTER ===", flush=True)
    if dry:
        print("  (dry-run — stats unchanged)", flush=True)
    else:
        after = label_stats()
        for k, v in sorted(after.items()):
            print(f"  {k}: {v}", flush=True)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
