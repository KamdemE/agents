# 📧 m365 CLI — Microsoft 365 from the Terminal

> Access Outlook mail, calendar, and OneDrive from the terminal via the Microsoft Graph API.

I wanted to read and manage my Outlook (`ivann.kamdem@hotmail.com`) and Polytechnique mail from the terminal — without a browser-first workflow. Microsoft has an official CLI for this: `@pnp/cli-microsoft365`. It uses device-code OAuth, which means it prints a URL and a code, you paste the code in a browser once, and after that the CLI handles the rest via stored tokens.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      m365 CLI                                │
│                                                              │
│   ┌──────────────────┐    ┌────────────────────────────┐    │
│   │  Azure App Reg.  │    │   Microsoft Graph API      │    │
│   │  (App ID+Tenant) │    │   graph.microsoft.com      │    │
│   │                  │───▶│                            │    │
│   │  Personal MS     │    │   /me/messages             │    │
│   │  accounts type   │    │   /me/calendar/events      │    │
│   │  Public client   │    │   /me/drive/root           │    │
│   └──────────────────┘    └────────────────────────────┘    │
│              │                                               │
│   Device Code Flow (once):                                   │
│   m365 login --authType deviceCode                           │
│   → open URL, paste code, tokens stored locally              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Install

```bash
npm install -g @pnp/cli-microsoft365
m365 --version
```

Uses the npm global prefix (`~/.npm-global`). Installed once, auto-updates via `npm install -g @pnp/cli-microsoft365@latest`.

---

## 🔑 Azure App Registration

This is the one-time setup that links the CLI to your Microsoft account.

### Step-by-step (do this once)

1. Go to `https://portal.azure.com` → **Azure Active Directory** → **App registrations** → **New registration**
2. Name: `m365-cli`
3. **Supported account types:** keep your existing working app registration (do not rotate IDs unless required)
4. **Redirect URI:** leave empty (device code flow doesn't need it)
5. Click **Register**
6. Note the **Application (client) ID** and **Directory (tenant) ID** — store them in Bitwarden `GLOBAL_ENV_VARS`
7. Go to **Authentication** → enable **"Allow public client flows"** → Save

```
Azure Portal setup:
  New App Registration
       ↓
  Existing m365 app registration (appId + tenant routing)
       ↓
  Authentication → Allow public client flows   ← required for device code flow
       ↓
  Note App ID + Tenant ID → store in GLOBAL_ENV_VARS
```

### Store credentials in Bitwarden

```bash
# Add to GLOBAL_ENV_VARS secure note in Bitwarden:
CLIMICROSOFT365_APPID=<your-app-id>
CLIMICROSOFT365_TENANT=<your-tenant-id>
```

After adding, re-inject: `bw-env unlock`.

---

## 🔐 Authentication

```bash
# Stability toggles (prevents browser/clipboard callback issues in some Linux sessions)
m365 cli config set --key autoOpenLinksInBrowser --value false
m365 cli config set --key copyDeviceCodeToClipboard --value false

# Known-working pattern in this environment
m365 login --authType deviceCode --appId <your-app-id> --tenant consumers
```

Output:
```
To sign in, use a web browser to open the page https://microsoft.com/devicelogin
and enter the code XXXXXXXX to authenticate.
```

Open the URL in a browser, paste the code, sign in with your Microsoft account. Done — tokens are cached locally and refreshed automatically.

```bash
# Verify connection metadata
m365 status --output json

# Deep diagnostics when login fails
m365 login --authType deviceCode --appId <your-app-id> --tenant consumers --debug
```

Note: `m365 status` may show `"connectedAs": ""` even when reads work. Validate with:

```bash
m365 request --url "https://graph.microsoft.com/v1.0/me" --method get --output json
```

On personal MSA, `--folderName Inbox` may return `[]` while `m365 outlook message list` (no folder) still returns mail — use `/me` or list without folder.

---

## 📬 Mail (Outlook)

### List messages

```bash
# Latest messages from Inbox
m365 outlook message list --folderName Inbox --output json

# Latest 10 only (JMESPath slicing on command output)
m365 outlook message list --folderName Inbox --output json --query "[0:10].{subject:subject,from:from.emailAddress.address,receivedDateTime:receivedDateTime,isRead:isRead}"
```

### Read a message

```bash
# Get message ID first, then read body
m365 outlook message list --folderName Inbox --output json --query "[0:5].{id:id,subject:subject}" | python3 -c "
import json,sys
msgs = json.load(sys.stdin)
for m in msgs: print(m['id'][:20], '...', m['subject'])
"

m365 outlook message get --id <message-id>
```

### Send a message

```bash
m365 outlook mail send \
  --to recipient@example.com \
  --subject "Hello from m365 CLI" \
  --bodyContents "Message body here"
```

**⚠️ Send-as limitation for personal accounts:** The Graph API blocks `from` override for personal Microsoft/Hotmail accounts. You cannot send as `ivann.kamdem-pouokam@polytechnique.edu` via m365 unless:
- You set up a **connected account** in Outlook settings (Settings → Sync email → Connected accounts → Zimbra SMTP), OR
- You use direct Zimbra SMTP via another mail client.

The `from` parameter is rejected with HTTP 403 for personal accounts without Exchange/Office365 admin rights.

---

## 📅 Calendar

```bash
# List upcoming events
m365 outlook event list --query '$top=10&$select=subject,start,end,location'

# Events in a date range
m365 outlook event list \
  --query '$filter=start/dateTime ge '"'"'2026-03-22T00:00:00'"'"'&$top=20'

# Create an event
m365 outlook event add \
  --subject "Meeting" \
  --startTime "2026-03-25T14:00:00" \
  --endTime "2026-03-25T15:00:00"
```

---

## 💾 OneDrive

```bash
# List root files
m365 onedrive list

# List files in a folder
m365 onedrive list --folderUrl "/Documents"

# Get a file's info
m365 file get --webUrl "https://onedrive.live.com/..."

# Download a file
m365 onedrive item get --itemId <id> --output json
```

---

## 🔧 Raw Graph API calls

For anything the CLI doesn't expose natively:

```bash
m365 request \
  --url "https://graph.microsoft.com/v1.0/me/messages" \
  --method get

# With filters
m365 request \
  --url "https://graph.microsoft.com/v1.0/me/messages?\$filter=isRead eq false&\$top=5" \
  --method get
```

This is the escape hatch — full Graph API access through the CLI's auth context.

---

## 🗺️ Credentials stored in Vault

| Variable | Purpose | Vault location |
|---|---|---|
| `CLIMICROSOFT365_APPID` | Azure App ID | `GLOBAL_ENV_VARS` |
| `CLIMICROSOFT365_TENANT` | Azure Tenant ID | `GLOBAL_ENV_VARS` |

Tokens (OAuth refresh) are cached locally by the CLI (v11+) at:

- `$HOME/.cli-m365-msal.json` (MSAL cache)
- `$HOME/.cli-m365-connection.json` (active connection)
- `$HOME/.cli-m365-all-connections.json` (named connections)

These are not stored in Bitwarden. Access tokens (~1 h) refresh automatically while the refresh token is valid (~**90 days** idle for MSA `consumers` — Microsoft policy, not CLI-configurable).

**Persist CLI defaults once:**

```bash
m365 cli config set --key authType --value deviceCode
m365 cli config set --key tenantId --value consumers
```

**If tokens expire or become invalid:**

```bash
m365 logout
m365 login --authType deviceCode --tenant consumers
```

Do **not** rely on `rm -rf ~/.config/m365` / `~/.local/share/m365/` (obsolete paths on v11).
