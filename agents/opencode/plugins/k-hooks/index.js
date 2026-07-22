const fs = require("fs");
const path = require("path");

/**
 * Kx Hooks — OpenCode lifecycle hooks plugin.
 *
 * Hooks:
 *   experimental.chat.messages.transform — inject startup context + suggestions check
 */
module.exports = async function (ctx) {
  const home = ctx.home || process.env.HOME;
  const agentsDir = path.join(home, ".agents");
  const skillsDir = path.join(agentsDir, "skills");

  let sessionStarted = false;

  function readFileSafe(filePath) {
    try {
      return fs.readFileSync(filePath, "utf8").trim();
    } catch (e) {
      return null;
    }
  }

  /**
   * Build startup context block: k-context TODOs + Active Projects.
   */
  function buildStartupContext() {
    const kContextPath = path.join(skillsDir, "k-context", "SKILL.md");
    const content = readFileSafe(kContextPath);
    if (!content) {
      return "<startup-context>k-context not available</startup-context>";
    }

    const todoMatch = content.match(/## Active TODOs\n+[\s\S]*?(?=\n## )/);
    const projectsMatch = content.match(/## Active Projects\n+[\s\S]*?(?=\n## )/);

    const dateStr = new Date().toISOString().split("T")[0];
    const parts = [
      "<startup-context>",
      `Session date: ${dateStr}`,
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
    /**
     * Startup context + suggestions guard.
     *
     * First call: injects k-context TODOs + Active Projects as system message.
     * Subsequent calls: checks LAST assistant response for Suggestions section.
     * If missing, injects a reminder before the next LLM call.
     */
    "experimental.chat.messages.transform": async (input, output) => {
      output.messages = output.messages || [...(input.messages || [])];

      // ── 1. FIRST CALL: inject startup context ──
      if (!sessionStarted) {
        sessionStarted = true;
        output.messages.unshift({
          role: "system",
          content: buildStartupContext(),
        });
        return;
      }

      // ── 2. SUBSEQUENT CALLS: check last assistant response for Suggestions ──
      const lastAssistant = [...(input.messages || [])]
        .reverse()
        .find((m) => m.role === "assistant");

      if (lastAssistant) {
        const content = lastAssistant.content || "";
        const hasSuggestions = content.includes("Suggestion");
        const suggestionCount = (content.match(/(?:^|\n)\s*\d+\.\s/g) || []).length;

        if (!hasSuggestions || suggestionCount < 3) {
          output.messages.push({
            role: "system",
            content:
              "REMINDER: Your response MUST include a `💡 Suggestions` section with ≥3 proactive suggestions. " +
              "Format: `## 💡 Suggestions` followed by 3+ numbered items.",
          });
        }
      }
    },
  };
};
