import re
import json
import base64

source_file = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"

FOLDER_MAP = {
    "391e4626-1d06-4cb5-bce1-5a869ce951e3": "Formel",
    "6cf7a5f1-a73f-484e-8a27-eeeef9ae794b": "Internships",
    "a7047795-9819-4365-b169-d28ed08e0f05": "Anglais",
    "c8cab1c6-96fc-4cd2-be30-b767110c8b23": "Analyse fonctionnelle",
    "0deaae04-4ecc-4c8c-b074-dcf78b051611": "IME-43031-EP",
    "51e61898-f841-41a2-b46b-79daca9ef756": "Algos pour l'analyse de données en Python",
    "8ba59244-1a5e-4ba6-8131-df54c9959900": "Optimation & Controle"
}

def smart_reconstruct():
    with open(source_file, 'r') as f:
        data = json.load(f)
    
    fluid_b64 = data.get("Fluid_Data", "")
    decoded = base64.b64decode(fluid_b64)
    
    # Decoded content as strings (ASCII and UTF-16)
    content_ascii = decoded.decode('ascii', errors='ignore')
    content_utf16 = decoded.decode('utf-16', errors='ignore')
    
    # We want to track the state of each TAB ID
    # State: {id: {url, title, group, timestamp_pos}}
    tab_states = {}
    
    # GUID pattern
    guid_pattern = re.compile(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
    
    # Find all GUID occurrences with their positions
    all_guids = []
    for match in guid_pattern.finditer(content_ascii):
        all_guids.append((match.group(), match.start()))
    
    # Scan the file and build state
    # This is tricky because we don't know the exact binary format.
    # We'll use a sliding window/proximity heuristic.
    
    # Let's find URLs and Titles first
    url_pattern = re.compile(r'https?://[^\s\x00-\x1f"\'<>]+')
    urls = []
    for match in url_pattern.finditer(content_ascii):
        urls.append((match.group(), match.start()))
    
    # Title pattern (UTF-16) - Titles are usually followed by a lot of nulls or preceded by them
    # We'll just look for non-URL strings in UTF-16
    titles = []
    # Simplified: look for strings in content_utf16 that look like titles
    # Titles are usually between 5 and 100 chars
    for match in re.finditer(r'[\u0020-\u007E\u00A0-\u00FF]{5,100}', content_utf16):
        s = match.group().strip()
        if s and not s.startswith('http') and not guid_pattern.match(s.lower()):
            titles.append((s, match.start() * 2)) # back to byte offset
            
    # Now, associate URLs with the nearest PRECEDING GUID that is NOT a folder GUID
    for url, pos in urls:
        best_guid = None
        for g, gpos in reversed(all_guids):
            if gpos < pos and g not in FOLDER_MAP:
                best_guid = g
                break
        
        if best_guid:
            if best_guid not in tab_states: tab_states[best_guid] = {"url": None, "title": None, "group": None, "pos": gpos}
            tab_states[best_guid]["url"] = url
            # Update position to the latest one
            tab_states[best_guid]["pos"] = max(tab_states[best_guid]["pos"], pos)

    # Associate Groups with the nearest PRECEDING GUID (the tab ID)
    for g, pos in all_guids:
        if g in FOLDER_MAP:
            # This is a group assignment
            # Find the tab ID it belongs to. Usually the tab ID is just before.
            best_tab = None
            for tg, tgpos in reversed(all_guids):
                if tgpos < pos and tg not in FOLDER_MAP:
                    best_tab = tg
                    break
            if best_tab and best_tab in tab_states:
                tab_states[best_tab]["group"] = g

    # Filter: Only keep tabs that have a URL
    active_tabs = {k: v for k, v in tab_states.items() if v["url"]}
    
    # The user says there are 103 tabs.
    # Let's see how many unique Tab GUIDs we have now.
    print(f"Found {len(active_tabs)} unique Tab GUIDs with URLs.")
    
    # If we have too many, we take the 103 with the LATEST positions (most recent activity)
    sorted_tabs = sorted(active_tabs.items(), key=lambda x: x[1]["pos"], reverse=True)
    final_tabs = sorted_tabs[:103]
    
    # Reconstruct the tree
    tree = {name: [] for name in FOLDER_MAP.values()}
    tree["Orphelins"] = []
    
    for tid, info in final_tabs:
        group_name = FOLDER_MAP.get(info["group"], "Orphelins")
        # Clean URL/Title (titles are hard to get accurately without better parsing)
        # We'll use the URL as a placeholder for the title if missing
        display_name = info["url"].split('/')[-1] or info["url"]
        tree[group_name].append(f"- [{display_name}]({info['url']})")
    
    # Output to Markdown
    with open("/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture_tree.md", "w") as f:
        f.write("# Architecture du Workspace X (22:49)\n\n")
        for group, items in tree.items():
            if items:
                f.write(f"## {group}\n")
                for item in items:
                    f.write(f"{item}\n")
                f.write("\n")

if __name__ == "__main__":
    smart_reconstruct()
