# Scraping Methodology — browser-proxy + CLI Hybrid

> **Scope:** Generic, abstract scraping methodology combining browser-proxy (session, cookies, AJAX) with CLI tools (curl, wget) for bulk data extraction. No concrete site references — patterns only.

---

## 1. Reconnaissance — Understand the target site

Before writing any scraper, answer these questions by observing the live site:

| Question | How to answer |
|----------|---------------|
| **Is there a gate?** (age verification, login, consent) | Open the URL in a browser tab. Does the content load immediately or is there an overlay/modal? |
| **How is pagination implemented?** | Scroll to the bottom of search results. Inspect the pager DOM. Note the URL pattern (`/path/pageN.html` vs AJAX). |
| **Are search results AJAX-loaded?** | Open DevTools Network tab, filter XHR/Fetch. Note the endpoint, headers (especially `X-Requested-With`), and response format (JSON with embedded HTML vs pure JSON). |
| **What identifies a listing?** | Inspect the DOM for a repeating pattern: anchor tags with a unique URL structure (e.g., `/type/NAME-ID/`). Note the CSS class or attribute on the link. |
| **What data is on the listing page vs the detail page?** | Compare: what's visible in the search results card vs what's only on the individual listing page. Decide if detail pages are needed. |
| **Rate limits?** | Make 10+ rapid requests. If HTTP 429 or empty responses appear, the site rate-limits. Note the threshold. |

---

## 2. Cookie & Session Management

### 2.1 — Gates (age verification, consent, login)

Most gates set a simple cookie after validation. The strategy:

1. **Open an InPrivate window** (fresh context, no prior state):
   ```
   browser-proxy do window-create '{"profile":"default","incognito":true,"layout":[{"type":"tab","url":"<target_url>"}]}'
   ```
2. **Let the human validate the gate** (password, 2FA, captcha — agent never touches secrets).
3. **Extract the cookie** from the validated session:
   ```
   browser-proxy do page-evaluate '{"profile":"default","target_id":"<id>","expression":"document.cookie"}'
   ```
4. **Test the cookie** with a single curl request before mass download:
   ```
   curl -s -o /dev/null -w "%{http_code} %{size_download}" "<url>" -H "Cookie: <cookie_string>" -H "User-Agent: <ua>"
   ```
   If HTTP 200 and reasonable size → cookie works. If 429 or empty → rate-limited or cookie expired.

### 2.2 — InPrivate window rules

- `window-create` with `incognito: true` → creates a fresh private context.
- `tab-create` with `incognito: true` → creates a **separate** per-call incognito context (mutually exclusive with `window_id`).
- `tab-create` with `window_id` only (no `incognito`) → adds a normal tab to an existing window.
- **Never** mix `incognito: true` + `window_id` in the same `tab-create` call — it silently does nothing.

### 2.3 — Cookie lifecycle

- InPrivate cookies expire when the window closes.
- Some sites set HttpOnly cookies invisible to `document.cookie` — use CDP `Network.getAllCookies` for full access.
- If the site rate-limits mid-scrape: close the InPrivate window, open a new one, re-validate the gate, get fresh cookies.

---

## 3. URL Extraction — Discovering the listing catalog

### 3.1 — AJAX pagination (most common for search results)

Many sites load search results via AJAX. The key difference from regular page loads:

```
Regular fetch:    GET /search/page1.html          → HTML (may require session cookies to not show gate)
AJAX fetch:       GET /search/page1.html
                  Header: X-Requested-With: XMLHttpRequest  → JSON { "content": "<html>...</html>" }
```

**Extraction flow (browser-side, zero polling):**

```javascript
// Store all unique URLs across all pages
window._urls = [];
window._done = false;

(async () => {
  const base = "/search/path/...";
  for (let p = 0; p < 100; p++) {
    const url = p === 0 ? base : base + "page" + p + ".html";
    const r = await fetch(url, {
      headers: { "X-Requested-With": "XMLHttpRequest" }
    });
    if (!r.ok) break;
    const j = await r.json();          // JSON response
    const h = j.content || "";          // HTML embedded in JSON
    const m = h.match(/\/listing-type\/[^"\/]+-[0-9]+\//g);  // Extract listing URLs
    if (!m) break;
    const unique = [...new Set(m)];
    const newUrls = unique.filter(u => !window._urls.includes(u));
    if (newUrls.length === 0) break;    // No new URLs = last page
    newUrls.forEach(u => window._urls.push(u));
    if (unique.length < 3) break;       // Near-empty page = end of data
  }
  window._done = true;
})();
```

**Key insight:** The pagination URL pattern for AJAX may differ from the regular pager links. Test by fetching `base + "page1.html"` with and without the AJAX header — if one returns JSON and the other returns HTML, use the JSON one.

### 3.2 — Dumping URLs from browser to filesystem

The browser's JS context can't write files directly. Dump in batches:

```bash
for i in 0 200 400 600 ...; do
  browser-proxy do page-evaluate "{
    \"profile\":\"default\",
    \"target_id\":\"<id>\",
    \"expression\":\"window._urls.slice($i,$((i+200))).join(\\\"\\\\n\\\")\"
  }" 2>/dev/null | python3 -c "
import sys,json
d=json.load(sys.stdin)
r=d.get('data',{}).get('result','')
if r: open('/tmp/urls_${i}.txt','w').write(r)
"
done
# Then concatenate and deduplicate
python3 -c "
import glob
urls = []
for f in sorted(glob.glob('/tmp/urls_*.txt')):
    urls.extend(open(f).read().splitlines())
seen = set(); unique = []
for u in urls:
    if u and u not in seen: seen.add(u); unique.append(u)
open('/tmp/all_urls.txt','w').write('\n'.join(unique)+'\n')
print(f'{len(unique)} unique URLs')
"
```

