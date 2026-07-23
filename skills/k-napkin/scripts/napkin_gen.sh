#!/usr/bin/env zsh
# napkin_gen.sh — Core generation function. Source this in any Napkin generation script.
#
# USAGE:
#   source $HOME/.agents/skills/k-napkin/scripts/napkin_gen.sh
#   napkin_gen <content_file> <visual_type> [format] [output_dir] [language]
#
# REQUIREMENTS: NAPKIN_API_KEY via Vaultwarden, jq, curl, python3

napkin_gen() {
  local content_file="$1"
  local vtype="$2"
  local fmt="${3:-svg}"
  local outdir="${4:-$HOME/Pictures/Napkin}"
  local lang="${5:-en}"
  local resp id vstatus poll fname

  mkdir -p "$outdir"
  sleep 1  # rate limit: 2 req/s

  # --arg encodes newlines as \n — required by API (--rawfile with literal newlines is rejected)
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

  # python3 required: API echoes multiline content in response → jq parse error
  id=$(echo "$resp" | python3 -c "
import sys, re
m = re.search(r'\"id\":\"([^\"]+)\"', sys.stdin.read())
print(m.group(1) if m else '')
")

  [[ -z "$id" ]] && { echo "❌ Submit failed: $(echo "$resp" | head -c 150)"; return 1; }
  echo "⏳ $vtype — ID: $id"

  for i in $(seq 1 60); do
    sleep 4
    poll=$(curl -s -H "Authorization: Bearer $NAPKIN_API_KEY" \
      "https://api.napkin.ai/v1/visual/$id/status")

    # vstatus — "status" is a reserved zsh variable
    vstatus=$(echo "$poll" | python3 -c "
import sys, re
m = re.search(r'\"status\":\"([^\"]+)\"', sys.stdin.read())
print(m.group(1) if m else '?')
")

    if [[ "$vstatus" == "completed" ]]; then
      echo "$poll" | python3 -c "
import sys, re
d = sys.stdin.read()
for u in re.findall(r'\"url\":\"(https?://[^\"]+)\"', d): print(u)
for u in re.findall(r'\"url\":\"(/[^\"]+)\"', d):         print('https://api.napkin.ai' + u)
" | while read -r url; do
        fname="$outdir/${vtype}_$(date +%H%M%S).${fmt}"
        # Authorization header required — file endpoint is not public
        curl -s -L -H "Authorization: Bearer $NAPKIN_API_KEY" -o "$fname" "$url"
        echo "✅ $(wc -c < "$fname")b → $fname"
      done
      return 0
    elif [[ "$vstatus" == "failed" ]]; then
      echo "❌ Generation failed (no detail from API)"; return 1
    fi
    [[ $((i % 3)) -eq 0 ]] && echo "  ⏳ [$i] $vstatus..."
  done
  echo "⏱️ Timeout"
}
