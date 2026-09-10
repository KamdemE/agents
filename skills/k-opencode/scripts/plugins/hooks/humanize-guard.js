// humanize-guard.js — Tier PROSE bloquant: em-dash / spaced en-dash / spaced --
// GLOBAL hook, `tool.execute.before`, NO TARGET_AGENTS — same reasoning as
// make-check-guard.js / raw-exec-guard.js: `tool.execute.before` has no
// `messages` to scope by, this is a GLOBAL kernel rule that must apply to
// every agent. Declaring TARGET_AGENTS would trip eslint `no-unused-vars`
// and fail `make check`'s check-js step; the hooks-standard §2 mandate
// applies to `messages.transform` hooks, not to tool-level blocking hooks.
// NOTE — TARGET_AGENTS is intentionally ABSENT (global rule).
//
// Libs (single source of truth):
//   - SEND_KEYS_REGEX from "../libs/tmux-patterns.js" (plugin-local, shared
//     with tmux-notify.js + raw-exec-guard.js).
//   - humanize helpers from "../../../../../libs/humanize/humanize_lib.js"
//     (repo-root libs — Tier PROSE bloquant patterns: EM_DASH_TRIPLE `---`,
//     EM_DASH_UNICODE `—` U+2014, DOUBLE_DASH_SPACED ` -- `, EN_DASH_SPACED
//     ` – ` U+2013 spaced). Interval `2024–2025` (alnum–alnum collé) is
//     allowed; ` -- ` blocked only with spaces; `---` standalone HR allowed
//     via check-dashes but blocked here if inside sentence/prose.
//   - Hardened: also blocks escaped/encoded bypasses ():
//     `\u2012`..`\u2015` / `\U00002012`.. (`\u`/`\U` case-insensitive),
//     `\xE2\x80\x92`..`\xE2\x80\x95` (UTF-8 bytes), `\N{EM DASH}`/`\N{EN DASH}`
//     (and FIGURE DASH/HORIZONTAL BAR), `chr(8210..8213)`/`chr(0x2012..)`
//     with optional spaces. The generic escaped check covers ALL inline
//     code runners (python3 -c, python -c, uv run python, node -e/-c,
//     ruby -e, perl -e, php -r, bash -c, sh -c, zsh -c, echo -e, printf, etc.)
//     — no per-runner special casing needed.
//
// Mechanism: same as raw-exec-guard.js / make-check-guard.js —
// `tool.execute.before` is the ONLY reliable block point (mutating
// `output.args` does NOT propagate, upstream opencode issue #31680), so
// enforcement is `throw new Error(...)` that aborts the tool call before
// it runs. Do NOT mutate output.args.
//
// Scope:
//   1. Only intercepts tools `edit`, `write`, `bash` (input.tool). Others pass.
//   2. For `write`/`edit`: if isCodeFile(filePath) → allow (code whitelist).
//      Otherwise check each content string (write: content; edit:
//      oldString/newString/content) via containsBlockedDash (now includes
//      escaped forms) + decoded second-pass via decodeUnicodeEscapesForCheck.
//      If blocked → throw.
//   3. For `bash`: if SEND_KEYS_REGEX.test(cmd) → allow (tmux payload not
//      executed here — same exemption as raw-exec-guard operational checks;
//      humanize is a prose rule, not a security rule, so payload is
//      delivered to pane). Otherwise check whole command string with
//      containsBlockedDash (escaped included) AND decoded check —
//      defense in depth: raw `\u2014` is blocked, and decoded `—` is also blocked.

import { SEND_KEYS_REGEX } from "../libs/tmux-patterns.js";
import { containsBlockedDash, decodeUnicodeEscapesForCheck, isCodeFile } from "../../../../../libs/humanize/humanize_lib.js";

function buildMessage(pattern, snippet, filePath) {
  const file = filePath || "(bash command)";
  return (
    "🛑 Humanize guard: em-dash / spaced en-dash / -- détecté — remplace par ponctuation + connecteur logique ( , ; : . + car/donc/or/puis/en effet). " +
    'Ex: "a — b" → "a, car b" ou "a : b". ' +
    `Blocked pattern: ${pattern} snippet: ${snippet} file: ${file} ` +
    "(note: also blocks escaped forms \\u2014 / \\U00002014 / \\xE2\\x80\\x94 / \\N{EM DASH} / chr(8212) etc.; interval 2024\u20132025 alnum\u2013alnum collé allowed, ` -- ` blocked only with spaces, `---` standalone HR allowed via check-dashes but blocked here if inside sentence)"
  );
}

export default async function () {
  return {
    "tool.execute.before": async (input, output) => {
      const tool = input?.tool;
      if (tool !== "edit" && tool !== "write" && tool !== "bash") return input;

      // ──── write / edit ────
      if (tool === "write" || tool === "edit") {
        const args = output?.args ?? {};
        const filePath = args.filePath ?? args.path ?? args.file ?? "";

        // Code files are whitelisted — skip prose check
        if (filePath && isCodeFile(filePath)) return input;

        const candidates = [];
        if (typeof args.content === "string" && args.content) candidates.push(args.content);
        if (typeof args.oldString === "string" && args.oldString) candidates.push(args.oldString);
        if (typeof args.newString === "string" && args.newString) candidates.push(args.newString);
        if (typeof args.text === "string" && args.text) candidates.push(args.text);
        // Fallback: some edit variants pass the new content directly in input.input
        if (candidates.length === 0 && typeof input?.input === "string" && input.input) {
          candidates.push(input.input);
        }

        for (const c of candidates) {
          // Layer 1: direct (now includes escaped)
          const res = containsBlockedDash(c);
          if (res.blocked) {
            throw new Error(buildMessage(res.pattern, res.snippet, filePath));
          }
          // Layer 2: decoded second-pass (defense in depth)
          const decoded = decodeUnicodeEscapesForCheck(c);
          if (decoded !== c) {
            const res2 = containsBlockedDash(decoded);
            if (res2.blocked) {
              throw new Error(buildMessage(res2.pattern, res2.snippet, filePath));
            }
          }
        }
        return input;
      }

      // ──── bash ────
      if (tool === "bash") {
        const cmd = output?.args?.command ?? input?.input ?? "";
        if (!cmd.trim()) return input;

        // Tmux send-keys payload is delivered to pane, not executed here —
        // same exemption as raw-exec-guard operational checks (humanize is
        // prose rule, not security rule).
        if (SEND_KEYS_REGEX.test(cmd)) return input;

        // Layer 1: direct (escaped included via lib)
        const res = containsBlockedDash(cmd);
        if (res.blocked) {
          throw new Error(buildMessage(res.pattern, res.snippet, ""));
        }
        // Layer 2: decoded second-pass
        const decoded = decodeUnicodeEscapesForCheck(cmd);
        if (decoded !== cmd) {
          const res2 = containsBlockedDash(decoded);
          if (res2.blocked) {
            throw new Error(buildMessage(res2.pattern, res2.snippet, ""));
          }
        }
        return input;
      }

      return input;
    },
  };
}
