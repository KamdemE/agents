import re
import json
import base64

source_file = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"

def surgical_discovery():
    with open(source_file, 'r') as f:
        data = json.load(f)
    
    fluid_b64 = data.get("Fluid_Data", "")
    decoded = base64.b64decode(fluid_b64)
    
    # We are looking for Group objects.
    # Often they look like: ... "id":"<GID>", ... "title":"<NAME>" ...
    # But it's binary. Let's look for "title" strings in the neighborhood of GIDs.
    
    utf16_raw = decoded.decode('utf-16', errors='ignore')
    
    known_gids = [
        "34077382-ee9d-416d-b615-eedd1ac775d3",
        "6ffce2f6-d97d-490a-bd91-0ffc576916f5",
        "2cc47188-d4e5-4a25-acdd-a842e1a7fe43",
        "391e4626-1d06-4cb5-bce1-5a869ce951e3",
        "6cf7a5f1-a73f-484e-8a27-eeeef9ae794b",
        "a7047795-9819-4365-b169-d28ed08e0f05",
        "c8cab1c6-96fc-4cd2-be30-b767110c8b23",
        "0deaae04-4ecc-4c8c-b074-dcf78b051611",
        "51e61898-f841-41a2-b46b-79daca9ef756",
        "8ba59244-1a5e-4ba6-8131-df54c9959900"
    ]
    
    for gid in known_gids:
        print(f"\n--- Searching for Group Name of {gid} ---")
        # Search in UTF-16
        idx = utf16_raw.find(gid)
        while idx != -1:
            # Look around this index (e.g., 200 chars before and after)
            context = utf16_raw[max(0, idx-100):min(len(utf16_raw), idx+300)]
            # Look for something that looks like a title
            # In Fluid, it might be preceded by "title"
            print(f"Context: {repr(context)}")
            idx = utf16_raw.find(gid, idx + 1)

if __name__ == "__main__":
    surgical_discovery()
