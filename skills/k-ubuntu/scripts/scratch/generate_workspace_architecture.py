import json
import base64
import re
import os

def build_bookmarks_tree(node, level=0):
    lines = []
    indent = "  " * level
    if node.get("type") == "folder":
        lines.append(f"{indent}📁 **{node['name']}**")
        for child in node.get("children", []):
            lines.extend(build_bookmarks_tree(child, level + 1))
    elif node.get("type") == "url":
        lines.append(f"{indent}📄 [{node['name']}]({node['url']})")
    return lines

# Configuration
backup_root = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default"
bookmarks_path = os.path.join(backup_root, "Bookmarks")
cache_path = os.path.join(backup_root, "Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c")

# 1. Bookmarks Tree for "X"
with open(bookmarks_path, 'r') as f:
    bookmarks_data = json.load(f)

# Find folder "X" (ID 774)
def find_node(node, node_id):
    if node.get("id") == node_id:
        return node
    if "children" in node:
        for child in node["children"]:
            found = find_node(child, node_id)
            if found:
                return found
    return None

folder_x = None
for root_name in bookmarks_data["roots"]:
    folder_x = find_node(bookmarks_data["roots"][root_name], "774")
    if folder_x:
        break

bookmarks_tree = build_bookmarks_tree(folder_x) if folder_x else ["Folder X not found in Bookmarks."]

# 2. Workspace Tabs and Groups
with open(cache_path, 'r') as f:
    cache_data = json.load(f)

group_metadata = cache_data.get("Tab_Group_Metadata", {})
fluid_b64 = cache_data.get("Fluid_Data", "")
fluid_bytes = base64.b64decode(fluid_b64)
fluid_str = fluid_bytes.decode('utf-8', 'ignore')

# Extract Tab Groups
# format in metadata: GUID: {"color": N, "title": "Name"}
groups = {}
for guid, meta in group_metadata.items():
    groups[guid] = {"title": meta.get("title", "Untitled Group"), "tabs": []}

# Extract Tabs heuristically
# We search for sequences of (URL, Title, TabGUID, GroupGUID)
# But since the group ID is hard to find reliably, we will use the Titles/URLs to assign groups
# based on keywords from group titles.

# Extract all (URL, Title) pairs first
tab_pairs = []
url_pattern = re.compile(r'https?://[^\s\x00-\x1f\x7f-\xff<>"]+')
# Extract urls and the string immediately after them (potential title)
urls = url_pattern.findall(fluid_str)
unique_urls = []
seen = set()
for u in urls:
    if u not in seen:
        unique_urls.append(u)
        seen.add(u)

# Assign tabs to groups
orphans = []
for url in unique_urls:
    assigned = False
    # Heuristic: Find if any group title is in the URL or the nearby strings
    # We can also check the context of the URL in the binary
    for guid, info in groups.items():
        title = info["title"].lower()
        # Exception for short titles
        if len(title) < 3: continue 
        
        if title in url.lower():
            info["tabs"].append(url)
            assigned = True
            break
    
    if not assigned:
        orphans.append(url)

# 3. Generate Final Markdown
with open("/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture.md", "w") as f:
    f.write("# Architecture de Workspace X\n\n")
    
    f.write("## 1. Arborescence des Favoris (Dossier X)\n")
    f.write("\n".join(bookmarks_tree))
    f.write("\n\n")
    
    f.write("## 2. Sessions Actives (Onglets et Groupes)\n\n")
    
    for guid, info in groups.items():
        f.write(f"### 📦 Groupe : {info['title']}\n")
        if not info["tabs"]:
            f.write("*(Aucun onglet détecté par heuristique)*\n")
        else:
            for tab_url in info["tabs"]:
                f.write(f"- 🔗 {tab_url}\n")
        f.write("\n")
    
    f.write("### 📄 Onglets Orphelins\n")
    for tab_url in orphans:
        f.write(f"- 🔗 {tab_url}\n")

print("Architecture generated: /home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture.md")
