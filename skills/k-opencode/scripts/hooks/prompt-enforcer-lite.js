import { appendFileSync } from "node:fs";
import { currentAgent, currentAgentIs } from "./libs/agent-scope.js";
import {
  hasToolPart,
  messageRole,
  messageText,
  appendMessage,
} from "./libs/message-utils.js";
import { loadPrompt } from "./libs/prompt-loader.js";

const TARGET_AGENTS = ["Agent"];

export default async function () {
  return {
    "experimental.chat.messages.transform": async (_input, output) => {
      const messages = output.messages || [];
      if (!currentAgentIs(messages, TARGET_AGENTS)) return output;
      const lastMessage = messages.at(-1);
      if (
        !lastMessage ||
        messageRole(lastMessage) !== "user" ||
        hasToolPart(lastMessage)
      )
        return output;
      const text = messageText(lastMessage);
      if (
        !text ||
        text.includes("<startup-context>") ||
        text.startsWith("Session date:")
      )
        return output;
      appendFileSync(
        "/tmp/pel-log.txt",
        `[${new Date().toISOString()}] Injecting for ${currentAgent(messages)}\n`,
      );
      appendMessage(output, "user", loadPrompt("prompt-enforcer-lite"));
      return output;
    },
  };
}
