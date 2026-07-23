import json
import re

# Paths
dump_path = "/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/fluid_strings_dump.txt"

def reconstruct_v5():
    # Final Mapping based on deep analysis of strings dump
    group_map = {
        "34077382-ee9d-416d-b615-eedd1ac775d3": "Perso / Administratif",
        "6ffce2f6-d97d-490a-bd91-0ffc576916f5": "Formel (Zimbra)",
        "391e4626-1d06-4cb5-bce1-5a869ce951e3": "Internships",
        "6cf7a5f1-a73f-484e-8a27-eeeef9ae794b": "Anglais",
        "a7047795-9819-4365-b169-d28ed08e0f05": "PSC (Envision)",
        "2cc47188-d4e5-4a25-acdd-a842e1a7fe43": "Analyse fonctionnelle",
        "c8cab1c6-96fc-4cd2-be30-b767110c8b23": "IME-43031-EP",
        "0deaae04-4ecc-4c8c-b074-dcf78b051611": "Algos pour l'analyse de données en Python",
        "51e61898-f841-41a2-b46b-79daca9ef756": "Optimisation & Controle"
    }
    
    group_ids = set(group_map.keys())
    
    with open(dump_path, "r") as f:
        lines = [line.strip() for line in f]
    
    tree = {name: [] for name in group_map.values()}
    tree["Orphelins"] = []
    
    seen_urls = set()
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Check for URL
        if line.startswith("http") and not line.endswith(".ico") and "favicon" not in line and "google-analytics" not in line:
            # We look back up to 5 lines for a Group GUID
            parent_gid = None
            for j in range(1, 6):
                if i - j >= 0:
                    prev = lines[i-j]
                    if prev in group_ids:
                        parent_gid = prev
                        break
            
            # Title is usually the next line or the one after
            title = "Untitled"
            if i + 1 < len(lines):
                next_line = lines[i+1]
                if not next_line.startswith("http") and len(next_line) > 3:
                    title = next_line
            
            url = line
            if url not in seen_urls:
                seen_urls.add(url)
                tab = {"title": title, "url": url}
                if parent_gid:
                    tree[group_map[parent_gid]].append(tab)
                else:
                    tree["Orphelins"].append(tab)
        
        i += 1
        
    # Final cleanup of titles
    for folder in tree:
        for tab in tree[folder]:
            # Clean GUIDs from titles
            tab["title"] = re.sub(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', '', tab["title"]).strip()
            if not tab["title"]:
                tab["title"] = tab["url"].split("/")[-1] or tab["url"]

    # Generate Output
    output = []
    output.append("📁 Workspace X (Session 22:49)")
    
    folders = sorted([f for f in tree.keys() if f != "Orphelins"])
    
    for folder in folders:
        tabs = tree[folder]
        if not tabs: continue
        output.append(f"├── 📁 {folder}")
        for j, tab in enumerate(tabs):
            connector = "└── " if j == len(tabs) - 1 else "├── "
            # Limit URL length for display
            display_url = tab["url"]
            if len(display_url) > 80:
                display_url = display_url[:77] + "..."
            output.append(f"│   {connector}📄 {tab['title']} ({display_url})")
            
    # Orphelins (limited to 5 if possible, but we show what we found)
    if tree["Orphelins"]:
        output.append("└── 📁 Onglets Orphelins")
        # Filter orphans to remove noise (google search, etc.)
        real_orphans = [t for t in tree["Orphelins"] if "google.com/search" not in t["url"] and "bing.com" not in t["url"]]
        for j, tab in enumerate(real_orphans):
            connector = "└── " if j == len(real_orphans) - 1 else "├── "
            display_url = tab["url"]
            if len(display_url) > 80:
                display_url = display_url[:77] + "..."
            output.append(f"    {connector}📄 {tab['title']} ({display_url})")
            
    return "\n".join(output)

if __name__ == "__main__":
    res = reconstruct_v5()
    with open("/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture_tree.md", "w") as f:
        f.write("# Architecture du Workspace X (Session 22:49)\n\n")
        f.write("```text\n")
        f.write(res)
        f.write("\n```\n")
    print("Done.")
