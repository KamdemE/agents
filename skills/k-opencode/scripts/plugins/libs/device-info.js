// device-info.js — resolve the current machine's Tailscale hostname + owning
// k-* infra skill. Single source of truth for any hook that needs to identify
// "which device am I running on" (e.g. startup-context.js's <device-context>,
// opencode-notify.js's notification title). Extracted 2026-08-27 out of
// startup-context.js (was a private, unexported local function there) to stop
// duplicating this logic across hooks — see libs/AGENTS.md → "no duplication, ever".

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { execSync } from "node:child_process";
import { stripJsonc } from "../../../../../libs/jsonc/jsonc_lib.js";

function readFileSafe(filePath) {
  try {
    return fs.readFileSync(filePath, "utf8").trim();
  } catch {
    return null;
  }
}

// Device auto-detection pipeline (documented in k-opencode/SKILL.md):
// tailscale status --json -> Self.DNSName -> assets/infras_skills.jsonc lookup
// Fallback: os.hostname() if tailscale is unreachable.
export function detectDevice() {
  const agentsDirectory = path.join(process.env.HOME, ".agents");
  const raw =
    readFileSafe(path.join(agentsDirectory, "assets", "infras_skills.jsonc")) ||
    "{}";
  // infras_skills.jsonc is the FLAT infra→skill map (no "infras" wrapper).
  const map = JSON.parse(stripJsonc(raw)) || {};
  let hostname = null;
  try {
    hostname = (
      JSON.parse(
        execSync("tailscale status --json", {
          timeout: 5000,
          encoding: "utf8",
        }),
      ).Self?.DNSName || ""
    ).split(".")[0];
  } catch {}
  hostname ||= os.hostname().toLowerCase();
  return { hostname, skillName: map[hostname.toLowerCase()] || null };
}
