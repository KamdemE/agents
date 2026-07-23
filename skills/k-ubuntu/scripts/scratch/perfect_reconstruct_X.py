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
    "8ba59244-1a5e-4ba6-8131-df54c9959900": "Optimation & Controle",
    "34077382-ee9d-416d-b615-eedd1ac775d3": "Administratif / Perso",
    "6ffce2f6-d97d-490a-bd91-0ffc576916f5": "Ecole / Polytechnique",
    "2cc47188-d4e5-4a25-acdd-a842e1a7fe43": "Maths / Algos"
}

WORKSPACE_ID = "2711dd14-9022-4f80-9c7d-2f069f218f2c"

def clean_title(title, url):
    if not title or len(title) < 2 or title in ["tabs", "groups", "workspace"]:
        return url
    title = title.strip(" -|_")
    if len(title) > 100: title = title[:97] + "..."
    return title

def generate_final_tree():
    with open(source_file, 'r') as f:
        data = json.load(f)
    
    fluid_b64 = data.get("Fluid_Data", "")
    decoded = base64.b64decode(fluid_b64)
    
    strings = []
    # ASCII
    for m in re.finditer(rb'[\x20-\x7E]{4,}', decoded):
        try:
            strings.append((m.group().decode('ascii'), m.start()))
        except: pass
    # UTF-16
    utf16_raw = decoded.decode('utf-16', errors='ignore')
    for m in re.finditer(r'[\u0020-\u007E\u00A0-\u00FF]{4,}', utf16_raw):
        strings.append((m.group().strip(), m.start() * 2))
        
    all_strings = sorted(strings, key=lambda x: x[1])
    
    guid_pattern = re.compile(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', re.I)
    url_pattern = re.compile(r'^https?://', re.I)
    
    tabs = {} # tid -> {url, title, gid, pos}
    
    for i in range(len(all_strings) - 2):
        s1, p1 = all_strings[i]
        s2, p2 = all_strings[i+1]
        s3, p3 = all_strings[i+2]
        
        # Sequence: [TabID, GroupID/WorkspaceID, URL]
        if guid_pattern.match(s1) and (guid_pattern.match(s2) or s2 == "tabs") and url_pattern.match(s3):
            tid = s1.lower()
            gid = s2.lower()
            url = s3
            
            # Find title
            title = None
            # Check next string
            if i + 3 < len(all_strings):
                cand, cp = all_strings[i+3]
                if not guid_pattern.match(cand) and not url_pattern.match(cand) and len(cand) > 3:
                    title = cand
            # Check previous string
            if not title and i > 0:
                cand, cp = all_strings[i-1]
                if not guid_pattern.match(cand) and not url_pattern.match(cand) and len(cand) > 3:
                    title = cand
                    
            tabs[tid] = {
                "url": url,
                "title": clean_title(title, url),
                "gid": gid,
                "pos": p1
            }

    # Structure
    groups = {name: [] for name in FOLDER_MAP.values()}
    orphans = []
    
    for tid in sorted(tabs, key=lambda k: tabs[k]["pos"], reverse=True):
        t = tabs[tid]
        if t["gid"] in FOLDER_MAP:
            groups[FOLDER_MAP[t["gid"]]].append(t)
        else:
            orphans.append(t)
            
    # Output
    md_path = "/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture_tree.md"
    with open(md_path, "w") as f:
        f.write("# 📂 Workspace X - Arborescence Architecturale\n")
        f.write("> État de session reconstitué (Version 22:49)\n\n")
        f.write("```text\n")
        f.write("Workspace X\n")
        
        folders = [name for name, tlist in groups.items() if tlist]
        for idx, name in enumerate(folders):
            is_last_folder = (idx == len(folders) - 1 and len(orphans) == 0)
            prefix = "└── " if is_last_folder else "├── "
            f.write(f"{prefix}📁 {name} ({len(groups[name])})\n")
            
            tab_prefix = "    " if is_last_folder else "│   "
            for t_idx, tab in enumerate(sorted(groups[name], key=lambda x: x["title"])):
                is_last_tab = (t_idx == len(groups[name]) - 1)
                tab_char = "└── " if is_last_tab else "├── "
                f.write(f"{tab_prefix}{tab_char}{tab['title']}\n")
                f.write(f"{tab_prefix}{'    ' if is_last_tab else '│   '}🔗 {tab['url']}\n")

        if orphans:
            f.write(f"└── 📄 Onglets Orphelins ({len(orphans)})\n")
            for t_idx, tab in enumerate(sorted(orphans, key=lambda x: x["title"])):
                is_last_tab = (t_idx == len(orphans) - 1)
                tab_char = "└── " if is_last_tab else "├── "
                f.write(f"    {tab_char}{tab['title']}\n")
                f.write(f"    {'    ' if is_last_tab else '│   '}🔗 {tab['url']}\n")
                
        f.write("```\n")

    print(f"Reconstruction terminée: {md_path}")
    print(f"Total tabs: {len(tabs)}")
    print(f"Folders: {len(folders)}")
    print(f"Orphans: {len(orphans)}")

if __name__ == "__main__":
    generate_final_tree()
