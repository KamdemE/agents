# Cloudflare Access SSO & Zero Trust Architecture

> **Domain:** `<github-user>.com` · **SSO Realm:** `<github-user>.cloudflareaccess.com`  
> **Account ID:** `5d0ff5e40bbc37baed99d3c7aacd0741` · **Zone ID:** `255f60d9f77924ac016c194300dbeb3c`

## Identity Providers (IdPs)

Callback URL: `https://<github-user>.cloudflareaccess.com/cdn-cgi/access/callback`

| Provider | Type | IdP ID | Configuration |
|----------|------|--------|---------------|
| **Google** | `google` | `a4c9264c-5736-4a9d-9cb9-4dab305aae13` | Client ID: `747851806672-ncbjr8e18gtdbonupcfgmh1j1d961q69.apps.googleusercontent.com` (GCP `<github-user>`), PKCE enabled |
| **OTP** | `onetimepin` | `a0756076-653c-4fb1-8747-626f216ac615` | Email 6-digit PIN fallback |

---

## Access Policy (`Admins`)

- **Policy ID:** `d6f8ccdd-6f8f-4780-b8ca-0756e7fb7415`
- **Name:** `Admins`
- **Decision:** `allow`
- **Session Duration:** **`24h`** (updated 2026-09-04)
- **Authorized Emails (`include` list):**
  1. `<primary@gmail.com>`
  2. `<school@polytechnique.edu>`
  3. `<personal@hotmail.com>`

---

## Protected Self-Hosted Applications (6 Apps)

All 6 applications share the `Admins` policy and `24h` session duration:

| Application Name | Protected Domain | App ID (`aud`) | Session Duration | App Launcher Visible |
|------------------|------------------|----------------|------------------|----------------------|
| **Live** | `live.<github-user>.com` | `e357ae18-f222-4822-a9b0-466d7ad4fae3` | `24h` | `true` |
| **AI** | `ai.<github-user>.com` | `a780fa9e-64c8-4775-bd74-e35f4955a5b5` | `24h` | `true` |
| **Mail** | `mail.<github-user>.com` | `6facdf2f-272c-4850-b946-15c89d702639` | `24h` | `true` |
| **Whatsapp** | `whats.<github-user>.com` | `7841ab7c-6aae-4cb1-88de-833c8bb153c5` | `24h` | `true` |
| **Ticktick** | `tick.<github-user>.com` | `cddce1a8-ed7b-4a9b-b312-590b0bb6f0e3` | `24h` | `true` |
| **Sentinel** | `sentinel.<github-user>.com` | `aecc7276-2c47-47e3-8936-0cce3aae3a89` | `24h` | `true` |

---

## API Management Patterns (`curls`)

```bash
# List all Access Applications
with-env curls -p cloudflare 'https://api.cloudflare.com/client/v4/accounts/5d0ff5e40bbc37baed99d3c7aacd0741/access/apps'

# List Access Policies
with-env curls -p cloudflare 'https://api.cloudflare.com/client/v4/accounts/5d0ff5e40bbc37baed99d3c7aacd0741/access/policies'

# Create a new Access App (HITL prompt y/N in tmux)
cp $HOME/.agents/skills/k-cloudflare/assets/templates/template-access-app.json /tmp/app-new.json
# Edit /tmp/app-new.json
with-env curls -p cloudflare -X POST 'https://api.cloudflare.com/client/v4/accounts/5d0ff5e40bbc37baed99d3c7aacd0741/access/apps' -H 'Content-Type: application/json' -d @/tmp/app-new.json
```
