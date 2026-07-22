/**
 * KπX Suggestions Guard — OpenCode plugin.
 * Injects a format-reminder system message on EVERY messages.transform
 * to ensure the assistant always includes 💡 Suggestions (≥3).
 *
 * This is unconditional — fires every turn, not conditional on
 * the previous response. The reminder is lightweight (single sentence)
 * and keeps the LLM primed for the format requirement.
 */
module.exports = async function suggestionsGuardPlugin() {
  return {
    "experimental.chat.messages.transform": async (_input, output) => {
      output.messages = output.messages || [];

      output.messages.push({
        role: "system",
        content:
          "FORMAT: Your response MUST end with a `💡 Suggestions` section " +
          "containing ≥3 numbered proactive suggestions for next steps.",
      });
    },
  };
};
