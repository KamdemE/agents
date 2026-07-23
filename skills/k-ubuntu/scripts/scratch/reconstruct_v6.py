import json
import re

# Paths
dump_path = "/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/fluid_strings_decoded.txt"

def reconstruct_v6():
    # Final Mapping based on deep analysis of decoded strings
    group_map = {
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
    
    group_ids = set(group_map.keys())
    
    with open(dump_path, "r", encoding='utf-8', errors='ignore') as f:
        lines = [line.strip() for line in f if line.strip()]
    
    tree = {name: [] for name in group_map.values()}
    tree["Orphelins"] = []
    
    seen_urls = set()
    current_group = None
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Check if line is a Group GUID
        if line in group_ids:
            current_group = group_map[line]
            i += 1
            continue
            
        # Check for URL
        if line.startswith("http") and not any(x in line for x in [".ico", "favicon", "google-analytics", "doubleclick"]):
            url = line
            title = "Untitled"
            
            # Pattern: URL -> Title -> URL
            if i + 2 < len(lines) and lines[i+2] == url:
                title = lines[i+1]
                i += 2 # Skip the repeated URL
            elif i + 1 < len(lines) and not lines[i+1].startswith("http"):
                title = lines[i+1]
                # Don't skip yet, might be part of the next block
            
            if url not in seen_urls:
                seen_urls.add(url)
                # Clean title
                title = re.sub(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', '', title).strip()
                if not title or title == "Untitled":
                    # Try to extract something from URL
                    title = url.split("/")[-1] or url
                
                tab = {"title": title, "url": url}
                if current_group:
                    tree[current_group].append(tab)
                else:
                    tree["Orphelins"].append(tab)
        
        i += 1
        
    # Generate Output
    output = []
    output.append("📁 Workspace X (Session 22:49)")
    
    folders = list(group_map.values()) # Keep order
    
    for folder in folders:
        tabs = tree[folder]
        if not tabs: continue
        output.append(f"├── 📁 {folder}")
        for j, tab in enumerate(tabs):
            connector = "└── " if j == len(tabs) - 1 else "├── "
            display_url = tab["url"]
            if len(display_url) > 100:
                display_url = display_url[:97] + "..."
            output.append(f"│   {connector}📄 {tab['title']} ({display_url})")
            
    # Orphelins (limited to 5 if possible)
    real_orphans = [t for t in tree["Orphelins"] if "google.com/search" not in t["url"] and "bing.com" not in t["url"]]
    if real_orphans:
        output.append("└── 📁 Onglets Orphelins")
        for j, tab in enumerate(real_orphans):
            connector = "└── " if j == len(real_orphans) - 1 else "├── "
            display_url = tab["url"]
            if len(display_url) > 100:
                display_url = display_url[:97] + "..."
            output.append(f"    {connector}📄 {tab['title']} ({display_url})")
            
    return "\n".join(output)

if __name__ == "__main__":
    res = reconstruct_v6()
    with open("/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture_tree.md", "w") as f:
        f.write("# Architecture du Workspace X (Session 22:49)\n\n")
        f.write("```text\n")
        f.write(res)
        f.write("\n```\n")
    print("Done.")
