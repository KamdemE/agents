# gemini.google.com

**Category:** AI chat + image generation (Gemini Flash/Pro). **Account:** <primary@gmail.com> (Pro). **Profile:** `default`.

## Login

Same Google session as AI Studio — cookies persist in `default` profile. No fresh login usually needed.

## Interface Anatomy (Headless Agent Perspective)

### Main Layout
```
┌──────────────┬──────────────────────────────────┐
│   Sidebar    │          Chat Area                │
│              │                                  │
│ Nouvelle     │   [User messages]                │
│ discussion   │   [Gemini responses]             │
│              │   [Generated images]             │
│ History      │                                  │
│ (scrollable) │                                  │
│              ├──────────────────────────────────┤
│              │   Input bar:                     │
│              │   [+] [contenteditable] [Flash ▾]│
│              └──────────────────────────────────┘
└──────────────┘
```

### Key DOM Elements
| Element | Selector / How to find |
|---------|----------------------|
| **Input (text)** | `[contenteditable]` — the main chat input |
| **Send button** | NOT a standard button — dispatch `KeyboardEvent('keydown', {key:'Enter'})` on `[contenteditable]` |
| **+ button (Importation)** | `button[aria-label*="Importation"]` or `button[aria-label*="Ajouter"]` |
| **Menu items** | `[role=menuitem]` — first item is "Importer des fichiers" |
| **File input** | `input[type=file]` — appears AFTER clicking Importer, 2 inputs present |
| **Scrollable container** | `INFINITE-SCROLLER` (custom element) |
| **Model selector** | "Flash ▾" button in input bar (click to switch Flash/Pro) |
| **Image action buttons** | Below generated images: download, thumbs up/down, regenerate |
| **Generated images** | `img[alt*="généré par IA"]` — blob URLs (`blob:...`) |

### History sidebar
- Conversations listed with titles
- Click a title to load that conversation
- Uses `INFINITE-SCROLLER` for lazy loading

## Upload Files — THE Working Method

### ❌ DOES NOT WORK: `browser-drop-file`
Gemini uses Angular material file inputs. `browser-drop-file` targets JS drop zones, NOT `<input type=file>`. It will report `dropped:true` but the file is NOT accepted.

### ❌ DOES NOT WORK: `DOM.setFileInputFiles` via raw CDP
The file inputs are Angular-managed and may not respond to CDP file injection reliably.

### ✅ WORKS: DataTransfer pattern via `page-evaluate`

This is the ONLY reliable method discovered through extensive testing:

```python
import base64, json, subprocess

# 1. Open menu + click Importer to create file inputs
browser-proxy do page-click '{"profile":"default","target_id":"<TARGET_ID>","selector":"button[aria-label*=\"Importation\"]"}'
# Wait 2-3 seconds for menu + file inputs to appear
browser-proxy do page-evaluate '{"profile":"default","target_id":"<TARGET_ID>","expression":"document.querySelectorAll(\"input[type=file]\").length"}'
# Should return 2

# 2. Create DataTransfer payload via Python
with open('/path/to/image.png', 'rb') as f:
    b64 = base64.b64encode(f.read()).decode()

expr = f"var b64 = '{b64}'; var byteChars = atob(b64); var byteNums = new Array(byteChars.length); for(var i=0; i<byteChars.length; i++) byteNums[i] = byteChars.charCodeAt(i); var byteArray = new Uint8Array(byteNums); var blob = new Blob([byteArray], {{type: 'image/png'}}); var file = new File([blob], 'image.png', {{type: 'image/png'}}); var input = document.querySelector('input[type=file]'); var dt = new DataTransfer(); dt.items.add(file); input.files = dt.files; input.dispatchEvent(new Event('change', {{bubbles: true}})); 'uploaded ' + input.files.length + ' files'"

payload = json.dumps({'profile': 'default', 'target_id': '<TARGET_ID>', 'expression': expr})
with open('/tmp/upload.json', 'w') as f:
    f.write(payload)

# 3. Execute via browser-proxy
browser-proxy do page-evaluate /tmp/upload.json
# Result: "uploaded 1 files"
```

