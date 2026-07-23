import json
import base64
import re

source_file = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"

def debug_fluid():
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
    
    # We saw groups like kapoivha@gmail.com...
    # Let's find those GUIDs and see what's around them
    
    # Actually, let's just dump ALL guid contexts to a file
    with open("/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/guid_contexts.txt", "w") as f:
        for i, (s, p) in enumerate(all_strings):
            if guid_pattern.match(s):
                f.write(f"\n--- GUID: {s} at pos {p} ---\n")
                # context before
                for j in range(max(0, i-10), i):
                    f.write(f"  PRE: {all_strings[j][0]}\n")
                # context after
                for j in range(i+1, min(len(all_strings), i+10)):
                    f.write(f"  POST: {all_strings[j][0]}\n")

if __name__ == "__main__":
    debug_fluid()
