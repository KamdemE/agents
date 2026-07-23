import json
import base64
import re
import os

# Source path from the 22:49 stage
source_file = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"
scratch_dir = "/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch"

def final_reconstruct():
    # 1. Load metadata to get all potential group GUIDs
    with open(source_file, 'r') as f:
        data = json.load(f)
    
    group_guids = set(data.get("Tab_Group_Collapsed_States", {}).keys())
    fluid_b64 = data.get("Fluid_Data", "")
    decoded = base64.b64decode(fluid_b64)
    
    # 2. Extract all strings (ASCII and UTF-16)
    # We use a regex that matches both
    all_strings = []
    # ASCII
    all_strings += re.findall(r'[\x20-\x7E]{4,}', decoded.decode('ascii', errors='ignore'))
    # UTF-16 (simplified search)
    utf16_strings = re.findall(b'(?:[\x20-\x7E]\x00){4,}', decoded)
    for s in utf16_strings:
        all_strings.append(s.decode('utf-16le', errors='ignore'))
        
    # 3. First pass: Map GUIDs to Names
    # We look for strings that appear right after a GUID and are not URLs
    group_names = {}
    for i, s in enumerate(all_strings):
        if s in group_guids:
            # Look ahead for a name
            for j in range(1, 5):
                if i + j < len(all_strings):
                    candidate = all_strings[i+j].strip()
                    if candidate and not candidate.startswith("http") and not candidate in group_guids and len(candidate) > 2:
                        # Heuristic: short names or specific patterns
                        if j == 1 or not group_names.get(s):
                            group_names[s] = candidate
                        break

    # Manual overrides for known groups if detection fails or is messy
    overrides = {
        "34077382-ee9d-416d-b615-eedd1ac775d3": "Perso / Administratif",
        "6ffce2f6-d97d-490a-bd91-0ffc576916f5": "Formel",
        "391e4626-1d06-4cb5-bce1-5a869ce951e3": "Internships",
        "6cf7a5f1-a73f-484e-8a27-eeeef9ae794b": "Anglais",
        "a7047795-9819-4365-b169-d28ed08e0f05": "PSC",
        "2cc47188-d4e5-4a25-acdd-a842e1a7fe43": "Analyse fonctionnelle",
        "c8cab1c6-96fc-4cd2-be30-b767110c8b23": "IME-43031-EP",
        "0deaae04-4ecc-4c8c-b074-dcf78b051611": "Algos pour l'analyse de données",
        "51e61898-f841-41a2-b46b-79daca9ef756": "Optimisation & Controle"
    }
    group_names.update(overrides)

    # 4. Second pass: Reconstruct tabs
    # We map each URL to its LATEST seen parent group
    final_tabs = {} # URL -> (Title, GroupName)
    current_group = None
    
    for i, s in enumerate(all_strings):
        if s in group_guids:
            current_group = group_names.get(s, s)
            continue
            
        if s.startswith("http") and not any(x in s for x in [".ico", "favicon", "google-analytics", "doubleclick"]):
            url = s
            title = "Untitled"
            # Look for title near the URL
            if i + 1 < len(all_strings) and not all_strings[i+1].startswith("http") and all_strings[i+1] not in group_guids:
                title = all_strings[i+1]
            elif i - 1 >= 0 and not all_strings[i-1].startswith("http") and all_strings[i-1] not in group_guids:
                title = all_strings[i-1]
            
            # Clean title
            title = re.sub(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', '', title).strip()
            
            # Store/Update (Latest wins)
            final_tabs[url] = (title, current_group)

    # 5. Build Hierarchy
    hierarchy = {}
    for url, (title, group) in final_tabs.items():
        if not group: group = "Orphelins"
        if group not in hierarchy: hierarchy[group] = []
        hierarchy[group].append({"title": title, "url": url})

    # 6. Generate Markdown
    output = []
    output.append("# Architecture du Workspace X (Sauvegarde 22:49)")
    output.append("\n> Source: `stage_2026-05-03_22-49-33`")
    output.append(f"> Total Unique Tabs found: {len(final_tabs)}")
    output.append("\n```text")
    output.append("📁 Workspace X")
    
    # Sort folders: named first, then orphans
    folders = sorted([f for f in hierarchy.keys() if f != "Orphelins"])
    if "Orphelins" in hierarchy: folders.append("Orphelins")
    
    for folder in folders:
        tabs = hierarchy[folder]
        # Filter orphans to reduce noise
        if folder == "Orphelins":
            tabs = [t for t in tabs if "google.com/search" not in t["url"] and "bing.com" not in t["url"]]
            if not tabs: continue
            
        output.append(f"├── 📁 {folder}")
        for j, tab in enumerate(tabs):
            connector = "└── " if j == len(tabs) - 1 else "├── "
            # Truncate title and URL for display
            t_disp = tab["title"][:50]
            u_disp = tab["url"]
            if len(u_disp) > 80: u_disp = u_disp[:77] + "..."
            output.append(f"│   {connector}📄 {t_disp} ({u_disp})")
            
    output.append("```")
    
    return "\n".join(output)

if __name__ == "__main__":
    result = final_reconstruct()
    output_md = os.path.join(scratch_dir, "workspace_x_architecture_tree.md")
    with open(output_md, "w") as f:
        f.write(result)
    print(f"Tree generated at {output_md}")
