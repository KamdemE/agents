/**
 * OpenClaw hook: session-guard
 * Event: command:stop (advisory)
 * Checks if $HOME/.agents/ git repo has uncommitted changes.
 * If yes, injects a finalization reminder via systemMessage.
 */
import { spawnSync } from "child_process";

export default function handler(_event: Record<string, unknown>) {
  try {
    const result = spawnSync(
      "python3",
      [
        "-c",
        `
import sys, json, os
sys.path.insert(0, os.path.join(os.environ["HOME"], ".agents/hooks"))
from core import session_guard
r = session_guard.check_agents_git_status()
print(json.dumps(r))
        `.trim(),
      ],
      { encoding: "utf8", timeout: 5000 }
    );

    if (result.status === 0 && result.stdout) {
      const data = JSON.parse(result.stdout.trim()) as {
        has_changes: boolean;
        message: string;
      };
      if (data.has_changes && data.message) {
        return { systemMessage: `⚠️ ${data.message}` };
      }
    }
  } catch (_) {
    // fail-safe
  }
  return {};
}
