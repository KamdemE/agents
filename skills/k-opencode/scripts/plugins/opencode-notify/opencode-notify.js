// opencode-notify.js — notify KπX (GUI + Telegram, always both) in EXACTLY
// 2 cases: (1) the agent's turn genuinely ends and it's waiting on KπX, or
// (2) it's paused needing a tool-call/permission decision. Nothing else.
//
// NOT A HOOK (see scripts/plugins/AGENTS.md → "Hooks vs Plugins") — a
// read-only/observational plugin, own subdirectory, no TARGET_AGENTS.
//
// FULL REWRITE 2026-08-27 (KπX: "je ne veux pas de patch, un code unifié
// ultra compact") — the previous version trusted `session.idle` directly,
// which is WRONG: confirmed via web research against OpenCode's own upstream
// (github.com/anomalyco/opencode issues #3815, #3744, #16626, #2021) that
// `session.idle` fires MULTIPLE TIMES per real agent turn — once per
// internal loop iteration, well before actual completion — which is exactly
// why the old version notified "when nothing was happening". The reliable
// signal, confirmed against the SDK's own AssistantMessage.finish field
// (types.gen.d.ts) and an OpenCode maintainer's own workaround (issue
// #3815): the LAST assistant message's `finish` reason.
//   - finish === "stop"        -> the agent genuinely finished ITS turn
//                                 (includes it asking KπX a question and
//                                 waiting — same bucket, no separate signal
//                                 needed for that case).
//   - finish === "tool-calls"  -> still mid-loop, about to call more tools —
//                                 NOT a real stop, never notify.
//   - error.name ===
//     "MessageAbortedError"    -> KπX's own Escape-Escape abort — explicitly
//                                 excluded per KπX ("si moi j'arrête ça ne
//                                 compte pas").
// Tool-call/permission decisions use the real "permission.ask" hook
// (confirmed to exist and fire before the human is even asked).

import fs from "node:fs";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import path from "node:path";
import { currentAgent } from "../libs/agent-scope.js";
import { detectDevice } from "../libs/device-info.js";

const execFileAsync = promisify(execFile);
const NOTIFY_SCRIPT = path.join(
  path.dirname(new URL(import.meta.url).pathname),
  "opencode-notify.sh",
);
// TUI auto-approve answers the same permission request almost immediately.
// Verified live: permission.asked.id === permission.replied.requestID and the
// auto reply arrived in 30ms. Hold the alert briefly; a matching reply cancels
// it, while a genuinely human-facing request remains pending and notifies.
const PERMISSION_GRACE_MS = 250;
const pendingPermissions = new Map(); // permission id -> timeout handle
// Diagnostic trail (2026-08-27, KπX directive: "va tester totalement jusqu'à
// garantir 100%") — the prior rewrite silently swallowed every dispatch
// failure with zero trace anywhere, making a real "why didn't it fire"
// impossible to answer. This is intentionally kept (not scaffolding to
// remove later) — every hook invocation and every dispatch outcome is
// logged here, so any future report can be root-caused from real evidence.
const DEBUG_LOG = "/tmp/opencode-notify-debug.log";
function trace(line) {
  try {
    fs.appendFileSync(DEBUG_LOG, `[${new Date().toISOString()}] ${line}\n`);
  } catch {}
}

// <code> renders as a monospace <pre> block on Telegram (e.g. the bash
// command awaiting approval); escaping happens inside notifier.sh, never
// here. Never throws back into the caller's turn — but ALWAYS traces its
// outcome (success or the exact error) to DEBUG_LOG.
async function dispatch(level, title, message, code = "") {
  try {
    await execFileAsync(NOTIFY_SCRIPT, [level, title, message, code], { timeout: 15000 });
    trace(`dispatch OK level=${level} title=${JSON.stringify(title)}`);
  } catch (error) {
    trace(`dispatch FAILED level=${level} title=${JSON.stringify(title)} error=${error && error.stack ? error.stack : error}`);
  }
}

function lastAssistant(entries) {
  for (let i = entries.length - 1; i >= 0; i -= 1) {
    if (entries[i]?.info?.role === "assistant") return entries[i].info;
  }
  return null;
}

function lastAssistantEntry(entries) {
  for (let i = entries.length - 1; i >= 0; i -= 1) {
    if (entries[i]?.info?.role === "assistant") return entries[i];
  }
  return null;
}

function extractText(entry) {
  if (!entry || !Array.isArray(entry.parts)) return "";
  return entry.parts
    .filter((p) => p?.type === "text" && typeof p.text === "string")
    .map((p) => p.text.trim())
    .filter(Boolean)
    .join("\n\n");
}

async function fetchEntries(client, sessionID) {
  try {
    const response = await client.session.messages({ path: { id: sessionID } });
    return Array.isArray(response) ? response : response.data || [];
  } catch {
    return [];
  }
}

