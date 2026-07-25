/**
 * KπX Suggestions Guard — OpenCode plugin.
 */
export default async function() {
  return {
    "experimental.chat.messages.transform": async (_input, output) => {
      // Find the agent name from the first message (or any message)
      const msgsStr = JSON.stringify(output.messages || []);
      if (!msgsStr.includes('"Colab"') && !msgsStr.includes('"Build"') && !msgsStr.includes('"Auto"')) return output;

      output.messages = output.messages || [];
      output.messages.push({
        info: { role: "system" },
        parts: [{ 
          type: "text", 
          text: "FORMAT: Your response MUST end with a `\uD83D\uDCA1 Suggestions` section containing \u22653 numbered proactive suggestions for next steps." 
        }]
      });
      return output;
    }
  };
}
