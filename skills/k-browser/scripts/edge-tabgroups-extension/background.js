// Edge Tab Groups Explorer — KπX k-browser
// Lit la structure complète : workspaces > groupes > tabs
// Usage: ouvrir chrome-extension://<id>/manifest.json puis evaluer JS

async function getTree() {
  const [groups, wins, tabs] = await Promise.all([
    chrome.tabGroups.query({}),
    chrome.windows.getAll({populate: true}),
    chrome.tabs.query({})
  ]);

  const result = [];
  for (const w of wins) {
    const wt = tabs.filter(t => t.windowId === w.id);
    const win = {id: w.id, type: w.type, groups: [], solo: []};

    for (const g of groups.filter(g => g.windowId === w.id)) {
      win.groups.push({
        title: g.title, color: g.color, collapsed: g.collapsed,
        tabs: wt.filter(t => t.groupId === g.id).map(t => ({
          id: t.id, title: t.title || '', url: t.url || ''
        }))
      });
    }

    win.solo = wt.filter(t => t.groupId === -1).map(t => ({
      id: t.id, title: t.title || '', url: t.url || ''
    }));

    result.push(win);
  }

  return result;
}

async function getContent(tabIds) {
  const results = [];
  for (const id of tabIds) {
    try {
      const [r] = await chrome.scripting.executeScript({
        target: {tabId: id},
        func: () => document.body?.innerText?.trim()?.slice(0, 5000) || ''
      });
      results.push({id, content: (r?.result || '').slice(0, 3000)});
    } catch {
      results.push({id, content: '[unreadable]'});
    }
  }
  return results;
}

chrome.runtime.onInstalled.addListener(async () => {
  await chrome.storage.local.set({tree: await getTree()});
});
chrome.action.onClicked.addListener(async () => {
  await chrome.storage.local.set({tree: await getTree()});
});
