---
name: k-napkin
description: >
  Napkin AI visual generation — infographics (SVG/PNG/PPT) from text, via direct API calls (no MCP).
  Visual types: mindmap, flowchart, timeline, comparison, hierarchy, cycle, list, matrix.
  Load before any Napkin AI visual generation request. Use when asked to generate visuals,
  diagrams, infographics, or any visual communication from text or markdown content.
license: private
metadata:
  author: KpihX
  version: "1.1.0"
  scope: tool-integration
  api-version: v0.10.5
allowed-tools: Bash
---

# k-napkin

**⚠️ WHEN EDITING THIS FILE, YOU MUST ALSO UPDATE THE HEADER (VERSION, ETC.) AND THE FOOTER (CHANGELOG).**

> **Strategy:** skill-only (no MCP) — API in developer preview, occasional use.
> Claude calls the API directly via `curl` + `python3`. Zero overhead when not in use.
>
> **Core function:** `scripts/napkin_gen.sh` — source it in any generation script.
> **Generation examples:** `scripts/` — one `.sh` per visual type (good usage) + `BAD_comparison_4agents.sh` (bad usage documented).
> **Visual outputs:** `assets/examples/` — real renders for visual reference.

## Auth & Quota

```bash
# NAPKIN_API_KEY must be loaded via bw-env (login shell)
echo ${NAPKIN_API_KEY:0:8}...   # verify loaded
```

| Item | Value |
|------|-------|
| Base URL | `https://api.napkin.ai` |
| Auth | `Authorization: Bearer $NAPKIN_API_KEY` |
| Free plan | **500 credits / week** |
| Cost per visual | ~80 credits (≈ 6 visuals/week free) |
| Rate limit | **2 req / second** → always `sleep 1` between submissions |
| Max poll time | 300s (5 min) |
| Variants per request | 1–4 (`number_of_visuals`) |

**Key gotchas:**
- `HEAD /v1/visual/test → 404` = key valid. But **HTTP 402 = out of credits** — auth and billing are separate.
- `status` is a **reserved zsh variable** → use `vstatus` in zsh scripts.
- Use **`--arg`** (not `--rawfile`) with jq: `--rawfile` embeds literal newlines → API rejects silently (status: failed, no error). `--arg` encodes as `\n` → accepted.
- Use **python3** (not jq) to parse responses: API echoes multiline content back unescaped → jq parse error.
- **File download requires Authorization header** — files at `/v1/visual/{id}/file/{file-id}` are not public.

## API Workflow

```
POST /v1/visual           → { id, status: "pending" }
        ↓ sleep 1 (rate limit)
GET  /v1/visual/{id}/status  → { status: "completed", generated_files: [{ url }] }
        ↓ curl -H "Authorization: Bearer $NAPKIN_API_KEY"
~/Pictures/Napkin/{type}_{time}.{fmt}
```

## Generate + Poll + Download (zsh function)

