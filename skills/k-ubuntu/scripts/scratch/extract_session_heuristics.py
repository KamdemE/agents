import re
import sys

def extract_workspace_tabs(session_file, workspace_guid):
    with open(session_file, 'rb') as f:
        content = f.read()
    
    # We look for the workspace GUID in binary
    guid_bytes = workspace_guid.encode('utf-16le') # Edge often uses UTF-16
    if guid_bytes not in content:
        guid_bytes = workspace_guid.encode('ascii')
    
    if guid_bytes not in content:
        return []

    # The SNSS format is complex. Let's use a heuristic: 
    # find all URLs (ASCII/UTF-8) and check if they are "near" the workspace markers.
    # Actually, let's just extract all URLs and see if we can identify blocks.
    
    # Regex for URLs in binary
    url_pattern = re.compile(rb'https?://[^\x00\x08\x0a\x0d\x20]{5,}')
    urls = url_pattern.findall(content)
    
    # Clean and unique
    cleaned_urls = []
    for url in urls:
        try:
            u = url.decode('utf-8', errors='ignore')
            if u not in cleaned_urls:
                cleaned_urls.append(u)
        except:
            continue
            
    return cleaned_urls

session_file = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Sessions/Session_13422314264822363"
ws_x_guid = "2711dd14-9022-4f80-9c7d-2f069f218f2c"
labs_guid = "676edddd-dbce-411a-97a6-5b0281d81331"

print(f"Extraction for Workspace X ({ws_x_guid})...")
urls_x = extract_workspace_tabs(session_file, ws_x_guid)
print(f"Found {len(urls_x)} potential URLs in the session file.")

# Let's try to be more specific by finding the "edge_workspaces_navigation_entry_data" blocks
# These blocks usually contain the URL and the workspace ID nearby.
