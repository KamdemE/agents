const fs = require("fs");
const path = require("path");

/**
 * Kx Orchestra — OpenCode plugin for colab/explore orchestration.
 *
 * Hooks:
 *   experimental.chat.messages.transform — inject startup context + suggestions check
 *   tool.execute.after — review output for errors
 *   experimental.session.compacting — preserve intent across compaction
 */
module.exports = async function (ctx) {
  const home = ctx.home || process.env.HOME;
  const agentsDir = path.join(home, ".agents");
  const skillsDir = path.join(agentsDir, "skills");
  const intentPath = path.join(agentsDir, "memories", "current-intent.md");

  let sessionStarted = false;

  function readFileSafe(filePath) {
    try {
      return fs.readFileSync(filePath, "utf8").trim();
    } catch (e) {
      return null;
    }
  }

  function readIntent() {
    try {
      const raw = fs.readFileSync(intentPath, "utf8").trim();
      if (!raw || !raw.startsWith("## Current Intent")) return null;
      return raw;
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

    // Extract key sections
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
      // Keep first 15 project summary lines (compact)
      const lines = projectsMatch[0].split("\n").slice(0, 22).join("\n");
      parts.push(lines.substring(0, 2000));
    }

    parts.push("</startup-context>");
    return parts.join("\n");
  }

  return {
    /**
     * Startup context + suggestions guard — fires before every LLM call.
     *
     * First call: injects k-context TODOs + Active Projects as system message.
     * Subsequent calls: checks LAST assistant response for                 Suggestions section.
     * If missing, injects a reminder the LLM will see before its next response.
     */
    "experimental.chat.messages.transform": async (input, output) => {
      output.messages = output.messages || [...(input.messages || [])];

      // ── 1. FIRST CALL: inject startup context ──
      if (!sessionStarted) {
        sessionStarted = true;

        const startupBlock = buildStartupContext();

        // Inject at the beginning (before system prompt)
        output.messages.unshift({
          role: "system",
          content: startupBlock,
        });

        // Also inject intent if available
        const intent = readIntent();
        if (intent) {
          output.messages.unshift({
            role: "system",
            content: [
              "<orchestra-context>",
              "## Active Intent (colab profile)",
              intent,
              "</orchestra-context>",
            ].join("\n"),
          });
        }
        return;
      }

      // ── 2. SUBSEQUENT CALLS: check last assistant response for Suggestions ──
      const lastAssistant = [...(input.messages || [])]
        .reverse()
        .find((m) => m.role === "assistant");

      if (lastAssistant) {
        const content = lastAssistant.content || "";
        const hasSuggestions =
          content.includes("Suggestion");
        const suggestionCount = (content.match(/(?:^|\n)\s*\d+\.\s/g) || []).length;

        if (!hasSuggestions || suggestionCount < 3) {
          output.messages.push({
            role: "system",
            content:
              "⚠️ REMINDER: Your response MUST include a `💡 Suggestions` section with ≥3 proactive suggestions. " +
              "Format: `## 💡 Suggestions` followed by 3+ numbered items.",
          });
        }
      }

      // ── 3. Inject intent context every turn ──
      const intent = readIntent();
      if (intent) {
        output.messages.unshift({
          role: "system",
          content: [
            "<orchestra-context>",
            "## Active Intent (colab profile)",
            intent,
            "</orchestra-context>",
          ].join("\n"),
        });
      }
    },

    /**
     * Pragmatic Checker — review tool output for errors.
     */
    "tool.execute.after": async (input, output) => {
      const tool = input.tool || input.name || "";
      const err = output.error || "";

      if (!err) return;

      const criticalPatterns = [
        /permission denied/i,
        /cannot (find|open|read|write|access)/i,
        /syntax error/i,
        /command not found/i,
      ];
      const minorPatterns = [
        /no such file/i,
        /not found/i,
        /unresolved import/i,
        /module not found/i,
      ];

      const isCritical = criticalPatterns.some((p) => p.test(err));
      const isMinor = minorPatterns.some((p) => p.test(err));

      if (isCritical) {
        output.notes = output.notes || [];
        output.notes.push(
          `CRITICAL: Tool "${tool}" failed — ${err.substring(0, 200)}`
        );
      } else if (isMinor) {
        output.notes = output.notes || [];
        output.notes.push(
          `MINOR: Tool "${tool}" had issue — ${err.substring(0, 200)}`
        );
      }
    },

    /**
     * Memory — preserve current intent across session compaction.
     */
    "experimental.session.compacting": async (input, output) => {
      const intent = readIntent();
      if (!intent) return;

      output.retain = output.retain || [];
      output.retain.push({
        role: "system",
        content: [
          "<orchestra-context>",
          "## Preserved Intent (cross-compaction)",
          intent,
          "</orchestra-context>",
        ].join("\n"),
      });
    },
  };
};
