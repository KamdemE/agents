import json
import base64
import re

cache_path = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"

with open(cache_path, 'r') as f:
    cache_data = json.load(f)

fluid_b64 = cache_data.get("Fluid_Data", "")
fluid_bytes = base64.b64decode(fluid_b64)
fluid_str = fluid_bytes.decode('utf-8', 'ignore')

# GUID regex
guid_re = re.compile(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')

# Known groups from JSON metadata or discovery
group_map = {
    "a7047795-9819-4365-b169-d28ed08e0f05": "Anglais",
    "2cc47188-d4e5-4a25-acdd-a842e1a7fe43": "PSC",
    "c8cab1c6-96fc-4cd2-be30-b767110c8b23": "Analyse fonctionnelle",
    "0deaae04-4ecc-4c8c-b074-dcf78b051611": "IME-43031-EP",
    "83a6b631-0701-4470-811c-c7657159c988": "Formel", # Guessed from previous work
    "485d4615-568e-4f1b-8531-1e967159c988": "Internships", # Guessed
}

# Actually, let's extract all strings (length > 3)
strings = re.findall(r'[ -~]{4,}', fluid_str)

# Let's try to find "tab" objects
# Heuristic: A tab record often contains: [GUID (TabID), Title, URL, GUID (GroupID)]
# Or [URL, Title, GUID (TabID), GUID (GroupID)]

tabs = []
current_group = None

# Let's just dump all strings with their index to see patterns
for i, s in enumerate(strings):
    if guid_re.match(s):
        # Is it a group?
        if s in group_map:
            print(f"Group: {group_map[s]} ({s}) at index {i}")
        else:
            print(f"GUID: {s} at index {i}")
    elif s.startswith("http"):
        print(f"URL: {s} at index {i}")
    elif len(s) > 10 and not s.startswith("ey"): # ignore tokens
        print(f"String: {s} at index {i}")

