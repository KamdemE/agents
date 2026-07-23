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

def clean_title(title, url):
    if not title:
        return url
    # If title is just a number or GUID, it's not a title
    if re.match(r'^\d+$', title) or re.match(r'^[0-9a-fA-F-]{36}$', title):
        return url
    if title.lower() in ["tabs", "groups", "workspace", "folder", "none"]:
        return url
    title = title.strip(" -|_")
    if len(title) > 120: title = title[:117] + "..."
    return title

def extract_workspace_tree():
    with open(source_file, 'r') as f:
        data = json.load(f)
    
    fluid_b64 = data.get("Fluid_Data", "")
    decoded = base64.b64decode(fluid_b64)
    
    strings = []
    # ASCII
    for m in re.finditer(rb'[\x20-\x7E]{3,}', decoded):
        try:
            strings.append((m.group().decode('ascii'), m.start()))
        except: pass
    # UTF-16
    utf16_raw = decoded.decode('utf-16', errors='ignore')
    for m in re.finditer(r'[\u0020-\u007E\u00A0-\u00FF]{3,}', utf16_raw):
        strings.append((m.group().strip(), m.start() * 2))
        
    all_strings = sorted(strings, key=lambda x: x[1])
    
    guid_pattern = re.compile(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', re.I)
    url_pattern = re.compile(r'^https?://', re.I)
    
    tabs = [] # list of {url, title, gid, pos}
    
    for i in range(len(all_strings) - 2):
        s1, p1 = all_strings[i]
        s2, p2 = all_strings[i+1]
        s3, p3 = all_strings[i+2]
        
        # Sequence: [TabID (GUID), GroupID/ "tabs", URL]
        if guid_pattern.match(s1) and (guid_pattern.match(s2) or s2 == "tabs") and url_pattern.match(s3):
            tid = s1.lower()
            gid = s2.lower()
            url = s3
            
            # Expanded title search: look around for the first string that isn't a GUID or URL
            title = None
            for offset in range(1, 10):
                # Search after
                if i + 2 + offset < len(all_strings):
                    cand, cp = all_strings[i + 2 + offset]
                    if not guid_pattern.match(cand) and not url_pattern.match(cand) and len(cand) > 3:
                        if not re.match(r'^\d+$', cand):
                            title = cand
                            break
                # Search before
                if i - offset >= 0:
                    cand, cp = all_strings[i - offset]
                    if not guid_pattern.match(cand) and not url_pattern.match(cand) and len(cand) > 3:
                        if not re.match(r'^\d+$', cand):
                            title = cand
                            break
            
            tabs.append({
                "url": url,
                "title": clean_title(title, url),
                "gid": gid,
                "pos": p1
            })

    # Sort by position (appearance in memory)
    tabs.sort(key=lambda x: x["pos"])

    # Grouping
    grouped_tabs = {name: [] for name in FOLDER_MAP.values()}
    orphans = []
    
    for t in tabs:
        if t["gid"] in FOLDER_MAP:
            grouped_tabs[FOLDER_MAP[t["gid"]]].append(t)
        else:
            orphans.append(t)
            
    # Write output
    output_path = "/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture_tree.md"
    with open(output_path, "w") as f:
        f.write("# 📂 Workspace X - Arborescence Architecturale (v22h49)\n\n")
        f.write("```text\n")
        f.write("Workspace X\n")
        
        active_folders = [name for name, tlist in grouped_tabs.items() if tlist]
        
        for idx, folder_name in enumerate(active_folders):
            is_last_folder = (idx == len(active_folders) - 1 and not orphans)
            folder_prefix = "└── " if is_last_folder else "├── "
            f.write(f"{folder_prefix}📁 {folder_name} ({len(grouped_tabs[folder_name])} onglets)\n")
            
            tab_base_prefix = "    " if is_last_folder else "│   "
            for t_idx, t in enumerate(grouped_tabs[folder_name]):
                is_last_tab = (t_idx == len(grouped_tabs[folder_name]) - 1)
                tab_char = "└── " if is_last_tab else "├── "
                f.write(f"{tab_base_prefix}{tab_char}{t['title']}\n")
                f.write(f"{tab_base_prefix}{'    ' if is_last_tab else '│   '}└─ {t['url']}\n")

        if orphans:
            f.write(f"└── 📄 Onglets Orphelins ({len(orphans)})\n")
            for t_idx, t in enumerate(orphans):
                is_last_tab = (t_idx == len(orphans) - 1)
                tab_char = "└── " if is_last_tab else "├── "
                f.write(f"    {tab_char}{t['title']}\n")
                f.write(f"    {'    ' if is_last_tab else '│   '}└─ {t['url']}\n")
                
        f.write("```\n")

    print(f"File generated: {output_path}")
    print(f"Summary: {len(active_folders)} folders, {len(orphans)} orphans.")

if __name__ == "__main__":
    extract_workspace_tree()