### For large files (>100KB base64)
Use Python to write the JSON payload to a file, then pass the file to `browser-proxy`:
```bash
python3 -c "
import base64, json
with open('image.jpg', 'rb') as f:
    b64 = base64.b64encode(f.read()).decode()
expr = \"var b64 = '\" + b64 + \"'; ...\"
payload = json.dumps({'profile': 'default', 'target_id': '...', 'expression': expr})
with open('/tmp/upload.json', 'w') as f:
    f.write(payload)
" && browser-proxy do page-evaluate /tmp/upload.json
```

### Upload sequence
1. Click `button[aria-label*="Importation"]`
2. Wait 1-3s for menu
3. Click `[role=menuitem]` item 0 ("Importer des fichiers")
4. Wait 2-3s for `input[type=file]` to appear (should be 2)
5. Write DataTransfer payload to `/tmp/upload.json`
6. `browser-proxy do page-evaluate /tmp/upload.json`
7. Verify: screenshot shows uploaded image thumbnail in input area

### ⚠️ CRITICAL: Re-open menu for EACH additional file
Each file requires its own Importer cycle:
```
click Importation → wait → click menuitem → wait for inputs → upload
```
The menu closes after each upload. You must re-click Importation for the next file.

## Send Prompts

### Text prompt
```bash
browser-proxy do page-type '{"profile":"default","target_id":"<TARGET_ID>","selector":"[contenteditable]","text":"Your prompt here"}'
```

### Submit (Enter key)
Gemini does NOT have a standard send button. You MUST dispatch Enter via JS:
```bash
browser-proxy do page-evaluate '{"profile":"default","target_id":"<TARGET_ID>","expression":"var input = document.querySelector(\"[contenteditable]\"); input.focus(); var ev = new KeyboardEvent(\"keydown\", {key: \"Enter\", code: \"Enter\", keyCode: 13, which: 13, bubbles: true, cancelable: true}); input.dispatchEvent(ev); \"sent\""}'
```

### Combined prompt + send
```bash
# Focus → Type → Enter (3 sequential calls)
browser-proxy do page-click-eval '{"profile":"default","target_id":"<TARGET_ID>","selector":"[contenteditable]"}'
browser-proxy do page-type '{"profile":"default","target_id":"<TARGET_ID>","selector":"[contenteditable]","text":"..."}'
browser-proxy do page-evaluate '{"profile":"default","target_id":"<TARGET_ID>","expression":"var input = document.querySelector(\"[contentallocable]\"); input.focus(); var ev = new KeyboardEvent(\"keydown\", {key: \"Enter\", code: \"Enter\", keyCode: 13, which: 13, bubbles: true, cancelable: true}); input.dispatchEvent(ev); \"sent\""}'
```

## Scrolling & Navigation

### Scroll to bottom (latest content)
```bash
browser-proxy do page-evaluate '{"profile":"default","target_id":"<TARGET_ID>","expression":"var sc = document.querySelector(\"INFINITE-SCROLLER\"); sc.scrollTop = sc.scrollHeight; \"scrolled\""}'
```

### Scroll to top
```bash
browser-proxy do page-evaluate '{"profile":"default","target_id":"<TARGET_ID>","expression":"var sc = document.querySelector(\"INFINITE-SCROLLER\"); sc.scrollTop = 0; \"scrolled\""}'
```

### Check scroll state
```bash
browser-proxy do page-evaluate '{"profile":"default","target_id":"<TARGET_ID>","expression":"var sc = document.querySelector(\"INFINITE-SCROLLER\"); \"scrollH=\" + sc.scrollHeight + \" scrollTop=\" + sc.scrollTop + \" clientH=\" + sc.clientHeight"}'
```

### Navigate to specific conversation (from sidebar)
```bash
browser-proxy do page-evaluate '{"profile":"default","target_id":"<TARGET_ID>","expression":"var items = document.querySelectorAll(\"li\"); var found = false; for(var i=0; i<items.length; i++) { if(items[i].textContent.includes(\"CONVERSATION_TITLE\")) { items[i].click(); found = true; break; } } found"}'
```

### Start new conversation
```bash
browser-proxy do page-navigate '{"profile":"default","target_id":"<TARGET_ID>","url":"https://gemini.google.com/app"}'
```

## Downloading Generated Images

### The Problem
Gemini stores generated images as **blob URLs** (`blob:https://gemini.google.com/...`). These are:
- ❌ NOT downloadable via JS `a.click()` (Edge blocks blob downloads from extension context)
- ❌ NOT downloadable via `browser-drop-file` or `browser-download`
- ✅ Extractable via canvas → base64 → Python file write

