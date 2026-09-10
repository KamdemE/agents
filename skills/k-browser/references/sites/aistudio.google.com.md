# aistudio.google.com

**Category:** AI playground (Gemini models, code execution, multimodal). **Account:** <primary@gmail.com> (Pro tier). **Profile:** `default`.

## Login

Session persists via Google account cookies already in the `default` profile (`SID`/`HSID`/`SSID`/`SAPISID`/`__Secure-1PSID`… on `.google.com`). No fresh login usually needed — if a login screen appears, it means the Google session expired; escalate to  rather than guessing which account.

## Structure / navigation

- Playground chats: `/prompts/<id>` (new: `/prompts/new_chat`)
- History: `/library`
- Model picker: playground header → model name button (no public `/models` REST listing — it 404s)
- Run settings panel: toggles for **Code execution** and **Grounding** (Google Search)

## Known quirks

- **Code execution**: toggle ON *before* sending a prompt that needs matplotlib/Python — toggling after the first message has no effect on that turn.
- **Grounding + attachments conflict**: uploading a PDF/video with Grounding ON frequently produces `An internal error has occurred.` — disable Grounding for attachment-heavy prompts.
- **Attachment readiness gate (critical)**: after upload, do NOT click Run until every attachment chip shows a token count (e.g. `3 921 tokens`) and none show `Loading…`/`Failed`. Early Run → the model answers "no video/PDF attached" or the generic internal error. Poll via `page-snapshot` every few seconds until all chips settle.
- **Video uploads are flaky**: short MP4s often fail with internal errors — don't retry more than once, ask the user before persisting.
- **Large-video ceiling, validated**: a 48m30 MP4 was accepted and indexed as `858 451 tokens`, but the Run response still ended with `An internal error has occurred.` Treat a successful token count as *upload completion*, not a promise that the selected Gemini UI/model can reason over the full video. Do not retry the same oversized request repeatedly; pivot to `k-ai` → `k-whisper` for a local transcript, then summarize that text.
- **Large local file injection**: for a real `<input type=file>` such as AI Studio's `input.file-input`, `browser-drop-file` is the wrong mechanism (it is for JavaScript drop zones). Use `do raw` with `protocol:"cdp-page"` and `DOM.setFileInputFiles` on the input node instead, then confirm the filename and token-count chip in the DOM. This avoids base64-copying a multi-hundred-MB file through the CLI.
- **Free-tier image model**: "Nano Banana" (`gemini-2.5-flash-image`) has no Paid badge; other image/video models (Imagen 4, Veo) are billed.
- **Downloads**: generated image → lightbox → Download button (saves to `~/Downloads/Generated Image …png`). The in-chat "Code execution result" `.txt` is NOT the plot image — the plot is a separate lightbox-downloadable image.

## History cleanup

`/library` → delete only chats created during the CURRENT automation run (titles from the last ~hour). Never delete older chats unless  names them explicitly. Flow: row → **More options** (`more_vert`) → Delete → confirm.

