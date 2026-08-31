import fs from "node:fs";
import path from "node:path";
import { execSync } from "node:child_process";
import { currentAgentIs } from "../libs/agent-scope.js";
import { messageText } from "../libs/message-utils.js";
import { loadPrompt } from "../libs/prompt-loader.js";
import { detectDevice } from "../libs/device-info.js";

const TARGET_AGENTS = ["Colab", "Live", "Agent", "Auto", "Build", "Plan"];

function readFileSafe(filePath) {
  try {
    return fs.readFileSync(filePath, "utf8").trim();
  } catch {
    return null;
  }
}
// tmuxContext() — always reports the full tmux tree (every session/window/pane)
// so the agent can address any pane by ID, whether or not it was launched inside
// tmux. When launched FROM a tmux pane (TMUX_PANE env set), it also states the
// agent's own session:window.pane position.
function tmuxContext() {
  const lines = ["<tmux-context>"];
  const run = (cmd) => {
    try {
      return execSync(cmd, { timeout: 5000, encoding: "utf8" }).trim();
    } catch {
      return null;
    }
  };
  const inTmux = Boolean(process.env.TMUX_PANE);
  lines.push(`Agent launched from tmux: ${inTmux ? "YES" : "NO"}`);
  if (inTmux) {
    const position = run(
      "tmux display-message -p '#{session_name}:#{window_index}.#{pane_index} (#{pane_id}) #{pane_current_command}'",
    );
    lines.push(
      `Agent tmux position: ${position || "(unknown)"}`,
    );
  }
  lines.push("", "Full tmux tree (session:window.pane | pane_id | current command):");
  const tree = run(
    "tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} | #{pane_id} | #{pane_current_command}'",
  );
  lines.push(tree || "(no tmux server reachable / none running)");
  lines.push("</tmux-context>");
  return lines.join("\n");
}
// inLabs — true only when the CLIENT session's own directory (Session.directory,
// resolved via client.session.get; NEVER process.cwd(), which is the persistent
// `opencode serve` daemon's own launch dir, not the calling client's) is EXACTLY
// $HOME/KpihX-Labs. When false, the k-context block (TODOs/Projects/Log) is
// skipped — device-context and tmux-context still always inject.
export function buildContext(inLabs) {
  const skillsDirectory = path.join(process.env.HOME, ".agents", "skills");
  const lines = ["<startup-context>", `Session date: ${new Date().toISOString().split("T")[0]}`, ""];
  if (inLabs) {
    lines.push(
      readFileSafe(path.join(skillsDirectory, "k-context", "SKILL.md")) ||
        "(k-context not available)",
      "",
      loadPrompt("startup-context"),
    );
  } else {
    lines.push(
      "(k-context skipped — session not launched from exactly $HOME/KpihX-Labs)",
    );
  }
  lines.push("</startup-context>");
  const device = detectDevice();
  lines.push("", "<device-context>", `--- DEVICE: ${device.hostname} ---`);
  lines.push(
    device.skillName
      ? `Infra skill: ${device.skillName} (see skills/${device.skillName}/SKILL.md for full details)`
      : "(no known infra skill)",
  );
  lines.push("--- /DEVICE ---", "</device-context>");
  const tmux = tmuxContext();
  if (tmux) lines.push("", tmux);
  return lines.join("\n");
}

// isLaunchedFromLabs() — resolves the CALLING SESSION's own directory via
// Session.directory (client.session.get), NOT process.cwd(). This hook runs
// inside the single persistent `opencode serve` daemon shared by every
// client/session regardless of where each one was launched from — so
// process.cwd() would always report the DAEMON's own launch dir, never the
// client's. Session.directory is the SDK-documented per-session field that
// actually carries the client's real launch directory.
async function isLaunchedFromLabs(client, messages) {
  const sessionID = messages.find((message) => message.info?.sessionID)?.info
    ?.sessionID;
  if (!sessionID) return false;
  try {
    const session = await client.session.get({ path: { id: sessionID } });
    const directory = session.data?.directory || "";
    return directory === path.join(process.env.HOME, "KpihX-Labs");
  } catch {
    return false;
  }
}

export default async function (input) {
  return {
    "experimental.chat.messages.transform": async (_input, output) => {
      const messages = output.messages || [];
      if (
        !currentAgentIs(messages, TARGET_AGENTS) ||
        messages.some((message) =>
          messageText(message).startsWith("Session date:"),
        )
      )
        return output;
      const inLabs = await isLaunchedFromLabs(input.client, messages);
      output.messages ??= [];
      output.messages.unshift({
        info: { role: "user" },
        // synthetic:true — keeps the startup context visible to the model but
        // excludes it from OpenCode's title-gen gate (requires EXACTLY ONE
        // non-synthetic user message to fire).
        parts: [{ type: "text", text: buildContext(inLabs), synthetic: true }],
      });
      return output;
    },
  };
}
