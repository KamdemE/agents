#!/usr/bin/env bash
# Preset: extract a LOADED Ubicast/Nudgis player's direct HLS manifests through browser-proxy.
# Start playback in the visible Edge tab first; before then, player.core.handler.hls does not exist.
#
# Usage: ubicast-hls-inspect.sh <target_id> [profile]
# Output: the browser-proxy JSON envelope containing the media OID, direct video levels, and audio
#         modes. Never use a blob: URL as a download input.

set -euo pipefail

if (( $# < 1 || $# > 2 )); then
  printf 'Usage: %s <target_id> [profile]\n' "${0##*/}" >&2
  exit 2
fi

command -v jq >/dev/null || {
  printf 'Missing required command: jq\n' >&2
  exit 1
}

TARGET_ID="$1"
PROFILE="${2:-default}"

EXPRESSION='(() => {
  const player = window.player;
  const hls = player?.core?.handler?.hls;
  if (!player || !hls) {
    return JSON.stringify({
      ready: false,
      reason: "Start playback first; the Ubicast HLS controller is not loaded yet."
    });
  }
  const modes = Object.fromEntries(
    Object.entries(player.modesManager?.modesDicts ?? {}).map(([name, mode]) => [
      name,
      {
        url: mode?.resource?.url ?? null,
        format: mode?.resource?.format ?? null
      }
    ])
  );
  return JSON.stringify({
    ready: true,
    title: document.title,
    media_oid: player.mediaOID ?? null,
    video_levels: (hls.levels ?? []).map((level) => ({
      height: level.height ?? null,
      width: level.width ?? null,
      bitrate: level.bitrate ?? null,
      urls: level.url ?? []
    })),
    modes
  });
})()'

PAYLOAD="$(jq -cn \
  --arg profile "$PROFILE" \
  --arg target_id "$TARGET_ID" \
  --arg expression "$EXPRESSION" \
  '{profile: $profile, target_id: $target_id, expression: $expression, await_promise: true}')"

browser-proxy do page-evaluate "$PAYLOAD"
