import json
import base64
import os
import re

# Paths
workspace_id = "2711dd14-9022-4f80-9c7d-2f069f218f2c"
backup_root = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default"
cache_path = os.path.join(backup_root, f"Workspaces/workspace_cache_{workspace_id}")

def get_fluid_data():
    with open(cache_path, 'r') as f:
        data = json.load(f)
    fluid_b64 = data.get("Fluid_Data", "")
    return base64.b64decode(fluid_b64)

def reconstruct():
    fluid_bytes = get_fluid_data()
    # Decode with ignore to handle binary markers
    content = fluid_bytes.decode('utf-8', 'ignore')
    
    # Group GUIDs from JSON
    with open(cache_path, 'r') as f:
        cache_json = json.load(f)
    group_guids = list(cache_json.get("Tab_Group_Collapsed_States", {}).keys())
    
    # 1. Map Group GUIDs to Names
    # We found these mappings in previous steps
    known_mappings = {
        "6ffce2f6-d97d-490a-bd91-0ffc576916f5": "Formel",
        "391e4626-1d06-4cb5-bce1-5a869ce951e3": "Internships",
        "6cf7a5f1-a73f-484e-8a27-eeeef9ae794b": "Anglais",
        "a7047795-9819-4365-b169-d28ed08e0f05": "PSC",
        "c8cab1c6-96fc-4cd2-be30-b767110c8b23": "Algos pour l'analyse de données en Python",
        "0deaae04-4ecc-4c8c-b074-dcf78b051611": "Optimisation & Controle",
        "2cc47188-d4e5-4a25-acdd-a842e1a7fe43": "IME-43031-EP",
        "a7047795-9819-4365-b169-d28ed08e0f05": "Analyse fonctionnelle" # Wait, I saw both labels. Let's re-check.
    }
    
    # Let's refine mapping by searching around GUIDs in content
    refined_map = {}
    for gid in group_guids:
        pos = content.find(gid)
        if pos != -1:
            # Look ahead for a label (string of 3-50 chars)
            # Usually the label follows the GUID after some markers
            segment = content[pos:pos+300]
            # Search for known labels first
            found = False
            for label in ["Formel", "Internships", "Anglais", "PSC", "Analyse fonctionnelle", 
                          "IME-43031-EP", "Algos pour l'analyse de données en Python", "Optimisation & Controle"]:
                if label in segment:
                    refined_map[gid] = label
                    found = True
                    break
            if not found:
                # Try to extract a potential label (text after GUID)
                m = re.search(r'[^\x00-\x1f\x7f-\xff]{3,30}', content[pos+36:pos+200])
                if m:
                    refined_map[gid] = m.group().strip()
    
    # 2. Extract Tabs (URL + Title)
    # Tabs are clusters: [TabGUID] [URL] [Title] [ParentGroupGUID]
    # In Fluid, parentId is often near the tab data.
    
    # Find all URLs
    url_pattern = re.compile(r'https?://[^\s\x00-\x1f\x7f-\xff<>"]+')
    matches = list(url_pattern.finditer(content))
    
    tabs = []
    seen_urls = set()
    
    for i, m in enumerate(matches):
        url = m.group()
        if url.endswith(".ico") or "favicon" in url: continue
        if url in seen_urls: continue
        seen_urls.add(url)
        
        start = m.start()
        end = m.end()
        
        # Title is usually the next string
        after = content[end:end+300]
        title_match = re.search(r'([^\x00-\x1f\x7f-\xff]{4,100})', after)
        title = title_match.group(1).strip() if title_match else "Untitled"
        
        # Parent Group GUID: Search lookback and lookahead for a Group GUID
        # We'll check the nearest 500 chars
        lookback = content[max(0, start-500):start]
        lookahead = content[end:end+500]
        
        parent_gid = None
        # Closest lookback is usually better for parentId in some serialization formats
        closest_dist = 9999
        for gid in refined_map.keys():
            # Check lookback (reversed search to find closest)
            lb_pos = lookback.rfind(gid)
            if lb_pos != -1:
                dist = len(lookback) - lb_pos
                if dist < closest_dist:
                    closest_dist = dist
                    parent_gid = gid
            
            # Check lookahead
            la_pos = lookahead.find(gid)
            if la_pos != -1:
                dist = la_pos
                if dist < closest_dist:
                    closest_dist = dist
                    parent_gid = gid
        
        tabs.append({
            "url": url,
            "title": title,
            "parent_gid": parent_gid
        })
    
    # 3. Organize into Tree
    tree = {
        "name": "Espace de Travail X",
        "folders": {}
    }
    orphans = []
    
    # Filter folders that actually have tabs or are in our refined map
    active_folders = {}
    for gid, name in refined_map.items():
        active_folders[gid] = {"name": name, "tabs": []}
        
    for tab in tabs:
        gid = tab["parent_gid"]
        if gid and gid in active_folders:
            active_folders[gid]["tabs"].append(tab)
        else:
            orphans.append(tab)
            
    # Remove empty folders except if they are core ones
    final_folders = []
    for gid, folder in active_folders.items():
        if folder["tabs"]:
            final_folders.append(folder)
            
    # Sort folders by name
    final_folders.sort(key=lambda x: x["name"])
    
    # 4. Generate Output
    output = []
    output.append("📁 Espace de Travail X")
    
    for folder in final_folders:
        output.append(f"    ├── 📁 {folder['name']}")
        for i, tab in enumerate(folder["tabs"]):
            connector = "└── " if i == len(folder["tabs"]) - 1 else "├── "
            output.append(f"    │   {connector}📄 {tab['title']} ({tab['url'][:60]}...)")
            
    if orphans:
        output.append("    └── 📁 Onglets Orphelins")
        for i, tab in enumerate(orphans):
            connector = "└── " if i == len(orphans) - 1 else "├── "
            output.append(f"        {connector}📄 {tab['title']} ({tab['url'][:60]}...)")
            
    return "\n".join(output)

if __name__ == "__main__":
    res = reconstruct()
    with open("/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture_tree.md", "w") as f:
        f.write("# Architecture du Workspace X (Session 22:49)\n\n")
        f.write("```text\n")
        f.write(res)
        f.write("\n```\n")
    print("Done.")
