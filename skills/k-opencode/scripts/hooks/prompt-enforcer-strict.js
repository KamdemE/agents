import { currentAgentIs } from "./libs/agent-scope.js";
import { appendMessage } from "./libs/message-utils.js";
import { loadPrompt } from "./libs/prompt-loader.js";

const TARGET_AGENTS = ["Colab", "Auto"];

export default async function() {
  return {
    "experimental.chat.messages.transform": async (_input, output) => {
      if (!currentAgentIs(output.messages || [], TARGET_AGENTS)) return output;
      appendMessage(output, "user", loadPrompt("prompt-enforcer-strict"));
      return output;
    },
  };
}
