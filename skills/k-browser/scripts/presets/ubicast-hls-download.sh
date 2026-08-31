#!/usr/bin/env bash
# Preset: download separate Ubicast/Nudgis HLS video and audio manifests, then losslessly mux them.
# The manifest URLs must come from ubicast-hls-inspect.sh after playback has loaded.
#
# Usage: ubicast-hls-download.sh <video-m3u8-url> <audio-m3u8-url> <output.mp4>
# Intermediates are deliberately preserved under /tmp for auditability and retry; no data is deleted.

set -euo pipefail

if (( $# != 3 )); then
  printf 'Usage: %s <video-m3u8-url> <audio-m3u8-url> <output.mp4>\n' "${0##*/}" >&2
  exit 2
fi

VIDEO_URL="$1"
AUDIO_URL="$2"
OUTPUT_PATH="$3"

for command_name in yt-dlp ffmpeg; do
  command -v "$command_name" >/dev/null || {
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  }
done

if [[ -e "$OUTPUT_PATH" ]]; then
  printf 'Refusing to overwrite existing output: %s\n' "$OUTPUT_PATH" >&2
  exit 1
fi

OUTPUT_DIR="$(dirname "$OUTPUT_PATH")"
mkdir -p "$OUTPUT_DIR"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ubicast-hls.XXXXXX")"

printf 'Downloading video manifest into: %s\n' "$WORK_DIR"
yt-dlp --no-playlist --merge-output-format mp4 \
  -o "$WORK_DIR/video.%(ext)s" \
  "$VIDEO_URL"

printf 'Downloading audio manifest into: %s\n' "$WORK_DIR"
yt-dlp --no-playlist --merge-output-format mp4 \
  -o "$WORK_DIR/audio.%(ext)s" \
  "$AUDIO_URL"

shopt -s nullglob
VIDEO_FILES=("$WORK_DIR"/video.*)
AUDIO_FILES=("$WORK_DIR"/audio.*)
if (( ${#VIDEO_FILES[@]} != 1 || ${#AUDIO_FILES[@]} != 1 )); then
  printf 'Expected exactly one video and one audio file in %s; inspect the preserved intermediates.\n' "$WORK_DIR" >&2
  exit 1
fi

printf 'Losslessly muxing video + audio into: %s\n' "$OUTPUT_PATH"
ffmpeg -n \
  -i "${VIDEO_FILES[0]}" \
  -i "${AUDIO_FILES[0]}" \
  -map 0:v:0 -map 1:a:0 -c copy -shortest \
  "$OUTPUT_PATH"

printf 'Completed: %s\nPreserved intermediates: %s\n' "$OUTPUT_PATH" "$WORK_DIR"
