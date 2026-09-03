// raw-exec-guard.js — technically enforces two long-standing PROSE-ONLY rules
// (KπX, 2026-08-29, following the tmux-notify TMUX_ADJUST work in this same
// session): `rules/tool-discipline.md` → `## tmux sudo Gate` ("never run raw
// sudo in agent tool shells") and the 5th tmux-notify root cause fix
// ("self-backgrounding" — never manually `sleep`/`wait`/`timeout`-poll a
// command instead of routing it through tmux). Both were documented, NEVER
// technically blocked — an agent could always just run them directly.
//
// Mechanism: same pattern as `make-check-guard.js` — `tool.execute.before`
// is the ONLY reliable block point (mutating `output.args` does NOT
// propagate, upstream opencode issue #31680), so the enforcement is a
// `throw new Error(...)` that aborts the tool call before it runs.
//
// Scope decision (KπX, 2026-08-29): explicitly LIMITED to these two static,
// pre-execution checks. A 3rd idea (kill any raw command once it exceeds
// 30s and relaunch the agent) was proposed and explicitly REJECTED as
// out-of-scope for this pass — it is not achievable anyway with the current
// plugin API (no PID access, no reliable command rewriting), and KπX chose
// to keep this hook simple and verifiably correct rather than add a
// reactive mechanism that could only ever be an after-the-fact reminder.
//
// Duration threshold (KπX, 2026-08-30): `sleep` and `timeout` are only
// blocked when their duration exceeds POLL_THRESHOLD_SECS (20s). Short
// sleeps/timeouts (<20s) are allowed as quick inline polls. The `wait`
// bash builtin is ALWAYS blocked — it has no duration parameter and is
// inherently an indeterminate hang.
//
// False-positive guard (KπX, 2026-08-30): the `wait` pattern uses a
// negative lookbehind `(?<![a-zA-Z-])` so that flags like `--wait-for-cdp`
// or `--wait-for-something` are NOT blocked — only the bare `wait` bash
// builtin (preceded by space, quote, or start-of-string) triggers.
//
// .env protection (KπX, 2026-09-01, extended 2026-09-01): Option A — blocks
// secret access at 3 layers: (1) direct .env file paths, (2) runtime secret
// loading (Python dotenv, bash source, Node dotenv), (3) exclusions for
// .env.example and legitimate env usage.
//
// Proxy pipe protection (KπX, 2026-09-01): blocks any `*-proxy do*` command
// piped into jq/python/etc. to prevent overloading the proxy server with
// repeated calls. Agent must call proxy ONCE (autosave in /tmp/*-proxy-autosave/),
// then read the saved file for parsing.
//
// False-positive fix (KπX, 2026-09-02): the pipe check now strips quoted
// substrings before testing for `|`.  A `|` inside a single-quoted JSON
// payload or double-quoted JS expression is a literal character, NOT a
// shell pipe operator — only naked `|` outside quotes triggers the block.
//
// Proxy stderr suppression (KπX, 2026-09-01): blocks `2>/dev/null` on any
// `*-proxy` command. The 100% Transparency mantra demands that proxy errors
// are NEVER silenced — agents MUST see failures, diagnostics, and status
// output. This covers tg-proxy, tick-proxy, whats-proxy, mail-proxy,
// browser-proxy, ts-proxy, and any future proxy.
//
// Layer 1 — File paths: any bash command referencing `*.env*` file is
// blocked UNLESS the path is `*.env.example*`. Covers cat, less, head,
// tail, bat, xxd, strings, cp, mv, diff, etc. Path-anchored to avoid
// false positives on env var names like `MY_ENV_VAR=1`.
//
// Layer 2 — Runtime loading (Option A scope):
//   - Python dotenv: `python -c "from dotenv import..."` / `import dotenv`
//     / `from decouple import` / `from environ import` — blocks code that
//     LOADS .env files via libraries. Does NOT block `os.environ` access
//     (too broad, would break legitimate env debugging).
//   - Bash source: `source .env` / `. .env` — blocks sourcing .env files
//     directly. Excludes `.env.example*`.
//   - Node.js dotenv: `node -e 'require("dotenv")...'` / `import "dotenv"`
//     — blocks inline Node code loading dotenv.
//
// NOT blocked (Option A exclusions): `os.environ`/`os.getenv` in Python
// inline (too broad), `python script.py` (can't inspect file contents),
// env var names (`MY_ENV_VAR=1`), `env`/`printenv` builtins.
//
// Compliant path (never blocked): a command that is ALREADY a
// `tmux send-keys -t <target> ...` call. The quoted payload inside it
// (which may itself contain "sudo"/"sleep"/"wait"/"timeout") is delivered
// to the target pane and executed there — never by the agent's own shell —
// so it is explicitly exempt via `SEND_KEYS_REGEX` (shared with
// `tmux-notify.js`, see `libs/tmux-patterns.js`).
//
// NOTE — `TARGET_AGENTS` is intentionally ABSENT, same reasoning as
// `make-check-guard.js`: `tool.execute.before` does not receive `messages`,
// so agent-scoping is not possible here; this is a GLOBAL kernel rule that
// must apply to every agent.

