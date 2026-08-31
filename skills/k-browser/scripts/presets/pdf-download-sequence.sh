#!/usr/bin/env bash
# Preset: turn an Edge inline PDF viewer into a real, visible browser download.
# It never uses curl, hidden fetches, or browser-proxy internals: each navigation and the final
# download request happens in KπX's visible Edge window through public `browser-proxy do` actions.
#
# Usage: pdf-download-sequence.sh <profile> <target_id> <pdf_url>
# Result: the server's canonical filename is saved in $HOME/Downloads. Verify it with `file`.

set -euo pipefail

if (( $# != 3 )); then
  printf 'Usage: %s <profile> <target_id> <pdf_url>\n' "${0##*/}" >&2
  exit 2
fi

command -v browser-proxy >/dev/null || {
  printf 'Missing required command: browser-proxy\n' >&2
  exit 1
}
command -v jq >/dev/null || {
  printf 'Missing required command: jq\n' >&2
  exit 1
}

PROFILE="$1"
TARGET_ID="$2"
PDF_URL="$3"
DOWNLOAD_PATH="$HOME/Downloads"

printf '1/3 Configure Edge downloads: %s\n' "$DOWNLOAD_PATH"
browser-proxy do raw "$(jq -cn \
  --arg profile "$PROFILE" \
  --arg path "$DOWNLOAD_PATH" \
  '{profile:$profile,protocol:"cdp-browser",method:"Browser.setDownloadBehavior",params:{behavior:"allow",downloadPath:$path,eventsEnabled:true}}')"

printf '2/3 Navigate the visible tab to the PDF. Edge may show its inline viewer.\n'
browser-proxy do page-navigate "$(jq -cn \
  --arg profile "$PROFILE" \
  --arg target_id "$TARGET_ID" \
  --arg url "$PDF_URL" \
  '{profile:$profile,target_id:$target_id,url:$url,wait_seconds:15}')"

printf '3/3 Request a same-origin browser download from the loaded PDF.\n'
browser-proxy do page-evaluate "$(jq -cn \
  --arg profile "$PROFILE" \
  --arg target_id "$TARGET_ID" \
  --arg expression '(() => {
    if (document.contentType !== "application/pdf") {
      throw new Error(`Refusing download: expected application/pdf, got ${document.contentType}.`);
    }
    const link = document.createElement("a");
    link.href = location.href;
    link.download = "";
    document.body.appendChild(link);
    link.click();
    link.remove();
    return {requested: true, url: location.href};
  })()' \
  '{profile:$profile,target_id:$target_id,expression:$expression}')"

printf 'Download requested. Verify the server-named file in %s with `file`.\n' "$DOWNLOAD_PATH"
