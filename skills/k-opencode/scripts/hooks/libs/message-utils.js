export function messageRole(message) { return message.info?.role ?? message.role; }
export function messageParts(message) { return message.parts ?? []; }
export function messageText(message) {
  return messageParts(message).filter((part) => part.type === "text").map((part) => part.text).join("\n").trim();
}
export function isToolPart(part) { return ["tool", "tool_use", "tool_result", "tool_call"].includes(part.type); }
export function hasToolPart(message) { return messageParts(message).some(isToolPart); }
export function appendMessage(output, role, text) {
  output.messages ??= [];
  // synthetic:true — marks this as an injected/system message so OpenCode's
  // title-gen gate (requires EXACTLY ONE non-synthetic user message) still fires.
  output.messages.push({ info: { role }, parts: [{ type: "text", text, synthetic: true }] });
}

export function hasPriorUserText(messages, marker) {
  return messages.slice(0, -1).some((message) => messageRole(message) === "user" && messageText(message).includes(marker));
}

export function missionContext(messages, { maxUserMessages = 5, excludedTexts = [] } = {}) {
  const blocks = [];
  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const message = messages[index];
    if (messageRole(message) !== "user") continue;
    const text = messageText(message);
    if (!text || text.includes("<startup-context>") || excludedTexts.some((marker) => text.includes(marker))) continue;
    blocks.unshift(text);
    if (text.includes("/loop") || text.includes("/mission")) return blocks;
  }
  return blocks.slice(-maxUserMessages);
}
