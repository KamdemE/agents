import json
import base64
import re
import os

# Paths
backup_root = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default"
bookmarks_path = os.path.join(backup_root, "Bookmarks")
workspace_id = "2711dd14-9022-4f80-9c7d-2f069f218f2c"
cache_path = os.path.join(backup_root, f"Workspaces/workspace_cache_{workspace_id}")

def find_node_by_id(node, node_id):
    if str(node.get("id")) == str(node_id):
        return node
    if "children" in node:
        for child in node["children"]:
            found = find_node_by_id(child, node_id)
            if found:
                return found
    return None

def format_tree_node(node, prefix="", is_last=True):
    if not node:
        return ["*(Empty or Missing)*"]
    
    name = node.get("name", "Unnamed")
    node_type = node.get("type", "unknown")
    url = node.get("url", "")
    
    char = "└── " if is_last else "├── "
    icon = "📁" if node_type == "folder" else "📄"
    
    # Clean name for display if it's a long URL
    display_name = name
    if node_type == "url" and len(name) > 80:
        display_name = name[:77] + "..."
    
    label = f"[{display_name}]({url})" if url else f"**{display_name}**"
    line = f"{prefix}{char}{icon} {label}"
    
    result = [line]
    
    children = node.get("children", [])
    new_prefix = prefix + ("    " if is_last else "│   ")
    for i, child in enumerate(children):
        result.extend(format_tree_node(child, new_prefix, i == len(children) - 1))
    
    return result

# 1. Load Bookmarks and extract Folder X
print("Loading Bookmarks...")
with open(bookmarks_path, 'r') as f:
    bookmarks_data = json.load(f)

# Search in all roots
folder_x = None
for root in bookmarks_data["roots"].values():
    folder_x = find_node_by_id(root, "774")
    if folder_x: break

if not folder_x:
    print("Warning: Folder X (ID 774) not found in Bookmarks. Searching by name...")
    for root in bookmarks_data["roots"].values():
        folder_x = find_node_by_id(root, name="X") # Need to fix find_node
        if folder_x: break

# 2. Load Workspace Cache and extract Tabs
print("Loading Workspace Cache...")
if os.path.exists(cache_path):
    with open(cache_path, 'r') as f:
        cache_data = json.load(f)
    
    fluid_b64 = cache_data.get("Fluid_Data", "")
    fluid_bytes = base64.b64decode(fluid_b64)
    fluid_str = fluid_bytes.decode('utf-8', 'replace')
    
    # Extract URLs
    url_pattern = re.compile(r'https?://[^\s\x00-\x1f\x7f-\xff<>"]+')
    urls = url_pattern.findall(fluid_str)
    
    unique_urls = []
    seen = set()
    for u in urls:
        if u.endswith(".ico") or "favicon" in u: continue
        if u not in seen:
            unique_urls.append(u)
            seen.add(u)
else:
    print(f"Error: Cache file not found at {cache_path}")
    unique_urls = []

# 3. Categorize active tabs
print("Categorizing tabs...")
active_session_node = {
    "name": "Active Session (Tabs)",
    "type": "folder",
    "children": []
}

themes = {
    "Academic (Moodle/Poly)": ["moodle", "polytechnique", "synapses", "gargantua", "pegase"],
    "Admin (CAF/Ameli/Impots)": ["caf.fr", "ameli.fr", "impots.gouv.fr", "france-identite"],
    "Communication (Zimbra/Gmail)": ["webmail", "gmail", "zimbra", "outlook"],
    "Career (Job Board/LinkedIn)": ["jobteaser", "linkedin", "jobboard", "recrutement", "welcome-to-the-jungle"],
    "Binet (Labs/Stratus)": ["binet", "gitlab", "stratus", "photo"],
}

theme_groups = {name: {"name": name, "type": "folder", "children": []} for name in themes}
orphans = []

for url in unique_urls:
    assigned = False
    for theme_name, keywords in themes.items():
        if any(kw in url.lower() for kw in keywords):
            theme_groups[theme_name]["children"].append({"name": url, "type": "url", "url": url})
            assigned = True
            break
    if not assigned:
        orphans.append({"name": url, "type": "url", "url": url})

for group in theme_groups.values():
    if group["children"]:
        active_session_node["children"].append(group)

if orphans:
    active_session_node["children"].append({"name": "Uncategorized Tabs", "type": "folder", "children": orphans})

# 4. Generate Final Markdown
output_path = "/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture_tree.md"
print(f"Generating tree at {output_path}...")
with open(output_path, 'w') as f:
    f.write("# Architectural View: Workspace X\n\n")
    f.write("This document presents a unified tree-like architecture of Workspace X, including both bookmarked resources and active session tabs.\n\n")
    
    # We create a virtual root to show everything
    workspace_root = {
        "name": "Workspace X (Overview)",
        "type": "folder",
        "children": [
            {
                "name": "Stored Resources (Bookmarks)",
                "type": "folder",
                "children": folder_x.get("children", []) if folder_x else []
            },
            active_session_node
        ]
    }
    
    tree_lines = format_tree_node(workspace_root, "", True)
    f.write("\n".join(tree_lines))
    f.write("\n\n---\n*Generated by Antigravity Analysis System*")

print("Done.")
