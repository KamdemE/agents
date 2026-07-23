import json
import base64
import re
import sys

source_file = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"

def clean_title(title, url):
    if not title: return url
    if re.match(r'^[0-9a-fA-F-]{36}$', title): return url
    if re.match(r'^\d+$', title): return url
    forbidden = ["tabs", "groups", "workspace", "folder", "none", "lockedTabs", "skypeChat"]
    if title.lower() in forbidden: return url
    title = title.strip(" -|_")
    if len(title) > 120: title = title[:117] + "..."
    return title

def reconstruct():
    with open(source_file, 'r') as f:
        data = json.load(f)
    
    fluid_b64 = data.get("Fluid_Data", "")
    decoded = base64.b64decode(fluid_b64)
    
    strings = []
    # ASCII
    for m in re.finditer(rb'[\x20-\x7E]{3,}', decoded):
        try: strings.append((m.group().decode('ascii'), m.start()))
        except: pass
    # UTF-16
    utf16_raw = decoded.decode('utf-16', errors='ignore')
    for m in re.finditer(r'[\u0020-\u007E\u00A0-\u00FF]{3,}', utf16_raw):
        strings.append((m.group().strip(), m.start() * 2))
    
    all_strings = sorted(strings, key=lambda x: x[1])
    
    guid_pattern = re.compile(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', re.I)
    url_pattern = re.compile(r'^https?://', re.I)
    
    # 1. Discover Groups and their Titles
    # Pattern observed: Title string is often just before or after the Group GUID in the property list
    group_titles = {}
    for i, (s, p) in enumerate(all_strings):
        if guid_pattern.match(s):
            # Check if this GUID is a group (look for "title" or descriptive strings nearby)
            # In Fluid metadata, groups often have a "title" property
            # For now, let's look for any non-GUID, non-URL string in the vicinity
            gid = s.lower()
            if gid in group_titles: continue
            
            # Look for a title
            for offset in range(1, 5):
                if i - offset >= 0:
                    cand = all_strings[i-offset][0]
                    if not guid_pattern.match(cand) and not url_pattern.match(cand) and len(cand) > 2:
                        if cand.lower() not in ["tabs", "groups", "workspace", "folder", "none"]:
                            # Handle split strings (like Algos pour l'analyse...)
                            final_title = cand
                            if i - offset - 1 >= 0:
                                prev = all_strings[i-offset-1][0]
                                if not guid_pattern.match(prev) and len(prev) > 3 and not url_pattern.match(prev):
                                    if not any(x in prev.lower() for x in ["tabs", "groups"]):
                                        final_title = prev + final_title
                            group_titles[gid] = final_title
                            break

    # 2. Extract Tabs
    tabs = []
    for i in range(len(all_strings) - 2):
        s1, p1 = all_strings[i]
        s2, p2 = all_strings[i+1]
        s3, p3 = all_strings[i+2]
        
        # Tab pattern: [TabGUID, GroupGUID/ "tabs", URL]
        if guid_pattern.match(s1) and (guid_pattern.match(s2) or s2 == "tabs") and url_pattern.match(s3):
            tid = s1.lower()
            gid = s2.lower()
            url = s3
            
            title = None
            for offset in range(1, 10):
                if i + 2 + offset < len(all_strings):
                    cand = all_strings[i + 2 + offset][0]
                    if not guid_pattern.match(cand) and not url_pattern.match(cand) and len(cand) > 3:
                        if not re.match(r'^\d+$', cand) and cand.lower() not in ["tabs", "groups", "workspace"]:
                            title = cand
                            break
                if i - offset >= 0:
                    cand = all_strings[i - offset][0]
                    if not guid_pattern.match(cand) and not url_pattern.match(cand) and len(cand) > 3:
                        if not re.match(r'^\d+$', cand) and cand.lower() not in ["tabs", "groups", "workspace"]:
                            title = cand
                            break
            
            tabs.append({"url": url, "title": clean_title(title, url), "gid": gid, "pos": p1})

    # 3. Build Tree
    tabs.sort(key=lambda x: x["pos"])
    
    # We only care about groups that actually have tabs
    active_gids = set(t["gid"] for t in tabs if t["gid"] != "tabs")
    
    output_path = "/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_architecture_tree.md"
    with open(output_path, "w") as f:
        f.write("# 📂 Workspace X - Arborescence Architecturale (v22h49)\n\n")
        f.write("```text\n")
        f.write("Workspace X\n")
        
        # Group tabs
        groups = {}
        orphans = []
        for t in tabs:
            if t["gid"] in group_titles:
                gname = group_titles[t["gid"]]
                if gname not in groups: groups[gname] = []
                groups[gname].append(t)
            else:
                orphans.append(t)
        
        sorted_gnames = sorted(groups.keys())
        for idx, gname in enumerate(sorted_gnames):
            is_last_g = (idx == len(sorted_gnames) - 1 and not orphans)
            prefix = "└── " if is_last_g else "├── "
            f.write(f"{prefix}📁 {gname} ({len(groups[gname])} onglets)\n")
            
            tab_prefix = "    " if is_last_g else "│   "
            for t_idx, t in enumerate(groups[gname]):
                is_last_t = (t_idx == len(groups[gname]) - 1)
                t_char = "└── " if is_last_t else "├── "
                f.write(f"{tab_prefix}{t_char}{t['title']}\n")
                f.write(f"{tab_prefix}{'    ' if is_last_t else '│   '}└─ {t['url']}\n")
        
        if orphans:
            f.write(f"└── 📄 Onglets Orphelins ({len(orphans)})\n")
            for t_idx, t in enumerate(orphans):
                is_last_t = (t_idx == len(orphans) - 1)
                t_char = "└── " if is_last_t else "├── "
                f.write(f"    {t_char}{t['title']}\n")
                f.write(f"    {'    ' if is_last_t else '│   '}└─ {t['url']}\n")
        
        f.write("```\n")
    
    print(f"Generated {output_path}")
    print(f"Found {len(groups)} groups and {len(orphans)} orphans.")

if __name__ == "__main__":
    reconstruct()
