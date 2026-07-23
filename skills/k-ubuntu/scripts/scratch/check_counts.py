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

def analyze():
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
    
    tabs = {} 
    
    for i in range(len(all_strings) - 2):
        s1, p1 = all_strings[i]
        s2, p2 = all_strings[i+1]
        s3, p3 = all_strings[i+2]
        
        if guid_pattern.match(s1) and guid_pattern.match(s2) and url_pattern.match(s3):
            tid = s1.lower()
            gid = s2.lower()
            url = s3
            
            tabs[tid] = {
                "url": url,
                "gid": gid,
                "pos": p1
            }

    print(f"Total Unique TIDs found: {len(tabs)}")
    
    gids_found = {}
    for tid, t in tabs.items():
        gid = t["gid"]
        gids_found[gid] = gids_found.get(gid, 0) + 1
        
    print("\nGroup Summary:")
    for gid, count in sorted(gids_found.items(), key=lambda x: x[1], reverse=True):
        status = "KNOWN" if gid in FOLDER_MAP else "UNKNOWN"
        name = FOLDER_MAP.get(gid, "???")
        print(f"GID: {gid} | Tabs: {count} | Status: {status} | Name: {name}")

if __name__ == "__main__":
    analyze()
