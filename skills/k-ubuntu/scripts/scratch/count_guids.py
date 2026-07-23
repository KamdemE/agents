import re

source_file = "/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/fluid_decoded.bin"

def count_guids_at_end():
    with open(source_file, 'rb') as f:
        data = f.read()
    
    # Extract all GUIDs
    guids = re.findall(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', data.decode('ascii', errors='ignore'))
    
    print(f"Total GUIDs found: {len(guids)}")
    
    # Check the last 200 GUIDs
    last_guids = guids[-200:]
    
    # Filter out known folder GUIDs to see if the rest are tab IDs
    folder_guids = {
        "391e4626-1d06-4cb5-bce1-5a869ce951e3", # Formel
        "6cf7a5f1-a73f-484e-8a27-eeeef9ae794b", # Internships
        "a7047795-9819-4365-b169-d28ed08e0f05", # Anglais
        "c8cab1c6-96fc-4cd2-be30-b767110c8b23", # Analyse fonctionnelle
        "0deaae04-4ecc-4c8c-b074-dcf78b051611", # IME-43031-EP
        "51e61898-f841-41a2-b46b-79daca9ef756", # Algos
        "8ba59244-1a5e-4ba6-8131-df54c9959900", # Optimisation
    }
    
    tab_ids = [g for g in last_guids if g not in folder_guids]
    print(f"Potential tab GUIDs in last 200: {len(tab_ids)}")
    print(f"Example tab IDs: {tab_ids[:10]}")

if __name__ == "__main__":
    count_guids_at_end()
