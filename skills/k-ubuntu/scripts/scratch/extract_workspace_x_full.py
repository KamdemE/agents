import json

def print_tree(node, indent=0):
    if node.get('type') == 'folder':
        print('  ' * indent + f"📁 {node.get('name')} (ID: {node.get('id')})")
        for child in node.get('children', []):
            print_tree(child, indent + 1)
    elif node.get('type') == 'url':
        print('  ' * indent + f"🔗 {node.get('name')}: {node.get('url')}")
    elif node.get('type') == 'workspace':
        print('  ' * indent + f"🌐 Workspace: {node.get('name')} (ID: {node.get('id')})")
        for child in node.get('children', []):
            print_tree(child, indent + 1)

backup_file = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Bookmarks"

with open(backup_file, 'r') as f:
    data = json.load(f)

print("=== EXTRACTION DU DOSSIER 'X' (BACKUP 22:49) ===")
# Target folder path found earlier: roots.other.children[2].children[0]
try:
    folder_x = data['roots']['other']['children'][2]['children'][0]
    if folder_x.get('name') == 'X':
        print_tree(folder_x)
    else:
        print("Erreur: Le chemin spécifié ne pointe pas vers 'X'")
except (KeyError, IndexError):
    print("Erreur: Chemin introuvable dans le JSON")

print("\n=== EXTRACTION DU WORKSPACE 'X' (BACKUP 22:49) ===")
# Target workspace path: roots.workspaces.children[2]
try:
    ws_x = data['roots']['workspaces']['children'][2]
    if ws_x.get('name') == 'X':
        print_tree(ws_x)
    else:
        print("Erreur: Le chemin spécifié ne pointe pas vers Workspace 'X'")
except (KeyError, IndexError):
    print("Erreur: Workspace 'X' introuvable")
