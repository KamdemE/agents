import re
import json
import base64

source_file = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"

def discover_groups():
    with open(source_file, 'r') as f:
        data = json.load(f)
    
    fluid_b64 = data.get("Fluid_Data", "")
    decoded = base64.b64decode(fluid_b64)
    
    # Extract all strings
    strings = []
    # ASCII
    for match in re.finditer(rb'[\x20-\x7E]{4,}', decoded):
        try:
            strings.append((match.group().decode('ascii'), match.start()))
        except: pass
    
    # UTF-16
    utf16_raw = decoded.decode('utf-16', errors='ignore')
    for match in re.finditer(r'[\u0020-\u007E\u00A0-\u00FF]{4,}', utf16_raw):
        strings.append((match.group().strip(), match.start() * 2))
    
    all_strings = sorted(strings, key=lambda x: x[1])
    
    guid_pattern = re.compile(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', re.I)
    url_pattern = re.compile(r'^https?://', re.I)
    
    groups_found = {} # gid -> set of titles found nearby
    
    for i in range(len(all_strings) - 2):
        s1, p1 = all_strings[i]
        s2, p2 = all_strings[i+1]
        s3, p3 = all_strings[i+2]
        
        # Sequence: TabID, GroupID, URL
        if guid_pattern.match(s1) and guid_pattern.match(s2) and url_pattern.match(s3):
            gid = s2.lower()
            if gid not in groups_found:
                groups_found[gid] = []
            
    print(f"Found {len(groups_found)} potential group IDs.")
    
    # Now try to find titles for these GIDs
    # Often a GID is followed by its name in a different object
    for gid in groups_found:
        # Search for GID in the string list
        for i, (s, p) in enumerate(all_strings):
            if s.lower() == gid:
                # Look at strings immediately following this GID
                for j in range(1, 5):
                    if i + j < len(all_strings):
                        candidate, cp = all_strings[i+j]
                        if not guid_pattern.match(candidate) and not url_pattern.match(candidate) and len(candidate) > 2:
                            # If it looks like a folder name (not a URL, not a GUID, not noise)
                            if candidate not in ["tabs", "groups", "workspace", "title"]:
                                groups_found[gid].append(candidate)
                                
    for gid, titles in groups_found.items():
        unique_titles = list(set(titles))
        print(f"GID: {gid} -> Titles: {unique_titles}")

if __name__ == "__main__":
    discover_groups()
