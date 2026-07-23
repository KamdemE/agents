import json

def find_workspace_nodes(nodes, target_id, current_path=[]):
    results = []
    for node in nodes:
        node_workspace_id = node.get("workspace_id")
        
        # Some nodes might be folders containing other nodes
        if node.get("type") == "folder":
            # If the folder itself is tagged with the workspace_id
            if node_workspace_id == target_id:
                results.append({
                    "type": "folder",
                    "name": node.get("name"),
                    "children": node.get("children", [])
                })
            else:
                # Recursively search children
                sub_results = find_workspace_nodes(node.get("children", []), target_id)
                if sub_results:
                    # If children belong to workspace, maybe this folder is a container?
                    # But usually Edge tags each node or the root folder.
                    results.extend(sub_results)
        elif node.get("type") == "url":
            if node_workspace_id == target_id:
                results.append({
                    "type": "url",
                    "name": node.get("name"),
                    "url": node.get("url")
                })
    return results

def main():
    target_id = "2711dd14-9022-4f80-9c7d-2f069f218f2c"
    with open("bookmarks_backup.json", "r") as f:
        data = json.load(f)
    
    roots = data.get("roots", {})
    all_workspace_items = []
    
    for root_name, root_node in roots.items():
        # Search everywhere in bookmarks
        found = find_workspace_nodes([root_node], target_id)
        if found:
            all_workspace_items.extend(found)
            
    print(json.dumps(all_workspace_items, indent=2))

if __name__ == "__main__":
    main()
