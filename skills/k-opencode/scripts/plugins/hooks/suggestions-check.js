import { currentAgentIs } from "../libs/agent-scope.js";
import { appendMessage } from "../libs/message-utils.js";
import { loadPrompt } from "../libs/prompt-loader.js";

// All main agents EXCEPT Lite — Lite has its own compact footer note in its
// own prompt.txt (KπX directive 2026-08-29: this hook's redundant injection
// on top of Lite's already-terse prompt was one contributor to a small local
// model (qwen3-4b) rambling/hesitating instead of acting fast).
const TARGET_AGENTS = ["Colab", "Live", "Explore", "Agent", "Auto", "Build", "Plan"];

export default async function() {
  return {
    "experimental.chat.messages.transform": async (_input, output) => {
      if (!currentAgentIs(output.messages || [], TARGET_AGENTS)) return output;
      appendMessage(output, "system", loadPrompt("suggestions-check"));
      return output;
    },
  };
}