### The Working Method: Canvas → base64 → Python

```python
import subprocess, json, base64

TARGET_ID = "<TARGET_ID>"

# Step 1: Find all generated images
cmd = json.dumps(
    {
        "profile": "default",
        "target_id": TARGET_ID,
        "expression": 'var imgs = Array.from(document.querySelectorAll("img")).filter(function(i){return i.naturalWidth > 300 && i.src.indexOf("blob:") === 0}); JSON.stringify(imgs.map(function(i,idx){return {idx:idx, w:i.naturalWidth, h:i.naturalHeight}}))',
    }
)
r = subprocess.run(
    ["browser-proxy", "do", "page-evaluate", cmd], capture_output=True, text=True
)
images = json.loads(json.loads(r.stdout)["data"]["result"])


# Step 2: Extract specific image via canvas → base64
def extract_image(idx):
    # Convert to data URL in browser
    cmd_canvas = json.dumps(
        {
            "profile": "default",
            "target_id": TARGET_ID,
            "expression": f'var imgs = Array.from(document.querySelectorAll("img")).filter(function(i){{return i.naturalWidth > 300 && i.src.indexOf("blob:") === 0}}); var canvas = document.createElement("canvas"); canvas.width = imgs[{idx}].naturalWidth; canvas.height = imgs[{idx}].naturalHeight; canvas.getContext("2d").drawImage(imgs[{idx}], 0, 0); window.__ext = canvas.toDataURL("image/png").split(",")[1]; window.__ext.length',
        }
    )
    r = subprocess.run(
        ["browser-proxy", "do", "page-evaluate", cmd_canvas],
        capture_output=True,
        text=True,
    )
    length = json.loads(r.stdout)["data"]["result"]

    # Extract in chunks (base64 too large for single CDP call)
    b64 = ""
    for offset in range(0, length, 100000):
        cmd_chunk = json.dumps(
            {
                "profile": "default",
                "target_id": TARGET_ID,
                "expression": f"window.__ext.substring({offset}, {offset + 100000})",
            }
        )
        r3 = subprocess.run(
            ["browser-proxy", "do", "page-evaluate", cmd_chunk],
            capture_output=True,
            text=True,
        )
        b64 += json.loads(r3.stdout)["data"]["result"]

    return base64.b64decode(b64)


# Step 3: Save to file
raw = extract_image(0)  # idx of target image
with open("/tmp/output.png", "wb") as f:
    f.write(raw)
```

### Quick extraction script (batch)
See `scripts/presets/gemini-extract-images.py` for a reusable batch extractor.

### Image identification
- `img[alt*="généré par IA"]` = generated by Gemini
- `img[alt*="importée"]` = user-uploaded reference image
- Size: 1024x1024 = logo, 1024x687 or 1060x606 = banner/landscape
- Order in DOM = order of generation in conversation

## Conversation Flow Best Practices

### One brand per message
When generating multiple brands, send ONE brand at a time. Gemini sometimes mixes brands in a single generation if you ask for all at once.

### Follow-up corrections
Gemini maintains conversation context. You can say "regenerate the last image but..." and it will modify. But:
- Corrections accumulate context → start fresh conversation if too many rounds
- Sometimes it regenerates the SAME wrong thing → rephrase the correction completely

### Image generation timing
- Gemini Flash: ~10-20s per image
- Use tmux pane 2.0 for waits (`TMUX_TIMEOUT=45`)
- Never sleep-poll in agent shell

### Prompt patterns that work
```
"Generate a [STYLE] [FORMAT] of [SUBJECT]"
"[ACTION] the [Nth] image you just generated — [CORRECTION]"
"Look at the image above. Regenerate it but [CHANGE]"
```

### Prompt patterns that DON'T work
- Asking for 4+ images at once (mixes content)
- Vague descriptions ("make it nicer")
- Multiple corrections in one message (Gemini gets confused)

## New Conversation Workflow

