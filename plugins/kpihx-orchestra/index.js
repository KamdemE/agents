const fs = require("fs");
const path = require("path");

/**
 * KπX Orchestra — OpenCode plugin for colab/explore orchestration.
 *
 * Hooks:
 *   experimental.chat.messages.transform — inject intent context
 *   tool.execute.after — review output for errors
 *   experimental.session.compacting — preserve intent across compaction
 */
module.exports = async function (ctx) {
  const home = ctx.home || process.env.HOME;
  const intentPath = path.join(home, ".agents", "memories", "current-intent.md");

  function readIntent() {
    try {
      const raw = fs.readFileSync(intentPath, "utf8").trim();
      if (!raw || !raw.startsWith("## Current Intent")) return null;
      return raw;
    } catch (e) {
      return null;
    }
  }

  return {
    /**
     * 🔍 Intent Guardian — inject current intent + detect drift context.
     */
    "experimental.chat.messages.transform": async (input, output) => {
      const intent = readIntent();
      if (!intent) return;

      const lastUser = [...(input.messages || [])].reverse().find(
        (m) => m.role === "user"
      );
      const userText = lastUser?.content || "";

      const contextBlock = [
        "<orchestra-context>",
        "## Active Intent (colab profile)",
        intent,
        "</orchestra-context>",
      ].join("\n");

      output.messages = output.messages || [...(input.messages || [])];
      output.messages.unshift({
        role: "system",
        content: contextBlock,
      });
    },

    /**
     * 🔧 Pragmatic Checker — review tool output for errors.
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
          `🔴 CRITICAL: Tool "${tool}" failed — ${err.substring(0, 200)}`
        );
      } else if (isMinor) {
        output.notes = output.notes || [];
        output.notes.push(
          `🟡 MINOR: Tool "${tool}" had issue — ${err.substring(0, 200)}`
        );
      }
    },

    /**
     * 💾 Memory — preserve current intent across session compaction.
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
