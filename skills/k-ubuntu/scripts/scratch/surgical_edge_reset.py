import json
import os
import sys

pref_path = "/home/kpihx/.config/microsoft-edge/Profile 2/Preferences"

if not os.path.exists(pref_path):
    print(f"Error: {pref_path} not found")
    sys.exit(1)

with open(pref_path, 'r') as f:
    data = json.load(f)

# Surgical Sync Reset
if 'sync' in data:
    print("Resetting sync configuration...")
    # Remove unique identifiers to force a "New Device" state
    data['sync'].pop('cache_guid', None)
    data['sync'].pop('keystore', None)
    data['sync'].pop('session_name', None)
    
    # Reset completion flags
    data['sync']['has_setup_completed'] = False
    data['sync']['initial_sync_completed'] = False
    data['sync']['keep_everything_synced'] = True # Ensure we push everything
    
    # Reset Microsoft account specific sync states if present
    if 'remaining_local_data_cleared' in data['sync']:
        data['sync']['remaining_local_data_cleared'] = False

# Ensure Workspaces are kept
if 'edge' in data and 'workspaces' in data['edge']:
    print("Workspaces configuration detected and preserved.")

with open(pref_path, 'w') as f:
    json.dump(data, f)

print("Surgical Preferences edit complete.")