export default async function ({ client }) {
  const device = detectDevice();

  async function notify(level, headline, sessionID, detail = "", code = "", entries = null) {
    if (!sessionID) return;
    let title = "(untitled)";
    let directory = "";
    try {
      const session = await client.session.get({ path: { id: sessionID } });
      title = session.data?.title || title;
      directory = session.data?.directory || "";
    } catch {}
    const agent = currentAgent(entries || (await fetchEntries(client, sessionID))) || "";
    const notifTitle = `OpenCode · ${device.hostname}${agent ? ` · ${agent}` : ""}`;
    const project = directory ? directory.split("/").filter(Boolean).pop() : "";
    const lines = [headline, `Session: ${title}`];
    if (project) lines.push(`Dir: ${project}`);
    if (detail) lines.push(detail);
    await dispatch(level, notifTitle, lines.join("\n"), code);
  }

  // Startup trace — proves this exact file (not an old cached copy) is loaded.
  trace(`plugin loaded device=${device.hostname} file=opencode-notify.js v=${new Date().toISOString()}`);

  return {
    event: async ({ event }) => {
      // Generic trace — log EVERY event to diagnose which one (if any) fires
      // for a permission ask. Without this, silent non-delivery is invisible.
      trace(`event received type=${event.type} sessionID=${event.properties?.sessionID || "unknown"}`);
      // Capture the exact reply payload before implementing asked↔replied
      // correlation for TUI auto-approve. No behavior change here: this is
      // evidence gathering only (id vs requestID must be verified live).
      if (event.type === "permission.replied") {
        const reply = event.properties || {};
        const timer = pendingPermissions.get(reply.requestID);
        if (timer) {
          clearTimeout(timer);
          pendingPermissions.delete(reply.requestID);
          trace(`permission auto-resolved requestID=${reply.requestID} reply=${reply.reply}; notification cancelled`);
        } else {
          trace(`event permission.replied raw=${JSON.stringify(reply).slice(0, 600)}`);
        }
        return;
      }
      // MAGIC FORMULA (found via deep web research + live log digging 2026-08-27):
      // The REAL event is "permission.asked" (past tense), NOT "permission.updated"
      // nor the hook "permission.ask". Web research confirms:
      // - GitHub issues #9229, #28066, #7006: active code PermissionNext.ask() does
      //   Bus.publish(Event.Asked, info) -> "permission.asked", never Plugin.trigger("permission.ask",...)
      //   since commit 38e0dc9 (Mar 2026). Hook is declared but dead.
      // - PR #10588 docs fix: "permission.updated" never fires, actual is "permission.asked".
      // - Live proof: debug log showed exactly 1 event "permission.asked" at 11:53:27 for the
      //   live TUI test (Edit notify-final2.txt), while "permission.updated" count was 0
      //   and "permission.ask" hook never logged. Keep "permission.updated" as fallback for compat.
      if (event.type === "permission.asked" || event.type === "permission.updated") {
        const perm = event.properties || {};
        trace(`event ${event.type} sessionID=${perm.sessionID} raw=${JSON.stringify(perm).slice(0, 600)}`);
        // Real structure verified live at 12:05:13.627Z: { permission:"edit", patterns:["tmp/..."], metadata:{filepath, diff}, ... }
        // Previous code read perm.type/title/pattern (all undefined) -> minimal "Permission required". Fix to real fields.
        const permission = perm.permission || perm.type || "Permission";
        const filepath = perm.metadata?.filepath || perm.patterns?.[0] || perm.pattern || "";
        const patterns = perm.patterns || (perm.pattern ? [perm.pattern] : []);
        const diff = perm.metadata?.diff || "";
        const title = perm.title || `${permission} ${filepath}`.trim() || permission;
        const code = diff || patterns.join("\n") || perm.pattern || "";
        const previous = pendingPermissions.get(perm.id);
        if (previous) clearTimeout(previous);
        const timer = setTimeout(() => {
          pendingPermissions.delete(perm.id);
          trace(`permission still pending id=${perm.id}; sending notification`);
          notify("WARN", "🔐 Waiting for your approval", perm.sessionID, title, code);
        }, PERMISSION_GRACE_MS);
        timer.unref?.();
        pendingPermissions.set(perm.id, timer);
        return;
      }
      if (event.type !== "session.idle") return;
      const sessionID = event.properties?.sessionID;
      if (!sessionID) return;
      const entries = await fetchEntries(client, sessionID);
      const last = lastAssistant(entries);
      const finish = last?.finish;
      const errName = last?.error?.name;
      trace(`event session.idle sessionID=${sessionID} finish=${finish} error=${errName}`);
      if (!last) return;
      if (errName === "MessageAbortedError") return; // KπX's own abort
      if (finish !== "stop") return; // mid-loop (tool-calls) — not a real stop
      // Full: include the actual final assistant text (what KπX sees on screen),
      // untruncated — KπX explicit: no truncation (2026-08-27).
      const lastEntry = lastAssistantEntry(entries);
      const fullText = extractText(lastEntry);
      await notify("OK", "✅ Finished — waiting for you", sessionID, fullText, "", entries);
    },

    "permission.ask": async (input, output) => {
      // input is Permission (see types.gen.d.ts), output is { status }. Use two-arg
      // form to match the actual SDK signature; single-arg still works but logging
      // both args proves the hook was actually invoked (critical diagnostic after
      // the earlier silent-failure where this hook never logged at all).
      const perm = input?.sessionID ? input : input?.permission || input || {};
      trace(`hook permission.ask CALLED sessionID=${perm?.sessionID} type=${perm?.type} title=${JSON.stringify(perm?.title)} pattern=${JSON.stringify(perm?.pattern)} output=${JSON.stringify(output)}`);
      const pattern = Array.isArray(perm.pattern)
        ? perm.pattern.join("\n")
        : perm.pattern || "";
      await notify("WARN", "🔐 Waiting for your approval", perm.sessionID, perm.title || perm.type || "Permission required", pattern);
    },
  };
}
