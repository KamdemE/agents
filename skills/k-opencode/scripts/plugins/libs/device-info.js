// device-info.js — resolve the current machine's identity for hooks.
// Single source of truth for any hook that needs to identify
// "which device am I running on" (e.g. startup-context.js's <device-context>,
// opencode-notify.js's notification title).
//
// Single-machine fork: identity is $AGENTS_INFRA when exported, else the OS
// hostname. No tailscale dependency, no infra→skill map (deleted).

import os from "node:os";

export function detectDevice() {
  const hostname = (process.env.AGENTS_INFRA || os.hostname()).toLowerCase();
  return { hostname, skillName: null };
}
