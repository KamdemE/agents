/**
 * OpenClaw hook: context-injector
 * Event: agent:bootstrap
 * Calls core/context_injector.py via subprocess and injects startup context.
 */
import { spawnSync } from "child_process";

// Entry point — OpenClaw calls this with the event payload
export default function handler(_event: Record<string, unknown>) {
  try {
    const result = spawnSync(
      "python3",
      [
        "-c",
        `
import sys, json, os
sys.path.insert(0, os.path.join(os.environ["HOME"], ".agents/hooks"))
from core import context_injector
data = context_injector.build_context_output("OPENCLAW")
print(json.dumps({"additionalContext": data["context"]}))
        `.trim(),
      ],
      { encoding: "utf8", timeout: 10000 }
    );

    if (result.status === 0 && result.stdout) {
      return JSON.parse(result.stdout.trim());
    }
  } catch (_) {
    // fail-safe: never block bootstrap
  }
  return {};
}
