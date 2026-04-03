/**
 * OpenClaw hook: path-guard
 * Event: message:sent (advisory — cannot block, only warn)
 * Only runs when the event exposes a concrete target file path inside $HOME/.agents/.
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
from core import path_guard
import json as _json
content = sys.argv[1]
file_path = sys.argv[2]
errors = path_guard.guard_content(content, file_path=file_path)
print(_json.dumps({"errors": errors}))
        `.trim(),
        content,
        filePath,
      ],
      { encoding: "utf8", timeout: 5000 }
    );

    if (result.status === 0 && result.stdout) {
      const data = JSON.parse(result.stdout.trim()) as { errors: string[] };
      if (data.errors && data.errors.length > 0) {
        return {
          systemMessage:
            "⚠️ PATH GUARD: Your last response contained rule violations:\n" +
            data.errors.map((e: string) => `- ${e}`).join("\n") +
            "\nPlease use $HOME and $USER for .agents file content.",
        };
      }
    }
  } catch (_) {
    // fail-safe: never block on error
  }
  return {};
}
