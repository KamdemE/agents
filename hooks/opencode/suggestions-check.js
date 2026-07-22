/**
 * KπX Suggestions Guard — OpenCode plugin.
 * Injects format reminder system message on EVERY messages.transform,
 * but ONLY for agents Colab, Build, and Auto.
 *
 * Agent detection: captures session.created event → info.agent.
 */
let currentAgent = null;

module.exports = async function suggestionsGuardPlugin() {
  return {
    // Capture agent name at session start
    event: async ({ event }) => {
      if (event.type === "session.created") {
        currentAgent = event.properties.info?.agent ?? null;
      }
    },

    // Inject format reminder every turn (for Colab/Build only)
    "experimental.chat.messages.transform": async (_input, output) => {
      if (currentAgent !== "Colab" && currentAgent !== "Build" && currentAgent !== "Auto") return;

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
