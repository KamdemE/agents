import os
import re

session_file = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Sessions/Session_13422314264822363"

def extract_urls(filepath):
    with open(filepath, 'rb') as f:
        content = f.read()
    
    # SNSS files contain URLs in a specific format, but they are often plain text within the binary
    # We look for http/https patterns.
    urls = re.findall(rb'https?://[^\x00\s"\'<>]+', content)
    unique_urls = []
    seen = set()
    for url in urls:
        url_str = url.decode('utf-8', errors='ignore')
        # Clean up trailing characters
        url_str = re.split(r'[^\w/.\-?=&%#]', url_str)[0]
        if url_str not in seen and len(url_str) > 10:
            unique_urls.append(url_str)
            seen.add(url_str)
    return unique_urls

urls = extract_urls(session_file)
print(f"Extracted {len(urls)} URLs from the main session file.")
for i, url in enumerate(urls[:200]): # Workspace X has 103, Labs has 63
    print(f"{i+1}: {url}")
