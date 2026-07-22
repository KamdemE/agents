const fs = require("fs");
const path = require("path");

/**
 * KπX Startup Context — OpenCode plugin.
 * Injects raw k-context content on first messages.transform,
 * but ONLY for agents Colab and Build.
 *
 * Agent detection: captures session.created event → info.agent.
 */
let currentAgent = null;

module.exports = async function startupContextPlugin() {
  const home = process.env.HOME;
  const kContextPath = path.join(
    home,
    ".agents",
    "skills",
    "k-context",
    "SKILL.md",
  );

  let injected = false;

  return {
    // Capture agent name at session start
    event: async ({ event }) => {
      if (event.type === "session.created") {
        currentAgent = event.properties.info?.agent ?? null;
      }
    },

    // Inject raw k-context on first turn (for Colab/Build only)
    "experimental.chat.messages.transform": async (input, output) => {
      if (currentAgent !== "Colab" && currentAgent !== "Build") return;
      if (injected) return;
      injected = true;

      let content = "<startup-context>\n";
      content += `Session date: ${new Date().toISOString().split("T")[0]}\n\n`;

      try {
        const raw = fs.readFileSync(kContextPath, "utf8").trim();
        content += raw;
      } catch {
        content += "(k-context not available)";
      }

      content += "\n</startup-context>";

      output.messages = output.messages || [...(input.messages || [])];
      output.messages.unshift({
        role: "system",
        content: content,
      });
    },
  };
};
