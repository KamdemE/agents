import json, base64, re

def reconstruct():
    path = '/home/kpihx/Work/Others/edge_restore/stage_2026-05-03_22-49-33/home/kpihx/.config/microsoft-edge/Default/Workspaces/workspace_cache_2711dd14-9022-4f80-9c7d-2f069f218f2c'
    with open(path, 'r') as f:
        data = json.load(f)

    raw_bytes = base64.b64decode(data['Fluid_Data'])

    # 1. Extract all URLs and their titles if possible
    # We saw titles follow the URL with some bytes in between.
    url_pattern = re.compile(b'https?://[^\x00\x22\x27\x20\x3e\x3c]+')
    tabs = []
    for m in url_pattern.finditer(raw_bytes):
        url = m.group().decode('ascii', errors='ignore')
        # Look for title in the next 100 bytes
        ctx = raw_bytes[m.end():m.end()+150]
        title = ""
        # Look for the length-prefixed string pattern we saw: \x0e\x00\x00\x00\x06\x00\x00\x00Zimbra
        title_match = re.search(b'\x00\x00\x00([\x01-\x7f])\x00\x00\x00([\x20-\x7e\xc2-\xdf][\x80-\xbf\x20-\x7e]+)', ctx)
        if title_match:
            length = title_match.group(1)[0]
            candidate = title_match.group(2)
            if len(candidate) >= length:
                title = candidate[:length].decode('utf-8', errors='ignore')
        
        # Fallback to URL-based title if title is empty or junk
        if not title or len(title) < 2:
            if 'zimbra' in url.lower(): title = "Zimbra"
            elif 'moodle' in url.lower(): title = "Moodle"
            elif 'jobteaser' in url.lower(): title = "JobTeaser"
            elif 'notebooklm' in url.lower(): title = "NotebookLM"
            elif 'colab' in url.lower(): title = "Colab"
            elif 'linkedin' in url.lower(): title = "LinkedIn"
            else: title = url.split('//')[-1].split('/')[0]
            
        tabs.append({'url': url, 'title': title})

    # 2. Group tabs by logic (Manual + Heuristic)
    folders = {
        "Optimation & Controle": [],
        "Analyse fonctionnelle": [],
        "Algos pour l'analyse de données en Python": [],
        "Internships / Stage 2A": [],
        "Mail (Zimbra)": [],
        "Admin (CAF / Ameli)": [],
        "Autres (Anglais / IME)": []
    }
    orphans = []

    for tab in tabs:
        u = tab['url'].lower()
        t = tab['title'].lower()
        
        if 'zimbra' in u or 'webmail' in u:
            folders["Mail (Zimbra)"].append(tab)
        elif 'caf.fr' in u or 'ameli' in u or 'impots.gouv' in u:
            folders["Admin (CAF / Ameli)"].append(tab)
        elif 'jobteaser' in u or 'google.com/about/careers' in u or 'linkedin.com' in u or 'welcometothejungle' in u or 'x-jobboard' in u:
            folders["Internships / Stage 2A"].append(tab)
        elif 'optimation' in t or 'optimisation' in u or 'optim' in u:
            folders["Optimation & Controle"].append(tab)
        elif 'analyse fonctionnelle' in t or 'analyse' in u:
            folders["Analyse fonctionnelle"].append(tab)
        elif 'python' in u or 'algos' in u or 'td6' in u or 'td5' in u:
            folders["Algos pour l'analyse de données en Python"].append(tab)
        elif 'anglais' in u or 'espagnol' in u or 'ime' in u:
            folders["Autres (Anglais / IME)"].append(tab)
        else:
            # Check if it fits anywhere else
            if 'moodle' in u:
                # Distribute Moodle tabs to courses if possible
                folders["Autres (Anglais / IME)"].append(tab)
            elif 'notebooklm' in u:
                folders["Optimation & Controle"].append(tab)
            else:
                orphans.append(tab)

    # 3. Clean up duplicates within folders
    for f in folders:
        seen = set()
        unique = []
        for tab in folders[f]:
            if tab['url'] not in seen:
                unique.append(tab)
                seen.add(tab['url'])
        folders[f] = unique

    # 4. Generate Markdown Tree
    with open('workspace_x_architecture_tree.md', 'w', encoding='utf-8') as f:
        f.write("# Architecture de Workspace X (Backup 22:49)\n\n")
        f.write("## Dossiers et Onglets\n\n")
        
        for folder_name, folder_tabs in folders.items():
            if not folder_tabs: continue
            f.write(f"### 📂 {folder_name}\n")
            for tab in folder_tabs:
                f.write(f"- 📄 [{tab['title']}]({tab['url']})\n")
            f.write("\n")
            
        if orphans:
            f.write("## 🔗 Onglets Orphelins\n")
            seen = set()
            for tab in orphans:
                if tab['url'] not in seen:
                    f.write(f"- 📄 [{tab['title']}]({tab['url']})\n")
                    seen.add(tab['url'])

reconstruct()
