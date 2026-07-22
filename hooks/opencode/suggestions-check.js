/**
 * KπX Suggestions Check — OpenCode plugin.
 * Reminds the assistant to include 💡 Suggestions (≥3 items) on every turn.
 */
module.exports = async function suggestionsCheckPlugin(ctx) {
  let checked = false;

  return {
    "experimental.chat.messages.transform": async (input, output) => {
      output.messages = output.messages || [...(input.messages || [])];

      // Skip first turn (startup context handles that)
      if (!checked) {
        checked = true;
        return;
      }

      const lastAssistant = [...(input.messages || [])]
        .reverse()
        .find((m) => m.role === "assistant");

      if (!lastAssistant) return;

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
    },
  };
};
