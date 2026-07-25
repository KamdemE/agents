import fs from "fs";
import path from "path";
import os from "os";
import { execSync } from "child_process";

function readFileSafe(fp) { try { return fs.readFileSync(fp, "utf8").trim(); } catch { return null; } }

function detectDevice() {
  const ad = path.join(process.env.HOME, ".agents");
  const map = (() => {
    try { return JSON.parse(fs.readFileSync(path.join(ad, "assets", "infras.json"), "utf8")).infras || {}; } catch { return {}; }
  })();
  let hn = null;
  try {
    const ts = execSync("tailscale status --json", { timeout: 5000, encoding: "utf8" });
    hn = (JSON.parse(ts).Self?.DNSName || "").split(".")[0];
  } catch {}
  if (!hn) { try { hn = os.hostname().toLowerCase(); } catch { return null; } }
  return { hostname: hn, skillName: map[hn?.toLowerCase()] || null };
}

function buildContext() {
  const sd = path.join(process.env.HOME, ".agents", "skills");
  const p = [];
  p.push("<startup-context>");
  p.push(`Session date: ${new Date().toISOString().split("T")[0]}`);
  p.push("");
  p.push(readFileSafe(path.join(sd, "k-context", "SKILL.md")) || "(k-context not available)");
  p.push("</startup-context>");
  const d = detectDevice();
  if (d?.hostname) {
    p.push("", "<device-context>", `--- DEVICE: ${d.hostname} ---`);
    if (d.skillName) {
      p.push(`Infra skill: ${d.skillName}`);
      const c = readFileSafe(path.join(sd, d.skillName, "SKILL.md"));
      if (c) { p.push("", c); }
    } else { p.push("(no known infra skill)"); }
    p.push("--- /DEVICE ---", "</device-context>");
  }
  return p.join("\n");
}

export default async function() {
  return {
    "experimental.chat.messages.transform": async (_input, output) => {
      const msgsStr = JSON.stringify(output.messages || []);
      if (!msgsStr.includes('"Colab"') && !msgsStr.includes('"Build"') && !msgsStr.includes('"Auto"')) return output;
      if (msgsStr.includes("Session date: 2026-")) return output;
      
      output.messages = output.messages || [];
      let contextStr = "";
      try {
        contextStr = buildContext();
      } catch (e) {
        contextStr = "ERROR BUILDING CONTEXT: " + e.message;
      }
      
      output.messages.unshift({ 
        info: { role: "user" }, 
        parts: [{ type: "text", text: contextStr }] 
      });
      return output;
    }
  };
}
