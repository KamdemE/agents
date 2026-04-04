/**
 * OpenClaw hook: path-guard
 * Event: message:sent (advisory — cannot block, only warn)
 * Only runs when the event exposes a concrete target file path inside $HOME/.agents/.
 * Reuses both path_guard and skill_edit_guard from the Python core.
 */
import { spawnSync } from "child_process";

export default function handler(event: Record<string, unknown>) {
  try {
    const content =
      typeof event["content"] === "string" ? event["content"] : "";
    const filePath =
      typeof event["filePath"] === "string"
        ? event["filePath"]
        : typeof event["file_path"] === "string"
          ? event["file_path"]
          : "";

    if (!content || !filePath) return {};

    const result = spawnSync(
      "python3",
      [
        "-c",
        `
import sys, json, os
sys.path.insert(0, os.path.join(os.environ["HOME"], ".agents/hooks"))
from core import path_guard, skill_edit_guard
import json as _json
content = sys.argv[1]
file_path = sys.argv[2]
errors = path_guard.guard_content(content, file_path=file_path)
skill = skill_edit_guard.evaluate_skill_edit("Write", {"file_path": file_path, "content": content})
errors.extend(skill["errors"])
print(_json.dumps({"errors": errors, "notes": skill["notes"]}))
          `.trim(),
          content,
          filePath,
      ],
      { encoding: "utf8", timeout: 5000 }
    );

    if (result.status === 0 && result.stdout) {
        const data = JSON.parse(result.stdout.trim()) as {
          errors: string[];
          notes?: string[];
        };
        if (data.errors && data.errors.length > 0) {
          const notes =
            data.notes && data.notes.length > 0
              ? "\n\nNotes:\n" + data.notes.map((e: string) => `- ${e}`).join("\n")
              : "";
          return {
            systemMessage:
              "⚠️ FILE GUARD: Your last response described a blocked `.agents/` file edit:\n" +
              data.errors.map((e: string) => `- ${e}`).join("\n") +
              notes,
          };
        }
      }
  } catch (_) {
    // fail-safe: never block on error
  }
  return {};
}
