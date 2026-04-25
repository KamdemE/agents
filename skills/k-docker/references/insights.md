# k-docker Insights

Purpose: autonomous runtime memory for this skill domain to avoid repeated mistakes, repeated dead-end searches, and repeated ineffective action patterns.

## Governance

- Read this file before non-trivial work in this skill domain.
- Update this file at the end of the task whenever a durable insight is learned.
- Keep entries concise, actionable, and focused on anti-repeat value.
- Reorganize, merge, or prune stale entries autonomously to keep signal high.

## Insights

- For uv-based Docker images, `uv sync` can leave console scripts depending on source paths. Either install non-editably or copy `src/` into the runtime image and set `PYTHONPATH`; always smoke-test `docker run <image> version`.
- For security-sensitive CLI downloads, avoid floating vendor URLs. Pin the release version and verify SHA-256 per architecture during the Docker build.
- Cross-platform "GUI from container to host" is not truly agnostic. Native Zenity/X11 is a Linux overlay; portable approval should be a browser-based localhost UI or a small host companion app.
- For MCP servers consumed over stdio, Docker should usually be **one invocation = one container**. A resident `serve` container plus `docker exec` recreates daemon lifecycle bugs, stale state, and port contention that do not exist with `docker run --rm`.
- If a containerized workflow must expose a localhost approval UI, the host wrapper should own port selection and browser opening. Fixed container-level ports become a shared global lock across agents and one-shot commands.
