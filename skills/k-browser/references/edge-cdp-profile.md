# Edge CDP Profile Info

## How to get all profile info

### 1. From Local State file (fast, no browser needed)
```bash
python3 -c "
import json
with open('$HOME/.config/msedge-cdp/Local State') as f:
    d = json.load(f)
info = d.get('profile', {}).get('info_cache', {}).get('Default', {})
for k, v in info.items():
    print(f'{k}: {v}')
"
```

### 2. From the browser via chrome-agent-mcp
Navigate to `edge://settings/profiles` and extract from shadow DOM, or use `chrome.management` API.

### 3. Profile data directory
`~/.config/msedge-cdp/` — contains all profile state including Local State, Cookies, Extensions, etc.

## CDP Profile — Current State (2026-07-27)

### Identity
| Field | Value |
|-------|-------|
| Profile name | Profile 1 |
| User name | Ivann KAMDEM |
| Email | kapoivha@gmail.com |
| Account type | Microsoft (consumer: login.microsoftonline.com) |
| Tenant ID | 9188040d-6c67-4c5b-b112-36a304b66dad |
| GAIA ID | 873db2dd2dfe3ad2 |
| MUID | 06C737862E78658F336B20242FC764F0 |

### Account flags
| Field | Value |
|-------|-------|
| Sync enabled | true |
| Consented primary account | true |
| Ephemeral | false |
| Force signout state | 0 (none) |
| Previously signed in | false |
| Sign-in source | 19 |
| Edge account type | 1 |
| Edge account environment | 2 (login.microsoftonline.com) |
| Avatar picture | Edge Profile Picture.png |
| Use GAIA picture | true |
| Can be deleted | true |
| Can be edited | true |

### Extensions installed (8)

| # | Name | ID | Version | Type |
|:-:|------|----|---------|------|
| 1 | AdGuard AdBlocker | bgnkhhnnamicmpeenaelnjfhikgbkllg | 5.4.3.109 | normal |
| 2 | TickTick - Todo & Task List | diankknpkndanachmlckaikddgcehkod | 1.2.1.2 | normal |
| 3 | Dark Reader | eimadpbcbfnmbkopoojfekhnkhdbieeh | 4.9.129 | normal |
| 4 | Avast Online Security & Privacy | fdgpikaaheckgdijjmepmdjjkbceakif | 22.11.179 | normal |
| 5 | Google Docs Offline | ghbmnnjooekpmoecnnnilnnbdlolhkhi | 1.108.1 | sideload |
| 6 | Bitwarden Password Manager | jbkfoedolllekgbhcbcoahefnbanhhlh | 2026.7.0 | normal |
| 7 | AI Exporter | kagjkiiecagemklhmhkabbalfpbianbe | 4.3.5 | normal |
| 8 | Translate - Translator, Dictionary, TTS | mnlohknjofogcljbcknkakphddjpijak | 1.4.11 | normal |

### Permissions per extension

#### AdGuard AdBlocker
`contextMenus`, `cookies`, `declarativeNetRequest`, `declarativeNetRequestFeedback`, `devtools`, `scripting`, `storage`, `tabs`, `unlimitedStorage`, `userScripts`, `webNavigation`, `webRequest`

#### TickTick
`contextMenus`, `cookies`, `scripting`, `sidePanel`, `storage`, `tabs`

#### Dark Reader
`alarms`, `fontSettings`, `scripting`, `storage`

#### Avast Online Security
`storage`, `tabs`, `webNavigation`, `webRequest`, `webRequestBlocking`

#### Google Docs Offline
`alarms`, `offscreen`, `storage`, `unlimitedStorage`

#### Bitwarden Password Manager
`activeTab`, `alarms`, `clipboardRead`, `clipboardWrite`, `contextMenus`, `idle`, `notifications`, `offscreen`, `scripting`, `sidePanel`, `storage`, `tabs`, `unlimitedStorage`, `webNavigation`, `webRequest`, `webRequestAuthProvider`

#### AI Exporter
`contextMenus`, `cookies`, `declarativeNetRequest`, `sidePanel`, `storage`, `tabs`

#### Translate
`contextMenus`, `storage`, `tabs`

## Browser info
| Field | Value |
|-------|-------|
| Engine | Edge Chromium 150.0.0.0 |
| Platform | Linux x86_64 |
| Language | en-US |
| User Agent | `Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0` |
| Data dir | `~/.config/msedge-cdp/` |

## CLI to get profile info quickly
```bash
python3 -c "
import json
with open('$HOME/.config/msedge-cdp/Local State') as f:
    d = json.load(f)
p = d.get('profile', {}).get('info_cache', {}).get('Default', {})
print('Name:', p.get('gaia_name', p.get('name', '?')))
print('Email:', p.get('user_name', '?'))
print('Sync:', p.get('edge_sync_enabled', '?'))
print('Edge Account Type:', p.get('edge_account_type', '?'))
print('CDP Port: 9222')
"
```
