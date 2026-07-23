import json
import base64
import re
import os

def extract_strings(data):
    # ASCII strings
    ascii_strings = re.findall(b'[\x20-\x7E]{4,}', data)
    # UTF-16 strings (basic attempt)
    utf16_strings = []
    try:
        # Scan for UTF-16LE sequences
        # This is very naive, but might catch titles
        for i in range(0, len(data) - 1, 2):
            if data[i] != 0 and data[i+1] == 0:
                # Potential start of UTF-16LE char
                # Try to extract a sequence
                j = i
                chars = []
                while j < len(data) - 1 and data[j] != 0 and data[j+1] == 0:
                    chars.append(data[j])
                    j += 2
                if len(chars) >= 4:
                    utf16_strings.append(bytes(chars).decode('ascii', errors='ignore'))
    except:
        pass
    
    return [s.decode('ascii', errors='ignore') for s in ascii_strings] + utf16_strings

def find_guid_patterns(data):
    # GUID pattern: 8-4-4-4-12 hex chars
    pattern = re.compile(b'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}')
    matches = []
    for match in pattern.finditer(data):
        matches.append((match.group().decode(), match.start()))
    return matches

def find_url_patterns(data):
    pattern = re.compile(b'https?://[^\s\x00-\x1f\x7f-\xff]{5,}')
    matches = []
    for match in pattern.finditer(data):
        matches.append((match.group().decode(), match.start()))
    return matches

def solve_workspace_x():
    cache_path = '/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c'
    
    with open(cache_path, 'r') as f:
        cache_data = json.load(f)
    
    fluid_b64 = cache_data.get('Fluid_Data', '')
    data = base64.b64decode(fluid_b64)
    
    guids = find_guid_patterns(data)
    urls = find_url_patterns(data)
    
    # Dump around each GUID to see what it is
    with open('/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/workspace_x_audit.txt', 'w') as out:
        out.write(f"Total GUIDs: {len(guids)}\n")
        out.write(f"Total URLs: {len(urls)}\n\n")
        
        for guid, pos in guids:
            # Look at context around GUID
            start = max(0, pos - 128)
            end = min(len(data), pos + 256)
            context = data[start:end]
            
            # Extract strings in context
            strs = extract_strings(context)
            out.write(f"GUID: {guid} at pos {pos}\n")
            out.write(f"Strings in context: {strs}\n")
            out.write("-" * 40 + "\n")

if __name__ == '__main__':
    solve_workspace_x()
