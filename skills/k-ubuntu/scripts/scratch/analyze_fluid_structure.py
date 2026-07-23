import json
import base64
import re

def analyze_fluid_structure():
    path = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"
    with open(path, "r") as f:
        data = json.load(f)
    
    fluid_b64 = data.get("Fluid_Data", "")
    decoded = base64.b64decode(fluid_b64)
    group_guids = list(data.get("Tab_Group_Collapsed_States", {}).keys())
    
    # Let's search for JSON-like fragments first
    # Often Fluid uses some binary markers but keeps JSON objects for state
    json_fragments = re.findall(b'\{[^{}]+\}', decoded)
    print(f"Found {len(json_fragments)} JSON-like fragments")
    
    for frag in json_fragments:
        try:
            # Try to find valid JSON within the fragment
            s = frag.decode('utf-8', errors='ignore')
            obj = json.loads(s)
            # Only print if it looks relevant (contains GUIDs or tab info)
            s_obj = json.dumps(obj)
            if any(gid in s_obj for gid in group_guids[:5]) or "url" in s_obj or "title" in s_obj:
                print(f"Fragment: {s_obj}")
        except:
            pass

    # Let's also look for strings (GUIDs, Titles, URLs) and their neighbors
    # We want to see if Tab IDs follow Group IDs in a list
    all_strings = re.findall(b'[\x20-\x7E]{4,}', decoded)
    with open("fluid_strings_dump.txt", "wb") as f:
        for s in all_strings:
            f.write(s + b"\n")
            
    print("Dumped strings to fluid_strings_dump.txt")

if __name__ == "__main__":
    analyze_fluid_structure()
