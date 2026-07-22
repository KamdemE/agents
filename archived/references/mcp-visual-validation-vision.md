# Brainstorm — MCP Visual Validation (HITL)

## Vision
Transform all "write" operations (`send`, `create`, `update`, `delete`, `move`) across the KπX MCP ecosystem into a Human-In-The-Loop (HITL) flow that launches a visual editor/previewer. 

This ensures that the agent's proposed actions are visible, adjustable, and manually validated by KpihX before they touch real-world data or external APIs.

## Scope
The following MCP servers and actions are priority targets:

| MCP | Priority Actions | Target UX |
|-----|------------------|-----------|
| **tick-mcp** | `create_task`, `update_task` | Visual task card with description, dates, and reminders |
| **whats-mcp** | `send_text`, `send_image`, `send_document` | Chat bubble preview with recipient and media metadata |
| **mail-mcp** | `send_message`, `reply_message`, `save_draft` | Full email composing interface with subject, recipients, and attachments |
| **linkedin-mcp** | `publish_post`, `send_message` | Post preview with text and image thumbnails |

## Proposed Architecture

1. **Shim Layer:** A wrapper or custom tool layer that intercepts write calls.
2. **Visual Editor:** A web-based or UI-based editor (likely leveraging the agent's ability to generate artifacts or using a dedicated local web server/WebTop) to present the payload.
3. **Validation Loop:** 
   - Agent proposes tool call.
   - Shim intercepts → generates a "validation artifact" (JSON/Markdown/HTML preview).
   - User reviews → approves, edits (manual JSON/Markdown edit), or rejects.
   - Shim executes the final validated payload via the original MCP tool.

## Technical Ideas
- **Artifact-driven Preview:** Use the agent's native artifact capability to show the preview. 
- **Wait-for-Input Tool:** A dedicated tool that blocks execution until a specific file/variable is updated by the user.
- **MCP Middleware:** If using a custom MCP bridge, inject logic there.

## Roadmap
- [ ] Draft detailed wireframes for each preview type (Task, Message, Post).
- [ ] Prototype the interception mechanism for `tick-mcp`.
- [ ] Standardize the validation payload format.
- [ ] Generalize across all communication MCPs.