```bash
# 1. Navigate to new chat
browser-proxy do page-navigate '{"profile":"default","target_id":"<TARGET_ID>","url":"https://gemini.google.com/app"}'
sleep 2

# 2. Upload reference images (cycle per image)
for img in image1.jpg image2.jpg; do
    # Click Importation
    browser-proxy do page-click '{"profile":"default","target_id":"<TARGET_ID>","selector":"button[aria-label*=\"Importation\"]"}'
    sleep 1
    # Click Importer des fichiers
    browser-proxy do page-evaluate '{"profile":"default","target_id":"<TARGET_ID>","expression":"var items = document.querySelectorAll(\"[role=menuitem]\"); if(items.length > 0) { items[0].click(); \"clicked\" } else { \"no menu\" }"}'
    sleep 2
    # Upload via DataTransfer
    python3 << 'PYEOF'
    # ... (write /tmp/upload.json with base64 payload)
    PYEOF
    browser-proxy do page-evaluate /tmp/upload.json
    sleep 2
done

# 3. Send prompt
browser-proxy do page-click-eval '{"profile":"default","target_id":"<TARGET_ID>","selector":"[contenteditable]"}'
browser-proxy do page-type '{"profile":"default","target_id":"<TARGET_ID>","selector":"[contenteditable]","text":"Generate..."}'
browser-proxy do page-evaluate '{"profile":"default","target_id":"<TARGET_ID>","expression":"var input = document.querySelector(\"[contenteditable]\"); input.focus(); var ev = new KeyboardEvent(\"keydown\", {key: \"Enter\", code: \"Enter\", keyCode: 13, which: 13, bubbles: true, cancelable: true}); input.dispatchEvent(ev); \"sent\""}'
```

## Gotchas & Anti-patterns

| Gotcha | Explanation |
|--------|------------|
| **Menu "no menu"** | The Importation menu takes 1-3s to appear. Always `sleep 1` after clicking, then check `[role=menuitem]`. If still empty, re-click Importation. |
| **"no file input"** | File inputs only appear AFTER clicking "Importer des fichiers" from the menu. The menu must be open first. |
| **Image upload shows but not in chat** | The DataTransfer `change` event may not propagate. Verify via screenshot — the image thumbnail should appear in the input area. |
| **Enter key not sending** | `new KeyboardEvent('keydown')` dispatched from `page-evaluate` sometimes doesn't trigger Gemini's handler. If it fails, try `page-press` with `key: "Enter"` instead. |
| **Generated images not in DOM** | Gemini lazy-loads images via `INFINITE-SCROLLER`. Scroll to bottom first, then check. Images may not appear until the response is fully loaded. |
| **Gemini re-generates wrong thing** | Too much accumulated context confuses it. Start a new conversation for clean generations. |
| **"Creating your image" stuck** | Image generation can take 30-40s. Use tmux wait, don't poll. |
| **Sidebar conversation not loading** | Gemini uses virtual scroll in sidebar. Search by title text, not by position. |
| **Model switched to wrong one** | The model selector resets on new conversations. Check "Flash ▾" or "Pro ▾" before generating. |
| **Send button CSS selector fails** | Gemini's send button is NOT a standard `<button>`. Only Enter key dispatch works. |

## Session Archive

Sessions logged here for full reopening if needed. Include Gemini conversation title + opencode session command.

### Logos et fonds , -Labs, ScienCurious, TechSkills

| Field | Value |
|-------|-------|
| **Date** | 2026-09-02 → 2026-09-03 |
| **Gemini conversation** | "Logos et fonds , -Labs, ScienCurious, TechS…" |
| **Resume opencode** | `opencode -s ses_f9c54b807ffehxrENU0l6YTiOz` |
| **What was done** | Full logo generation session: uploaded 5 original images to Gemini, generated clean line art logos ( hooded figure on laptop, -Labs lightbulb neural, ScienCurious cartoon character, TechSkills circuit lightbulb), generated abstract gradient banners for all 4 brands. Iterated on  logo (removed duplicate text, removed face features, corrected π sizing). Created comparison PDF. Installed bg removal tools (bgone, withoutbg, nobg, rembg). Generated 16 comparison images in `1/pure/`. Created k-browser Gemini site memory + 3 presets. |
| **Key learnings** | DataTransfer upload is the ONLY working method for Gemini file uploads. Enter key dispatch via JS is the ONLY send method. INFINITE-SCROLLER is the scrollable container. Canvas→base64 is the ONLY way to extract blob images. Gemini corrects accumulate context → start fresh conversation if too many rounds. One brand per message for clean generations. |
| **Output** | `~/Downloads/Logos/{_/0/1/pure/}` — full logo archive with originals, phase 0, series 1, and bg removal comparison |

