const fs = require("fs");
const path = require("path");

/**
 * KπX Startup Context — OpenCode plugin.
 * Injects k-context TODOs + Active Projects on first messages.transform.
 */
module.exports = async function startupContextPlugin(ctx) {
  const home = ctx.home || process.env.HOME;
  const agentsDir = path.join(home, ".agents");
  const skillsDir = path.join(agentsDir, "skills");

  let injected = false;

  function readFileSafe(filePath) {
    try {
      return fs.readFileSync(filePath, "utf8").trim();
    } catch {
      return null;
    }
  }

  function buildStartupContext() {
    const kContextPath = path.join(skillsDir, "k-context", "SKILL.md");
    const content = readFileSafe(kContextPath);
    if (!content) {
      return "<startup-context>k-context not available</startup-context>";
    }

    const todoMatch = content.match(/## Active TODOs[\s\S]*?(?=\n## )/);
    const projectsMatch = content.match(/## Active Projects[\s\S]*?(?=\n## )/);

    const parts = [
      "<startup-context>",
      `Session date: ${new Date().toISOString().split("T")[0]}`,
      "",
      todoMatch ? todoMatch[0].trim() : "(no Active TODOs)",
      "",
    ];

    if (projectsMatch) {
      const lines = projectsMatch[0].split("\n").slice(0, 22).join("\n");
      parts.push(lines.substring(0, 2000));
    }

    parts.push("</startup-context>");
    return parts.join("\n");
  }

  return {
    "experimental.chat.messages.transform": async (input, output) => {
      if (injected) return;
      injected = true;

      output.messages = output.messages || [...(input.messages || [])];
      output.messages.unshift({
        role: "system",
        content: buildStartupContext(),
      });
    },
  };
};
