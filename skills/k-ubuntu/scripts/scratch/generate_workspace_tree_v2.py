import json
import base64
import os
import re

# Paths
backup_root = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default"
bookmarks_path = os.path.join(backup_root, "Bookmarks")
workspace_id = "2711dd14-9022-4f80-9c7d-2f069f218f2c"
cache_path = os.path.join(backup_root, f"Workspaces/workspace_cache_{workspace_id}")

def get_fluid_data():
    if not os.path.exists(cache_path):
        return None
    with open(cache_path, 'r') as f:
        data = json.load(f)
    fluid_b64 = data.get("Fluid_Data", "")
    return base64.b64decode(fluid_b64)

def extract_workspace_tree():
    fluid_bytes = get_fluid_data()
    if not fluid_bytes:
        return "Cache file not found."
    
    fluid_str = fluid_bytes.decode('utf-8', 'ignore')
    
    # Extract GUID-Name mappings for groups
    # We saw names like "Fr", "Former", etc. in the binary
    # Usually they follow a GUID and some metadata
    
    # Let's find all GUIDs first
    guid_pattern = re.compile(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
    
    # We also have the group IDs from the JSON itself (collapsed states)
    with open(cache_path, 'r') as f:
        cache_json = json.load(f)
    group_ids = list(cache_json.get("Tab_Group_Collapsed_States", {}).keys())
    
    # Map group IDs to names by looking in the fluid string
    group_map = {}
    for gid in group_ids:
        # Search for the GUID in the fluid string and look for a nearby short string (the name)
        pos = fluid_str.find(gid)
        if pos != -1:
            # Look ahead for the name. It's usually a short string preceded by a length byte or similar.
            # For simplicity, we'll search for the names we saw earlier.
            known_names = ["Fr", "Former", "Internships", "Anglais", "PSC", "Analyse fonctionnelle", 
                           "IME-43031-EP", "Algos pour l'analyse de données en Python", "Optimisation & Controle"]
            for name in known_names:
                # Check if the name appears within 100 chars of the GUID
                if name in fluid_str[pos:pos+200]:
                    group_map[gid] = name
                    break
            if gid not in group_map:
                group_map[gid] = f"Group_{gid[:8]}"

    # Extract tabs
    # Each tab has: TabGUID, ParentGroupGUID, URL, Title
    # It's hard to parse perfectly without the full Fluid schema, but we can use proximity.
    
    # Pattern: [TabGUID] ... [GroupGUID] ... [URL] ... [Title]
    # Actually, it seems GroupGUID often precedes the URL of its tabs.
    
    tabs = []
    # Split by URL to find tab blocks
    url_pattern = re.compile(r'https?://[^\s\x00-\x1f\x7f-\xff<>"]+')
    
    # Find all occurrences of URLs and their titles
    # Titles usually follow the URL
    matches = list(url_pattern.finditer(fluid_str))
    for i, m in enumerate(matches):
        url = m.group()
        if url.endswith(".ico") or "favicon" in url: continue
        
        start = m.end()
        # The title is usually the next string
        # We look for a string that doesn't look like a URL or GUID
        remaining = fluid_str[start:start+200]
        # Titles often end with a newline or null or special char in the decoded output
        title_match = re.search(r'([^\x00-\x1f\x7f-\xff]{5,100})', remaining)
        title = title_match.group(1).strip() if title_match else url
        
        # Now find the nearest preceding Group GUID
        lookback = fluid_str[max(0, m.start()-500):m.start()]
        parent_gid = None
        for gid in group_ids:
            if gid in lookback:
                parent_gid = gid
                # Don't break, find the *closest* one
        
        tabs.append({
            "url": url,
            "title": title,
            "group_id": parent_gid
        })

    # Build the tree
    tree = {
        "name": "Workspace X",
        "type": "folder",
        "children": []
    }
    
    # Add groups
    groups_nodes = {}
    for gid, name in group_map.items():
        node = {"name": name, "type": "folder", "children": []}
        groups_nodes[gid] = node
        tree["children"].append(node)
        
    # Add tabs to groups or root (orphans)
    orphans = []
    seen_urls = set()
    for tab in tabs:
        if tab["url"] in seen_urls: continue
        seen_urls.add(tab["url"])
        
        node = {"name": tab["title"], "type": "url", "url": tab["url"]}
        if tab["group_id"] and tab["group_id"] in groups_nodes:
            groups_nodes[tab["group_id"]]["children"].append(node)
        else:
            orphans.append(node)
            
    if orphans:
        tree["children"].append({"name": "Orphaned Tabs", "type": "folder", "children": orphans})
        
    return tree

def format_tree_ascii(node, prefix="", is_last=True):
    # This function generates a clean tree string
    connector = "└── " if is_last else "├── "
    icon = "📁 " if node["type"] == "folder" else "📄 "
    
    name = node["name"]
    url = node.get("url", "")
    
    # Clean up name if it's a GUID
    if name.startswith("Group_") and len(name) > 14:
        name = name[:14] + "..."
        
    line = f"{prefix}{connector}{icon}{name}"
    if url:
        line += f" ({url[:60]}...)"
    
    lines = [line]
    
    children = node.get("children", [])
    new_prefix = prefix + ("    " if is_last else "│   ")
    for i, child in enumerate(children):
        lines.extend(format_tree_ascii(child, new_prefix, i == len(children)-1))
    return lines

# Build the tree
tree_data = extract_workspace_tree()

if isinstance(tree_data, dict):
    # Sort children: Folders first, then Orphans at the end
    folders = [c for c in tree_data["children"] if c["name"] != "Orphaned Tabs"]
    orphans = [c for c in tree_data["children"] if c["name"] == "Orphaned Tabs"]
    
    # Reassemble with orphans last
    tree_data["children"] = folders + orphans
    
    # Translate labels to French
    if tree_data["name"] == "Workspace X":
        tree_data["name"] = "Espace de Travail X"
    for child in tree_data["children"]:
        if child["name"] == "Orphaned Tabs":
            child["name"] = "Onglets Orphelins (Hors Groupes)"

    output_lines = format_tree_ascii(tree_data)
    
    with open("/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture_tree.md", "w") as f:
        f.write("# Architecture du Workspace X\n\n")
        f.write("```text\n")
        f.write("\n".join(output_lines))
        f.write("\n```\n\n")
        f.write("---\n*Généré par Antigravity - Extraction heuristique des données Fluid*")
    print("Tree generated in scratch/workspace_x_architecture_tree.md")
else:
    print(tree_data)
