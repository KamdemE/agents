import json
import sys
import os

def sanitize_json(path):
    if not os.path.exists(path):
        print(f"File not found: {path}")
        return
    with open(path, 'r') as f:
        try:
            data = json.load(f)
        except Exception as e:
            print(f"Error loading {path}: {e}")
            return
    
    # Nuke all sync and account info
    data['account_info'] = []
    data['sync'] = {
        "has_setup_completed": False,
        "initial_sync_completed": False,
        "keep_everything_synced": True
    }
    if 'google' in data and 'services' in data['google']:
        data['google']['services']['signin_allowed'] = True
        
    with open(path, 'w') as f:
        json.dump(data, f)
    print(f"Sanitized: {path}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        target_dir = sys.argv[1]
    else:
        target_dir = "/home/kpihx/.config/microsoft-edge/Default"
        
    sanitize_json(os.path.join(target_dir, "Preferences"))
    sanitize_json(os.path.join(target_dir, "Secure Preferences"))
