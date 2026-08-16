import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execSync } from "node:child_process";
import { currentAgentIs } from "../libs/agent-scope.js";
import { messageText } from "../libs/message-utils.js";
import { loadPrompt } from "../libs/prompt-loader.js";
import { stripJsonc } from "../../../../../libs/jsonc/jsonc_lib.js";

const TARGET_AGENTS = ["Colab", "Agent", "Auto", "Build", "Plan"];

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
function detectDevice() {
  const agentsDirectory = path.join(process.env.HOME, ".agents");
  const raw =
    readFileSafe(path.join(agentsDirectory, "assets", "infras_skills.jsonc")) ||
    "{}";
  // infras_skills.jsonc is the FLAT infra→skill map (no "infras" wrapper).
  const map = JSON.parse(stripJsonc(raw)) || {};
  let hostname = null;
  try {
    hostname = (
      JSON.parse(
        execSync("tailscale status --json", {
          timeout: 5000,
          encoding: "utf8",
        }),
      ).Self?.DNSName || ""
    ).split(".")[0];
  } catch {}
  hostname ||= os.hostname().toLowerCase();
  return { hostname, skillName: map[hostname.toLowerCase()] || null };
}
export function buildContext() {
  const skillsDirectory = path.join(process.env.HOME, ".agents", "skills");
  const lines = [
    "<startup-context>",
    `Session date: ${new Date().toISOString().split("T")[0]}`,
    "",
    readFileSafe(path.join(skillsDirectory, "k-context", "SKILL.md")) ||
      "(k-context not available)",
    "",
    loadPrompt("startup-context"),
    "</startup-context>",
  ];
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

export default async function () {
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
      output.messages ??= [];
      output.messages.unshift({
        info: { role: "user" },
        // synthetic:true — keeps the startup context visible to the model but
        // excludes it from OpenCode's title-gen gate (requires EXACTLY ONE
        // non-synthetic user message to fire).
        parts: [{ type: "text", text: buildContext(), synthetic: true }],
      });
      return output;
    },
  };
}