```zsh
napkin_generate() {
  local content_file="$1"  # path to .md file
  local vtype="$2"         # mindmap|flowchart|timeline|comparison|hierarchy|cycle|list|matrix
  local fmt="${3:-svg}"    # svg|png|ppt
  local outdir="${4:-$HOME/Pictures/Napkin}"
  local lang="${5:-en}"    # BCP 47: en, fr, en-US, fr-FR...
  local resp id vstatus poll fname

  mkdir -p "$outdir"
  sleep 1  # rate limit: 2 req/s

  # --arg encodes newlines as \n → API accepts (NOT --rawfile)
  local content body
  content=$(<"$content_file")
  body=$(jq -n \
    --arg c "$content" --arg fmt "$fmt" \
    --arg vq "$vtype"  --arg lang "$lang" \
    '{format:$fmt, content:$c, visual_query:$vq, language:$lang}')

  resp=$(curl -s -X POST https://api.napkin.ai/v1/visual \
    -H "Authorization: Bearer $NAPKIN_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$body")

  # python3: handles multiline JSON (jq fails on API responses with content echoed back)
  id=$(echo "$resp" | python3 -c "
import sys,re; m=re.search(r'\"id\":\"([^\"]+)\"',sys.stdin.read()); print(m.group(1) if m else '')")

  [[ -z "$id" ]] && { echo "❌ Submit failed: $(echo "$resp" | head -c 150)"; return 1; }
  echo "⏳ $vtype — ID: $id"

  for i in $(seq 1 60); do
    sleep 4
    poll=$(curl -s -H "Authorization: Bearer $NAPKIN_API_KEY" \
      "https://api.napkin.ai/v1/visual/$id/status")
    vstatus=$(echo "$poll" | python3 -c "
import sys,re; m=re.search(r'\"status\":\"([^\"]+)\"',sys.stdin.read()); print(m.group(1) if m else '?')")

    if [[ "$vstatus" == "completed" ]]; then
      echo "$poll" | python3 -c "
import sys,re
d=sys.stdin.read()
for u in re.findall(r'\"url\":\"(https?://[^\"]+)\"',d): print(u)
for u in re.findall(r'\"url\":\"(/[^\"]+)\"',d): print('https://api.napkin.ai'+u)
" | while read -r url; do
        fname="$outdir/${vtype}_$(date +%H%M%S).${fmt}"
        curl -s -L -H "Authorization: Bearer $NAPKIN_API_KEY" -o "$fname" "$url"
        echo "✅ $(wc -c < "$fname")b → $fname"
      done
      return 0
    elif [[ "$vstatus" == "failed" ]]; then
      echo "❌ Failed (no detail from API)"; return 1
    fi
    [[ $((i % 3)) -eq 0 ]] && echo "  ⏳ [$i] $vstatus..."
  done
  echo "⏱️ Timeout"
}
```

Usage:
```bash
echo "# My Visual\n## A\n- x\n## B\n- y" > /tmp/v.md
napkin_generate /tmp/v.md mindmap svg
```

## Visual Types

| Type | Template | Best for | ⚠️ Limits |
|------|----------|----------|-----------|
| `mindmap` | Radial branches | Brainstorm, concepts, ecosystems | — |
| `flowchart` | Boxes + arrows | Processes, decisions, workflows | — |
| `timeline` | Chronological line | History, roadmap, milestones | — |
| `comparison` | **2-column pros/cons** | 2-item comparison only | **Max 2 `##` sections** — more items → unexpected layout |
| `hierarchy` | Tree structure | Org charts, taxonomies | — |
| `cycle` | Closed loop | Lifecycles, iterative processes | — |
| `list` | Structured list | Toolboxes, inventories, steps | — |
| `matrix` | 2×2 grid | Priority/effort, quadrants | Use instead of `comparison` for 3–4 items |

## Parameters Reference

| Param | Type | Default | Notes |
|-------|------|---------|-------|
| `format` | svg\|png\|ppt | — | Required |
| `content` | string | — | Required. Markdown recommended |
| `visual_query` | string | auto | Visual type (see table above) |
| `language` | BCP47 | auto | `en`, `fr`, `en-US`… |
| `color_mode` | light\|dark\|both | light | |
| `orientation` | auto\|horizontal\|vertical\|square | auto | |
| `number_of_visuals` | 1–4 | 1 | Variants per request |
| `text_extraction_mode` | auto\|rewrite\|preserve | auto | |
| `transparent_background` | bool | false | SVG/PNG only |
| `width`/`height` | int 100–10000 | — | PNG only |
| `style_id` | string | — | See api.napkin.ai/docs/styles |

## Output Convention

```
~/Pictures/Napkin/
├── mindmap_143000.svg
├── flowchart_143500.svg
└── timeline_090000.png
```

> `~/Pictures/Napkin/` is currently **empty** — example renders are in `assets/examples/` of this skill.

## Changelog

| Date | Agent | Action |
|------|-------|--------|
| 2026-04-01 | [CLAUDE] | v1.1.0 — quota table, fixed function (python3 parsing, --arg, auth download, vstatus), batch script ref, comparison warning, examples moved to assets/ |
| 2026-03-31 | [CLAUDE] | v1.0.1 — HTTP 402 gotcha documented; output dir → ~/Pictures/Napkin |
| [SUMMARY] | — | v1.0.0 — initial skill creation |
