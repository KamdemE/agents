const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

/**
 * KπX Startup Context — OpenCode plugin.
 * Injects raw k-context + current device infra context on first
 * messages.transform, but ONLY for agents Colab and Build.
 *
 * Agent detection: captures session.created event → info.agent.
 * Device detection: tailscale status → infras.json lookup → infra skill.
 */
let currentAgent = null;

module.exports = async function startupContextPlugin() {
  const home = process.env.HOME;
  const agentsDir = path.join(home, ".agents");
  const assetsDir = path.join(agentsDir, "assets");
  const skillsDir = path.join(agentsDir, "skills");

  let injected = false;

  // ── helpers ──────────────────────────────────────────────────────────

  function readFileSafe(filePath) {
    try {
      return fs.readFileSync(filePath, "utf8").trim();
    } catch {
      return null;
    }
  }

  function detectDevice() {
    /** Returns { hostname, skillName } or null. */
    const infrasPath = path.join(assetsDir, "infras.json");
    const map = (() => {
      try {
        const raw = JSON.parse(fs.readFileSync(infrasPath, "utf8"));
        return raw.infras || {};
      } catch {
        return {};
      }
    })();

    // Primary: tailscale status --json
    let hostname = null;
    try {
      const ts = execSync("tailscale status --json", {
        timeout: 5000,
        encoding: "utf8",
      });
      const data = JSON.parse(ts);
      const dnsName = (data.Self && data.Self.DNSName) || "";
      hostname = dnsName.split(".")[0];
    } catch {
      // fallback
    }

    // Fallback: os hostname
    if (!hostname) {
      try {
        const os = require("os");
        hostname = os.hostname().toLowerCase();
      } catch {
        return null;
      }
    }

    const skillName = map[hostname.toLowerCase()] || null;
    return { hostname, skillName };
  }

  // ── build context block ──────────────────────────────────────────────

  function buildContext() {
    const parts = [];

    // ── k-context ──
    parts.push("<startup-context>");
    parts.push(
      `Session date: ${new Date().toISOString().split("T")[0]}`,
    );
    const kContext = readFileSafe(
      path.join(skillsDir, "k-context", "SKILL.md"),
    );
    parts.push("");
    parts.push(kContext || "(k-context not available)");
    parts.push("</startup-context>");

    // ── device infra context ──
    const device = detectDevice();
    if (device && device.hostname) {
      parts.push("");
      parts.push("<device-context>");
      parts.push(`--- DEVICE: ${device.hostname} ---`);

      if (device.skillName) {
        parts.push(`Infra skill: ${device.skillName}`);

        // Read the infra skill's SKILL.md
        const infraSkillPath = path.join(
          skillsDir,
          device.skillName,
          "SKILL.md",
        );
        const infraContent = readFileSafe(infraSkillPath);
        if (infraContent) {
          parts.push("");
          parts.push(infraContent);
        }
      } else {
        parts.push("(no known infra skill)");
      }

      parts.push("--- /DEVICE ---");
      parts.push("</device-context>");
    }

    return parts.join("\n");
  }

  // ── plugin hooks ─────────────────────────────────────────────────────

  return {
    // Capture agent name at session start
    event: async ({ event }) => {
      if (event.type === "session.created") {
        currentAgent = event.properties.info?.agent ?? null;
      }
    },

    // Inject full context on first turn (for Colab/Build only)
    "experimental.chat.messages.transform": async (input, output) => {
      if (currentAgent !== "Colab" && currentAgent !== "Build") return;
      if (injected) return;
      injected = true;

      output.messages = output.messages || [...(input.messages || [])];
      output.messages.unshift({
        role: "system",
        content: buildContext(),
      });
    },
  };
};