---

## 4. Bulk Download — browser fetch vs curl vs wget

### 4.1 — Decision matrix

| Factor | Browser fetch | curl | wget |
|--------|:---:|:---:|:---:|
| Cookies auto-included | ✅ | ❌ (manual) | ❌ (manual) |
| Parallelism | Limited by JS memory | High (threads) | Moderate (jobs) |
| Rate-limit resistance | Better (same session) | Needs fresh cookies | Same as curl |
| Large responses (>1MB) | ❌ JS memory overflow | ✅ | ✅ |
| URL encoding handled | ✅ | ❌ (manual encode) | ❌ |
| Best for | Small batches, session-heavy | Bulk download | Single large files |

### 4.2 — curl bulk download with proper URL encoding

```python
from urllib.parse import quote
import subprocess, os
from concurrent.futures import ThreadPoolExecutor, as_completed


def download_one(base_url, cookie, ua, url, outdir):
    # Encode URL path segments (keep / and -)
    parts = url.strip("/").split("/")
    encoded = "/".join(quote(p, safe="") for p in parts)
    full_url = f"{base_url}/{encoded}/"

    filename = url.strip("/").replace("/", "_").replace(" ", "_")
    outfile = f"{outdir}/{filename}.html"

    r = subprocess.run(
        [
            "curl",
            "-s",
            "-o",
            outfile,
            full_url,
            "-H",
            f"Cookie: {cookie}",
            "-H",
            f"User-Agent: {ua}",
            "--max-time",
            "30",
        ],
        capture_output=True,
        timeout=35,
    )
    size = os.path.getsize(outfile) if os.path.exists(outfile) else 0
    if size > 1000:
        return True
    else:
        os.remove(outfile) if os.path.exists(outfile) else None
        return False
```

### 4.3 — Throttling strategy

```
Phase 1: Test     → 1 request, verify cookie + response
Phase 2: Warm-up  → 5 sequential requests with 2s delay
Phase 3: Ramp     → 3 parallel, batch of 5, 3s between batches
Phase 4: Sustain  → 5 parallel, batch of 10, 2s between batches
```

If HTTP 429 appears at any phase → **STOP immediately**. Get fresh cookies (new InPrivate window), restart from Phase 1.

### 4.4 — The hybrid approach (recommended)

1. **Browser** → extract all listing URLs (AJAX pagination with session cookies)
2. **curl** → download individual listing pages in parallel (fresh cookies, throttled)
3. **Python** → parse downloaded HTML, extract structured data

---

## 5. Post-Download Analysis

### 5.1 — Extracting structured data from HTML

```python
import re

with open("listing.html", errors="ignore") as f:
    content = f.read()

# Title
title = re.search(r"<title>([^<]+)</title>", content)

# Phone numbers (various formats)
phones = re.findall(
    r"(?:tel|tél|phone|mobile|whatsapp|sms)[\s:]*"
    r"([0-9][\s.\-()0-9]{8,})",
    content,
    re.IGNORECASE,
)
# Standalone national patterns
phones2 = re.findall(
    r"(?<!\d)(?:\+?\d{1,3}[\s.\-]?)?\d{2}[\s.\-]?\d{2}[\s.\-]?\d{2}[\s.\-]?\d{2}[\s.\-]?\d{2}(?!\d)",
    content,
)

# Context around a keyword (for semantic analysis)
for m in re.finditer(r"keyword", content, re.IGNORECASE):
    ctx = content[max(0, m.start() - 200) : m.end() + 200]
    clean = re.sub(r"<[^>]+>", " ", ctx)  # Strip HTML tags
    clean = re.sub(r"\s+", " ", clean)
```

### 5.2 — Semantic filtering (beyond simple grep)

A keyword appearing in text doesn't mean the listing offers it. Context matters:

| Pattern | Meaning |
|---------|---------|
| `keyword + price/supplement` | ✅ Offered (with extra cost) |
| `keyword + available/possible` | ✅ Offered |
| `❌ keyword / tabou keyword / interdit keyword` | ❌ Forbidden |
| `keyword + condition/si hygiène` | ⚠️ Conditionally offered |
| `keyword` in physical description | ℹ️ Not a service (just descriptive) |

Always extract ±200 chars around each keyword match, strip HTML, and classify the context before including/excluding a listing.

---

## 6. Anti-Detection & Best Practices

| Practice | Why |
|----------|-----|
| **Rotate User-Agent** | Mimic a real browser UA string |
| **Respect robots.txt** | Legal and ethical baseline |
| **Throttle requests** | 429 means you're detected — slow down or rotate session |
| **Use InPrivate for each session** | Clean cookies, no cross-contamination |
| **Never store secrets** | Cookies/tokens in variables, never printed or logged |
| **Name files by unique ID** | From the URL slug, not the human-readable title (which may contain special chars) |
| **Log progress** | Print batch count, OK/fail ratio, total bytes — makes debugging trivial |
