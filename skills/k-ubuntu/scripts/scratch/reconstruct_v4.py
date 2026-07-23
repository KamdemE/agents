import json
import re

# Paths
dump_path = "/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/fluid_strings_dump.txt"

def reconstruct_v4():
    # 1. Known Group GUIDs
    known_groups = {
        "34077382-ee9d-416d-b615-eedd1ac775d3": "Formel", # Actually looking at tabs, it's admin/mail
        "6ffce2f6-d97d-490a-bd91-0ffc576916f5": "Formel", # The dump says Formel follows this
        "391e4626-1d06-4cb5-bce1-5a869ce951e3": "Internships",
        "6cf7a5f1-a73f-484e-8a27-eeeef9ae794b": "Anglais",
        "a7047795-9819-4365-b169-d28ed08e0f05": "PSC",
        "2cc47188-d4e5-4a25-acdd-a842e1a7fe43": "Analyse fonctionnelle",
        "c8cab1c6-96fc-4cd2-be30-b767110c8b23": "IME-43031-EP",
        "0deaae04-4ecc-4c8c-b074-dcf78b051611": "Algos pour l'analyse de données en Python",
        "51e61898-f841-41a2-b46b-79daca9ef756": "Optimisation & Controle"
    }
    
    # Actually, the user says "folders and tabs inside". 
    # Let's map folders by the names found in the master list.
    group_ids = set(known_groups.keys())
    
    with open(dump_path, "r") as f:
        lines = [line.strip() for line in f]
    
    tree = {}
    current_group = "Root"
    
    # Heuristic: 
    # [Tab ID GUID]
    # [Group ID GUID]
    # [URL]
    # [Title]
    
    i = 0
    seen_tabs = set()
    
    while i < len(lines):
        line = lines[i]
        
        # Is it a Group ID?
        if line in group_ids:
            # We don't necessarily change current_group here, 
            # because the Group ID often appears as the PARENT of the next tab.
            pass
            
        # Is it a URL?
        if line.startswith("http") and not line.endswith(".ico") and "favicon" not in line:
            # Look at the line BEFORE it. Is it a Group ID?
            potential_group = lines[i-1] if i > 0 else None
            potential_tab_id = lines[i-2] if i > 1 else None
            
            if potential_group in group_ids:
                group_name = known_groups[potential_group]
                if group_name not in tree:
                    tree[group_name] = []
                
                # Title is usually the next line
                title = lines[i+1] if i+1 < len(lines) else "Untitled"
                
                tab_key = (line, title)
                if tab_key not in seen_tabs:
                    tree[group_name].append({"title": title, "url": line})
                    seen_tabs.add(tab_key)
            elif potential_tab_id in group_ids:
                 # Sometimes they are swapped?
                 group_name = known_groups[potential_tab_id]
                 if group_name not in tree:
                     tree[group_name] = []
                 title = lines[i+1] if i+1 < len(lines) else "Untitled"
                 tab_key = (line, title)
                 if tab_key not in seen_tabs:
                    tree[group_name].append({"title": title, "url": line})
                    seen_tabs.add(tab_key)
            else:
                # Orphan tab
                if "Orphans" not in tree:
                    tree["Orphans"] = []
                title = lines[i+1] if i+1 < len(lines) else "Untitled"
                tab_key = (line, title)
                if tab_key not in seen_tabs:
                    tree["Orphans"].append({"title": title, "url": line})
                    seen_tabs.add(tab_key)
        
        i += 1
        
    # Generate Output
    output = []
    output.append("📁 Espace de Travail X")
    
    # Sort folders (Orphans last)
    folders = sorted([f for f in tree.keys() if f != "Orphans"])
    
    for folder in folders:
        output.append(f"    ├── 📁 {folder}")
        tabs = tree[folder]
        for j, tab in enumerate(tabs):
            connector = "└── " if j == len(tabs) - 1 else "├── "
            output.append(f"    │   {connector}📄 {tab['title']} ({tab['url'][:60]}...)")
            
    if "Orphans" in tree and tree["Orphans"]:
        output.append("    └── 📁 Onglets Orphelins")
        for j, tab in enumerate(tree["Orphans"]):
            connector = "└── " if j == len(tree["Orphans"]) - 1 else "├── "
            output.append(f"        {connector}📄 {tab['title']} ({tab['url'][:60]}...)")
            
    return "\n".join(output)

if __name__ == "__main__":
    res = reconstruct_v4()
    with open("/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture_tree.md", "w") as f:
        f.write("# Architecture du Workspace X (Session 22:49)\n\n")
        f.write("```text\n")
        f.write(res)
        f.write("\n```\n")
    print("Done.")
