import json
import base64
import re

source_file = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"

def find_active_tabs():
    with open(source_file, 'r') as f:
        data = json.load(f)
    
    fluid_b64 = data.get("Fluid_Data", "")
    decoded = base64.b64decode(fluid_b64)
    
    # Search for JSON fragments that look like lists of GUIDs
    # GUID pattern: [0-9a-f]{8}-[0-9a-f]{4}...
    fragments = re.findall(b'\{[^{}]+\}', decoded)
    
    for frag in fragments:
        try:
            s = frag.decode('utf-8', errors='ignore')
            obj = json.loads(s)
            if isinstance(obj, dict):
                # Look for keys or values that are lists of GUIDs
                for k, v in obj.items():
                    if isinstance(v, list) and len(v) > 0 and isinstance(v[0], str) and re.match(r'[0-9a-f]{8}-', v[0]):
                        print(f"Found list in key '{k}': {len(v)} items")
                        print(f"Items: {v[:5]}...")
        except:
            pass

if __name__ == "__main__":
    find_active_tabs()