import { SEND_KEYS_REGEX } from "../libs/tmux-patterns.js";

/** Only block sleep/timeout when duration exceeds this (seconds). */
const POLL_THRESHOLD_SECS = 20;

const SUDO_PATTERN = /\bsudo\b/;
const SLEEP_PATTERN = /\bsleep\s+([\d.]+)/;
/** Matches `wait` bash builtin only — NOT flags like `--wait-for-cdp`. */
const WAIT_PATTERN = /(?<![a-zA-Z-])\bwait\b/;
const TIMEOUT_PATTERN = /\btimeout\s+([\d.]+)/;

// .env file protection: match any file path ending with .env* but NOT .env.example*
// Anchored to paths (contain / or start with ~/ or ./) to avoid matching env var names.
// Examples matched: cat /foo/.env, less ~/.config/x/.env.local, head ./.env
// Examples NOT matched: cat /foo/.env.example, less x.env, export MY_ENV=1, env -i
const ENV_FILE_PATTERN = /(?:(?:^|\s)(?:[~/.][^\s]*\/[^\s]*\.env(?![\w.]*example)[^\s]*))/;

// Python dotenv import: catches `python -c "from dotenv import..."` /
// `import dotenv` / `from decouple import` / `from environ import` in
// inline Python code. Does NOT match `python script.py` (file execution).
const PYTHON_DOTENV_PATTERN = /\b(?:python3?|uv\s+run\s+python3?)\s+(?:-[ce]\s+['"]?.*?)?\b(?:from\s+(?:dotenv|decouple|environ)\s+import|import\s+(?:dotenv|decouple|environ)\b)/;

// Bash source .env: matches `source .env`, `. .env`, `source ~/.config/x/.env`
// but NOT `source .env.example`. Bare `.env` allowed (no path required).
const BASH_SOURCE_ENV_PATTERN = /(?:^|\s)(?:source|\.)\s+(?:([^\s]*\/))?[~/.]env(?![\w.])/;

// Node.js dotenv: matches `require("dotenv")`, `import "dotenv"`,
// `"dotenv".config()` in inline Node code (node -e / node -c).
const NODE_DOTENV_PATTERN = /\bnode\s+-[ec]\s+['"].*?(?:require\s*\(\s*['"]dotenv['"]\s*\)|import\s+(?:.*?\s+from\s*)?['"]dotenv['"]|['"]dotenv['"]\.config)/;

// Proxy pipe protection: blocks `*-proxy do*` commands piped into jq/python/etc.
// Agent must call the proxy ONCE (autosave in /tmp/*-proxy-autosave/),
// then read the saved file for parsing. Never pipe proxy output.
const PROXY_DO_PATTERN = /\b\w+[-_]proxy\s+do\b/;

/**
 * Strip quoted substrings from a command so that pipe characters inside
 * string literals (JSON payloads, JS expressions, etc.) are NOT treated
 * as shell pipes.  Handles both single and double quotes, with backslash
 * escapes inside double-quoted regions.  Returns the command with every
 * quoted region replaced by an empty string — only "naked" characters
 * remain.
 */
function stripQuotedContent(s) {
  let out = "";
  let i = 0;
  while (i < s.length) {
    const ch = s[i];
    if (ch === "'") {
      // Single-quoted: consume until closing ' (no escapes inside)
      i++; // skip opening quote
      while (i < s.length && s[i] !== "'") i++;
      i++; // skip closing quote (if any)
    } else if (ch === '"') {
      // Double-quoted: consume until closing " (backslash escapes apply)
      i++; // skip opening quote
      while (i < s.length && s[i] !== '"') {
        if (s[i] === "\\" && i + 1 < s.length) i++; // skip escaped char
        i++;
      }
      i++; // skip closing quote (if any)
    } else {
      out += ch;
      i++;
    }
  }
  return out;
}

// Proxy stderr suppression: blocks `2>/dev/null` on any `*-proxy` command.
// 100% Transparency — proxy errors/diagnostics must never be silenced.
const PROXY_PATTERN = /\b\w+[-_]proxy\b/;
const DEVNULL_PATTERN = /2\s*>\s*\/dev\/null/;

export default async function () {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return input;
      const cmd = output?.args?.command || input.input || "";
      if (!cmd.trim()) return input;

      // Compliant path: already routed through tmux — the quoted payload is
      // executed IN THE PANE, never by the agent's own shell. Nothing to
      // block here; `tmux-notify.js` already arms/handles it.
      if (SEND_KEYS_REGEX.test(cmd)) return input;

      // .env file protection: block any command referencing a .env* file
      // (secrets, tokens, passwords) unless it's a .env.example* file.
      // Covers cat, less, head, tail, bat, xxd, strings, cp, mv, diff, etc.
      const envMatch = cmd.match(ENV_FILE_PATTERN);
      if (envMatch) {
        // Extract the matched path for a clean error message
        const envPath = envMatch[0].trim();
        throw new Error(
          "🔒 .env secrets protection: access to secrets files is blocked.\n" +
            "Secrets are NEVER accessible to agents — this is an absolute security rule.\n" +
            "If you need to understand a service's configuration, consult the source:\n" +
            "  → the corresponding `.env.example` file (has all keys, no secrets)\n" +
            "  → the project's `CONTRACT.md` or `config.py` (documents expected env vars)\n" +
            `  → the owning skill's SKILL.md (documents configuration patterns)\n\n` +
            `Blocked path: ${envPath}\n` +
            `Blocked command: ${cmd}`,
        );
      }

      // Runtime .env loading protection (Option A): block code that LOADS
      // secrets at runtime via dotenv libraries or bash source.
      // Python dotenv: import dotenv/decouple/environ in inline code
      if (PYTHON_DOTENV_PATTERN.test(cmd)) {
        throw new Error(
          "🔒 .env secrets protection: Python dotenv loading is blocked.\n" +
            "Code that loads .env secrets via dotenv/decouple/environ is forbidden.\n" +
            "To understand a service's configuration, consult:\n" +
            "  → the corresponding `.env.example` file (has all keys, no secrets)\n" +
            "  → the project's `CONTRACT.md` or `config.py` (documents expected env vars)\n" +
            `  → the owning skill's SKILL.md (documents configuration patterns)\n\n` +
            `Blocked command: ${cmd}`,
        );
      }

      // Bash source .env: `source .env` / `. .env` — loads env vars from file
      if (BASH_SOURCE_ENV_PATTERN.test(cmd)) {
        throw new Error(
          "🔒 .env secrets protection: sourcing .env files is blocked.\n" +
            "`source .env` loads secrets into the shell environment — forbidden.\n" +
            "To understand a service's configuration, consult:\n" +
            "  → the corresponding `.env.example` file (has all keys, no secrets)\n" +
            "  → the project's `CONTRACT.md` or `config.py` (documents expected env vars)\n" +
            `  → the owning skill's SKILL.md (documents configuration patterns)\n\n` +
            `Blocked command: ${cmd}`,
        );
      }

      // Node.js dotenv: require("dotenv") / import "dotenv" in inline code
      if (NODE_DOTENV_PATTERN.test(cmd)) {
        throw new Error(
          "🔒 .env secrets protection: Node.js dotenv loading is blocked.\n" +
            "Code that loads .env secrets via dotenv module is forbidden.\n" +
            "To understand a service's configuration, consult:\n" +
            "  → the corresponding `.env.example` file (has all keys, no secrets)\n" +
            "  → the project's `CONTRACT.md` or `config.ts` (documents expected env vars)\n" +
            `  → the owning skill's SKILL.md (documents configuration patterns)\n\n` +
            `Blocked command: ${cmd}`,
        );
      }

      // Proxy stderr suppression: block `2>/dev/null` on any `*-proxy` command.
      // 100% Transparency — proxy errors/diagnostics must never be silenced.
      if (PROXY_PATTERN.test(cmd) && DEVNULL_PATTERN.test(cmd)) {
        throw new Error(
          "🛑 Proxy stderr suppression blocked (100% Transparency): " +
            "`*-proxy` commands must NOT use `2>/dev/null`.\n" +
            "Proxy errors, diagnostics, and status output must be visible to the agent.\n" +
            "If stdout is noisy, redirect only stdout (not stderr), or read the autosave file.\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // Proxy pipe protection: block `*-proxy do*` piped into jq/python/etc.
      // The proxy autosaves the full output to /tmp/*-proxy-autosave/.
      // Agent must call the proxy ONCE, then read the saved file for parsing.
      // Only detect pipes OUTSIDE quotes — a `|` inside a JSON payload or JS
      // expression is a literal character, not a shell pipe operator.
      if (PROXY_DO_PATTERN.test(cmd) && stripQuotedContent(cmd).includes("|")) {
        throw new Error(
          "🛑 Proxy pipe blocked (minimize proxy calls): " +
            "`*-proxy do*` must NOT be piped into jq/python/etc.\n" +
            "The proxy server returns full JSON and autosaves it to:\n" +
            "  → /tmp/whats-proxy-autosave/<action>_<timestamp>.json\n" +
            "  → /tmp/browser-proxy-autosave/<action>_<timestamp>.json\n\n" +
            "Correct flow:\n" +
            "  1. Run: whats-proxy do <action> '{...}'\n" +
            "  2. Read the autosave file (full output, no truncation)\n" +
            "  3. Parse the JSON from the saved file\n\n" +
            "This prevents overloading the proxy server with repeated calls.\n" +
            `Blocked command: ${cmd}`,
        );
      }

      if (SUDO_PATTERN.test(cmd)) {
        throw new Error(
          "🛑 tmux sudo Gate (rules/tool-discipline.md → `## tmux sudo Gate`): " +
            "raw `sudo` is never allowed directly in an agent shell.\n" +
            "Route it through a tmux pane instead (see k-tmux skill):\n" +
            "  TMUX_TIMEOUT=20 TMUX_LINES=15 tmux send-keys -t <session>:agents.2 'sudo ...' Enter\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // Sleep: extract duration, only block if > threshold
      const sleepMatch = cmd.match(SLEEP_PATTERN);
      if (sleepMatch) {
        const secs = parseFloat(sleepMatch[1]);
        if (secs > POLL_THRESHOLD_SECS) {
          throw new Error(
            "🛑 Manual polling is never allowed (rules/tool-discipline.md → " +
              "`## Tmux Stateful Command Execution`): `sleep` with duration " +
              `${secs}s exceeds the ${POLL_THRESHOLD_SECS}s threshold.\n` +
              "Launch your command in a tmux pane instead (see k-tmux skill) — " +
              "tmux-notify's <tmux-armed>/<tmux-watchdog>/<tmux-notify> will handle " +
              "waiting for you automatically, no polling needed:\n" +
              "  TMUX_TIMEOUT=30 TMUX_LINES=20 tmux send-keys -t <session>:agents.2 '<your command>' Enter\n" +
              `Blocked command: ${cmd}`,
          );
        }
      }

      // Wait (bash builtin): always blocked — inherently indeterminate, no
      // duration to extract. Pattern uses negative lookbehind to avoid
      // false positives on flags like `--wait-for-cdp`.
      if (WAIT_PATTERN.test(cmd)) {
        throw new Error(
          "🛑 Manual polling is never allowed (rules/tool-discipline.md → " +
            "`## Tmux Stateful Command Execution`): `wait` (bash builtin) is " +
            "prohibited — it is an indeterminate wait with no timeout.\n" +
            "Launch your command in a tmux pane instead (see k-tmux skill) — " +
            "tmux-notify's <tmux-armed>/<tmux-watchdog>/<tmux-notify> will handle " +
            "waiting for you automatically, no polling needed:\n" +
            "  TMUX_TIMEOUT=30 TMUX_LINES=20 tmux send-keys -t <session>:agents.2 '<your command>' Enter\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // Timeout: extract duration, only block if > threshold
      const timeoutMatch = cmd.match(TIMEOUT_PATTERN);
      if (timeoutMatch) {
        const secs = parseFloat(timeoutMatch[1]);
        if (secs > POLL_THRESHOLD_SECS) {
          throw new Error(
            "🛑 Manual polling is never allowed (rules/tool-discipline.md → " +
              "`## Tmux Stateful Command Execution`): `timeout` with duration " +
              `${secs}s exceeds the ${POLL_THRESHOLD_SECS}s threshold.\n` +
              "Launch your command in a tmux pane instead (see k-tmux skill) — " +
              "tmux-notify's <tmux-armed>/<tmux-watchdog>/<tmux-notify> will handle " +
              "waiting for you automatically, no polling needed:\n" +
              "  TMUX_TIMEOUT=30 TMUX_LINES=20 tmux send-keys -t <session>:agents.2 '<your command>' Enter\n" +
              `Blocked command: ${cmd}`,
          );
        }
      }

      return input;
    },
  };
}
