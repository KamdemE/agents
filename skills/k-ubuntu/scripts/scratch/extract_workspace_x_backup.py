import json

# READING FROM THE GOLDEN BACKUP
bookmarks_path = "/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Bookmarks"

with open(bookmarks_path, 'r') as f:
    data = json.load(f)

def find_workspace_x(node):
    if isinstance(node, dict):
        if node.get('name') == 'X' and (node.get('type') == 'workspace' or node.get('workspace_id')):
            return node
        if 'children' in node:
            for child in node['children']:
                res = find_workspace_x(child)
                if res: return res
    elif isinstance(node, list):
        for item in node:
            res = find_workspace_x(item)
            if res: return res
    return None

workspace_x = find_workspace_x(data)

def print_tree(node, level=0):
    indent = "  " * level
    name = node.get('name', 'Unnamed')
    node_type = node.get('type', 'folder')
    if node_type == 'url':
        print(f"{indent}🔗 {name}: {node.get('url')}")
    else:
        print(f"{indent}📁 {name}")
        if 'children' in node:
            for child in node['children']:
                print_tree(child, level + 1)

if workspace_x:
    print(f"Content of Workspace X from BACKUP:")
    print_tree(workspace_x)
else:
    # Try searching for any folder that might be X
    print("Workspace X not found as workspace type. Searching all folders...")
    # Search for a folder with children that has a name 'X'
    def find_any_x(node):
        if isinstance(node, dict):
            if node.get('name') == 'X': return node
            if 'children' in node:
                for child in node['children']:
                    res = find_any_x(child)
                    if res: return res
        return None
    any_x = find_any_x(data)
    if any_x:
        print_tree(any_x)
    else:
        print("Truly not found.")
