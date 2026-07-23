import json

bookmarks_path = "/home/kpihx/.config/microsoft-edge/Profile 2/Bookmarks"

with open(bookmarks_path, 'r') as f:
    data = json.load(f)

def find_workspace_x(node):
    if isinstance(node, dict):
        if node.get('name') == 'X' and node.get('type') == 'workspace':
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
    print(f"Content of Workspace X (ID: {workspace_x.get('workspace_id')}):")
    print_tree(workspace_x)
else:
    print("Workspace X not found in Bookmarks.")
