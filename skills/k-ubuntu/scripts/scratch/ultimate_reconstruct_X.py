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

def ultimate_reconstruct():
    with open(source_file, 'r') as f:
        data = json.load(f)
    
    fluid_b64 = data.get("Fluid_Data", "")
    decoded = base64.b64decode(fluid_b64)
    
    # Get all strings (ASCII and UTF-16) with positions
    # We'll use a byte-by-byte scan for GUIDs and URLs
    
    # 1. Extract all GUIDs
    guids = []
    for match in re.finditer(rb'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', decoded):
        guids.append((match.group().decode(errors='ignore'), match.start()))
        
    # 2. Extract all URLs
    urls = []
    for match in re.finditer(rb'https?://[^\s\x00-\x1f"\'<>]+', decoded):
        urls.append((match.group().decode(errors='ignore'), match.start()))
        
    # 3. Extract all UTF-16 strings (titles)
    titles = []
    utf16_data = decoded.decode('utf-16', errors='ignore')
    for match in re.finditer(r'[\u0020-\u007E\u00A0-\u00FF]{5,100}', utf16_data):
        s = match.group().strip()
        if s and not s.startswith('http') and not re.match(r'[0-9a-f]{8}-', s.lower()):
            titles.append((s, match.start() * 2))

    # Track tab state: {tab_id: {url, title, group, pos}}
    # A Tab ID is a GUID that is NOT in FOLDER_MAP
    tabs = {}
    
    # Process the stream sequentially
    # We'll use a combined list of all events sorted by position
    events = []
    for g, p in guids: events.append(("guid", g, p))
    for u, p in urls: events.append(("url", u, p))
    for t, p in titles: events.append(("title", t, p))
    events.sort(key=lambda x: x[2])
    
    current_tab_id = None
    current_group_id = None
    
    for type, val, pos in events:
        if type == "guid":
            if val in FOLDER_MAP:
                current_group_id = val
            else:
                current_tab_id = val
                if current_tab_id not in tabs:
                    tabs[current_tab_id] = {"url": None, "title": None, "group": current_group_id, "pos": pos}
                else:
                    # Update group if it changed
                    tabs[current_tab_id]["group"] = current_group_id
                    tabs[current_tab_id]["pos"] = pos
        elif type == "url":
            if current_tab_id:
                tabs[current_tab_id]["url"] = val
                tabs[current_tab_id]["pos"] = pos
        elif type == "title":
            if current_tab_id:
                tabs[current_tab_id]["title"] = val
                tabs[current_tab_id]["pos"] = pos

    # Filter to active tabs (those that have a URL and are among the 103 most recent)
    # Also exclude noise URLs
    noise = ["accounts.google.com/ServiceLogin", "bing.com/search", "google.com/search"]
    
    active_list = []
    for tid, info in tabs.items():
        if info["url"]:
            # Skip noise
            if any(n in info["url"] for n in noise): continue
            active_list.append((tid, info))
            
    # Sort by position (most recent first) and take 103
    active_list.sort(key=lambda x: x[1]["pos"], reverse=True)
    final_tabs = active_list[:103]
    
    # Reconstruct the tree
    tree = {name: [] for name in FOLDER_MAP.values()}
    tree["Onglets Orphelins"] = []
    
    # Deduplicate by URL within the same group to keep it clean if multiple sessions exist
    seen_in_group = {} # (url, group) -> bool
    
    for tid, info in final_tabs:
        group_id = info["group"]
        group_name = FOLDER_MAP.get(group_id, "Onglets Orphelins")
        
        url = info["url"]
        title = info.get("title") or url.split('/')[-1] or url
        
        # Simple deduplication
        key = (url, group_name)
        if key in seen_in_group: continue
        seen_in_group[key] = True
        
        tree[group_name].append(f"- [{title}]({url})")

    # Output to Markdown
    with open("/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture_tree.md", "w") as f:
        f.write("# Arborescence du Workspace X\n")
        f.write("> État reconstruit à partir de la sauvegarde du 03/05/2026 à 22:49\n\n")
        
        # Display folders first
        for group in FOLDER_MAP.values():
            items = tree[group]
            if items:
                f.write(f"## 📁 {group}\n")
                for item in items:
                    f.write(f"{item}\n")
                f.write("\n")
        
        # Then orphelins
        if tree["Onglets Orphelins"]:
            f.write(f"## 📄 Onglets Orphelins\n")
            for item in tree["Onglets Orphelins"]:
                f.write(f"{item}\n")
            f.write("\n")

if __name__ == "__main__":
    ultimate_reconstruct()
