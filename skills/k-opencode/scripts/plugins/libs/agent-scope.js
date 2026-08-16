/**
 * Return the agent owning the latest session activity.
 *
 * OpenCode retains all prior messages when an operator switches agent in the
 * same session. A historical match therefore identifies an old agent, not the
 * active one. Every agent-scoped hook must use this helper instead of scanning
 * serialized history for a name.
 */
export function currentAgent(messages) {
  for (let index = messages.length - 1; index >= 0; index -= 1) {
    const agent = messages[index]?.info?.agent;
    if (typeof agent === "string" && agent.trim()) return agent;
  }
  return null;
}

/** Return whether the latest session agent belongs to an exact target list. */
export function currentAgentIs(messages, targetAgents) {
  const agent = currentAgent(messages);
  return agent !== null && (targetAgents.includes("*") || targetAgents.some(
    (target) => target.toLowerCase() === agent.toLowerCase(),
  ));
}
