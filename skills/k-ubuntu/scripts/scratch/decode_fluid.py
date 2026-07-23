import json
import base64
import re

cache_path = "/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c"
output_path = "/home/kpihx/.agents/skills/k-ubuntu/scripts/scratch/fluid_decoded.bin"

def decode_fluid():
    with open(cache_path, 'r') as f:
        data = json.load(f)
    
    fluid_b64 = data.get("Fluid_Data", "")
    if not fluid_b64:
        print("No Fluid_Data found.")
        return

    binary_data = base64.b64decode(fluid_b64)
    with open(output_path, 'wb') as f:
        f.write(binary_data)
    print(f"Decoded {len(binary_data)} bytes to {output_path}")

if __name__ == "__main__":
    decode_fluid()
