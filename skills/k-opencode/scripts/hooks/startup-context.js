import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execSync } from "node:child_process";
import { currentAgentIs } from "./libs/agent-scope.js";
import { messageText } from "./libs/message-utils.js";
import { loadPrompt } from "./libs/prompt-loader.js";
import { stripJsonc } from "../../../../libs/jsonc_lib.js";

const TARGET_AGENTS = ["Colab", "Agent", "Auto", "Build", "Plan"];

function readFileSafe(filePath) {
  try {
    return fs.readFileSync(filePath, "utf8").trim();
  } catch {
    return null;
  }
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
