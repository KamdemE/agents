import { appendFileSync } from "node:fs";
import { currentAgent, currentAgentIs } from "./libs/agent-scope.js";
import { hasToolPart, messageRole, messageText, missionContext } from "./libs/message-utils.js";
import { promptMarker, renderPrompt } from "./libs/prompt-loader.js";

const TARGET_AGENTS = ["Agent"];
const STOP_MARKER = promptMarker("stop-enforcer");

export default async function({ client }) {
  return {
    event: async ({ event }) => {
      if (event.type !== "session.idle") return;
      const sessionId = event.properties?.sessionID;
      if (!sessionId) return;
      try {
        const response = await client.session.messages({ path: { id: sessionId } });
        const messages = Array.isArray(response) ? response : response.data || [];
        if (!currentAgentIs(messages, TARGET_AGENTS)) return;
        const latestMessage = messages.at(-1);
        if (!latestMessage || messageRole(latestMessage) !== "assistant" || hasToolPart(latestMessage) || !messageText(latestMessage)) return;
        let foundMarker = false;
        let usedToolAfterMarker = false;
        for (let index = messages.length - 1; index >= 0; index -= 1) {
          const text = messages[index].parts?.filter((part) => part.type === "text").map((part) => part.text).join("\n") || "";
          if (!foundMarker && hasToolPart(messages[index])) usedToolAfterMarker = true;
          if (text.includes(STOP_MARKER)) foundMarker = true;
        }
        // A STOP CHECK is a post-tool verification gate, never a response to a
        // text-only turn. A previous marker only suppresses duplicate checks;
        // an actual tool part since that marker is the positive trigger.
        if (!usedToolAfterMarker) return;
        const blocks = missionContext(messages, {
          maxUserMessages: 5,
          excludedTexts: [STOP_MARKER, promptMarker("prompt-enforcer-strict")],
        });
        if (!blocks.length) return;
        const mission = `MISSION CONTEXT:\n"""\n${blocks.join("\n\n--- SUITE ---\n\n").slice(0, 4000)}\n"""`;
        appendFileSync("/tmp/stop-enforcer.log", `Injecting into session: ${sessionId}\n`);
        await client.session.prompt({ path: { id: sessionId }, body: { agent: currentAgent(messages), parts: [{ type: "text", text: renderPrompt("stop-enforcer", { MISSION_CONTEXT: mission }) }] } });
      } catch (error) {
        appendFileSync("/tmp/stop-enforcer-error.log", `${error.stack || error}\n`);
      }
    },
  };
}
