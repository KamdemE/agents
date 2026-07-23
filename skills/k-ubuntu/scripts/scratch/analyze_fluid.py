import json
import base64
import os
import re

cache_path = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"

if not os.path.exists(cache_path):
    print("Cache not found")
    exit()

with open(cache_path, 'r') as f:
    data = json.load(f)

fluid_b64 = data.get("Fluid_Data", "")
fluid_bytes = base64.b64decode(fluid_b64)

# Print as hex and ASCII to see structure
def print_binary_structure(data, chunk_size=32):
    for i in range(0, len(data), chunk_size):
        chunk = data[i:i+chunk_size]
        hex_part = " ".join(f"{b:02x}" for b in chunk)
        ascii_part = "".join(chr(b) if 32 <= b <= 126 else "." for b in chunk)
        print(f"{i:06x}: {hex_part:<{chunk_size*3}} | {ascii_part}")

# print_binary_structure(fluid_bytes)

# Let's try to extract GUIDs and Names
fluid_str = fluid_bytes.decode('utf-8', 'ignore')

# Looking for GUID pattern: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
guid_pattern = re.compile(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
guids = guid_pattern.findall(fluid_str)

# Looking for URL pattern
url_pattern = re.compile(r'https?://[^\s\x00-\x1f\x7f-\xff<>"]+')
urls = url_pattern.findall(fluid_str)

print(f"Found {len(guids)} GUIDs and {len(urls)} URLs")

# Let's see if there's a pattern like [GUID][NAME] or [GUID][TAB_ID]
# The cat output showed something like:
# 34077382-ee9d-416d-b615-eedd1ac775d3 .... Fr
# 391e4626-1d06-4cb5-bce1-5a869ce951e3 .... Former

# I will try to find the groups and their labels
# In Fluid, groups are usually "TabGroup" objects.
