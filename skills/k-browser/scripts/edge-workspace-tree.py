#!/usr/bin/env python3
"""
Edge Workspace Explorer — KπX k-browser
Affiche tous les workspaces Edge avec leurs tabs et groupes de tabs.

Usage:
  python3 edge-workspace-tree.py          # Liste les workspaces + tabs CDP
  python3 edge-workspace-tree.py --detail # Affiche les URLs complètes
"""

import argparse
import json
import os
import re
import urllib.request
from datetime import datetime

CDP_URL = "http://127.0.0.1:9222"


def get_cdp_data(endpoint="/json/list"):
    try:
        resp = urllib.request.urlopen(f"{CDP_URL}{endpoint}", timeout=3)
        return json.loads(resp.read())
    except (urllib.error.URLError, json.JSONDecodeError, OSError, ValueError):
        return None


def get_edge_workspace_info():
    ws_dir = os.path.expanduser("~/.config/microsoft-edge/Default/Workspaces")
    workspace_cache = os.path.join(ws_dir, "WorkspacesCache")
    workspaces = []

    # Read WorkspacesCache for workspace names
    ws_map = {}
    if os.path.exists(workspace_cache):
        try:
            with open(workspace_cache) as f:
                data = json.load(f)
            for ws in data.get("workspaces", []):
                ws_map[ws.get("id")] = ws.get("name", "Unknown")
        except (json.JSONDecodeError, KeyError, TypeError, ValueError):
            pass

    # Read workspace cache files for additional metadata
    if os.path.isdir(ws_dir):
        for fname in sorted(os.listdir(ws_dir)):
            if fname.startswith("workspace_cache_"):
                ws_id = fname.replace("workspace_cache_", "")
                fpath = os.path.join(ws_dir, fname)
                try:
                    with open(fpath) as f:
                        data = json.load(f)
                    groups = list(data.get("Tab_Group_Collapsed_States", {}).keys())
                    name = ws_map.get(ws_id, f"Workspace-{ws_id[:8]}")
                    mtime = datetime.fromtimestamp(
                        os.path.getmtime(fpath), tz=datetime.timezone.utc
                    )
                    workspaces.append(
                        {
                            "id": ws_id,
                            "name": name,
                            "groups": len(groups),
                            "group_ids": groups,
                            "cache_mtime": mtime.strftime("%Y-%m-%d %H:%M"),
                        }
                    )
                except (
                    json.JSONDecodeError,
                    KeyError,
                    TypeError,
                    ValueError,
                    OSError,
                ) as e:
                    workspaces.append(
                        {"id": ws_id, "name": ws_map.get(ws_id, "?"), "error": str(e)}
                    )

    return workspaces


def group_tabs_by_window(tabs):
    """Try to group tabs by window context"""
    # Edge exposes `webSocketDebuggerUrl` which doesn't include window info
    # We can group by URL patterns as a heuristic
    return tabs


def print_tree(workspaces, tabs, detail=False):
    print("\n" + "=" * 60)
    print("  📊 EDGE — VUE COMPLÈTE")
    print("=" * 60)

    # 1. Workspaces
    print("\n  📁 WORKSPACES:")
    for ws in workspaces:
        active = "🟢" if "ACTIVE" in ws.get("flags", []) else "⚪"
        print(f"  {active} {ws['name']}")
        if ws.get("groups", 0) > 0:
            print(f"       Tab groups: {ws['groups']}")
        print(f"       Cache: {ws.get('cache_mtime', '?')}")

    # 2. Active tabs from CDP
    print("\n  📑 TABS ACTIFS (via CDP):")
    active_wins = {}
    for i, tab in enumerate(tabs):
        title = tab.get("title", "?")[:60] or "(no title)"
        url = tab.get("url", "")
        short_url = re.sub(r"[?#].*", "", url)[:60]
        # Categorize by domain
        domain = "?"
        m = re.match(r"https?://([^/]+)", url)
        if m:
            domain = m.group(1)

        if domain not in active_wins:
            active_wins[domain] = []
        active_wins[domain].append({"idx": i, "title": title, "url": short_url})

    # Print by domain groups
    for domain, domain_tabs in sorted(active_wins.items()):
        print(f"\n    🌐 {domain}")
        for t in domain_tabs:
            if detail:
                print(f"       [{t['idx']:2d}] {t['title']}")
                print(f"              {t['url']}")
            else:
                short_title = t["title"][:55]
                print(f"       [{t['idx']:2d}] {short_title}")

    # 3. Tab groups from workspace caches
    print("\n  🏷️ GROUPES DE TABS (cache historique):")
    has_groups = False
    for ws in workspaces:
        if ws.get("groups", 0) > 0:
            has_groups = True
            print(f"\n    📁 {ws['name']} ({ws['groups']} groupes):")
            for gid in ws.get("group_ids", []):
                print(f"       ├ 🗂️  {gid[:8]}...")
    if not has_groups:
        print(
            "    (aucun groupe dans le cache — les groupes actuels sont en mémoire Edge)"
        )

    print(f"\n  {'=' * 50}")
    print(f"  Total workspace caches: {len(workspaces)}")
    print(f"  Total tabs actifs CDP: {len(tabs)}")
    print(f"  {'=' * 50}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Edge Workspace Explorer")
    parser.add_argument(
        "--detail", action="store_true", help="Afficher les URLs complètes"
    )
    args = parser.parse_args()

    workspaces = get_edge_workspace_info()
    tabs = get_cdp_data("/json/list")

    if tabs is None:
        print(
            "❌ CDP :9222 non accessible — Edge est-il lancé avec --remote-debugging-port=9222 ?"
        )
        tabs = []
    else:
        # Filter to page-type targets only
        tabs = [t for t in tabs if t.get("type") == "page"]

    # Try to identify which workspace is active
    # The active workspace can be detected from the spaceworks page
    for tab in tabs:
        if "spaceworks" in tab.get("url", "") or "Workspaces" in tab.get("title", ""):
            for ws in workspaces:
                if "ACTIVE" in ws.get("flags", []):
                    ws["flags"].remove("ACTIVE")
        # Simple heuristic: last workspace modified in cache = might be active
    if workspaces:
        workspaces[-1]["flags"] = workspaces[-1].get("flags", []) + ["ACTIVE"]

    print_tree(workspaces, tabs, args.detail)
