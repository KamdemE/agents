import re
import json
import base64

source_file = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"

def dump_guid_contexts():
    with open(source_file, 'r') as f:
        data = json.load(f)
    
    fluid_b64 = data.get("Fluid_Data", "")
    decoded = base64.b64decode(fluid_b64)
    
    # ASCII GUIDs
    guid_pattern = re.compile(rb'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', re.I)
    
    for match in guid_pattern.finditer(decoded):
        start = match.start()
        gid = match.group().decode()
        # Look around
        context = decoded[max(0, start-40):min(len(decoded), start+100)]
        # Filter out obvious tab data (URLs)
        if b"http" not in context:
            print(f"GID: {gid} | Context: {repr(context)}")

if __name__ == "__main__":
    dump_guid_contexts()
