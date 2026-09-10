// raw-exec-guard.js — technically enforces two long-standing PROSE-ONLY rules
// (, 2026-08-29, following the tmux-notify TMUX_ADJUST work in this same
// session): `rules/tool-discipline.md` → `## tmux sudo Gate` ("never run raw
// sudo in agent tool shells") and the 5th tmux-notify root cause fix
// ("self-backgrounding" — never manually `sleep`/`wait`/`timeout`-poll a
// command instead of routing it through tmux). Both were documented, NEVER
// technically blocked — an agent could always just run them directly.
//
// Architecture (, 2026-09-04): two-tier check system.
//   Tier 1 — SECURITY CHECKS: always run on the full command string, even
//     inside tmux send-keys / ssh / bash -c payloads. Patterns find their
//     target ANYWHERE in the string — no wrapper exemption. Covers: .env
//     file access, secret keyword files, dotenv loading, env var disclosure,
//     proxy suppression/piping, curl secret headers.
//   Tier 2 — OPERATIONAL CHECKS: only run when the agent's own shell would
//     execute the command (NOT inside send-keys payloads). Covers: raw sudo,
//     sleep/timeout >20s polling, wait builtin. These are "do it properly"
//     rules, not security rules — the agent must route through tmux instead.
//
// Mechanism: same pattern as `make-check-guard.js` — `tool.execute.before`
// is the ONLY reliable block point (mutating `output.args` does NOT
// propagate, upstream opencode issue #31680), so the enforcement is a
// `throw new Error(...)` that aborts the tool call before it runs.
//
// Scope decision (, 2026-08-29): explicitly LIMITED to these two static,
// pre-execution checks. A 3rd idea (kill any raw command once it exceeds
// 30s and relaunch the agent) was proposed and explicitly REJECTED as
// out-of-scope for this pass — it is not achievable anyway with the current
// plugin API (no PID access, no reliable command rewriting), and  chose
// to keep this hook simple and verifiably correct rather than add a
// reactive mechanism that could only ever be an after-the-fact reminder.
//
// Duration threshold (, 2026-08-30): `sleep` and `timeout` are only
// blocked when their duration exceeds POLL_THRESHOLD_SECS (20s). Short
// sleeps/timeouts (<20s) are allowed as quick inline polls. The `wait`
// bash builtin is ALWAYS blocked — it has no duration parameter and is
// inherently an indeterminate hang.
//
// False-positive guard (, 2026-08-30): the `wait` pattern uses a
// negative lookbehind `(?<![a-zA-Z-])` so that flags like `--wait-for-cdp`
// or `--wait-for-something` are NOT blocked — only the bare `wait` bash
// builtin (preceded by space, quote, or start-of-string) triggers.
//
// Secret-file protection (, 2026-09-01, v1.21.0): blocks secret access
// at 3 layers: (1) direct file paths for ALL secret-like patterns (.env,
// .secret, .credentials, .token, .auth + .json/.env/no-extension variants),
// (2) runtime secret loading (Python dotenv, bash source, Node dotenv),
// (3) exclusions for .example files and legitimate env usage. The
// SECRET_FILE_PATTERN replaces the original ENV_FILE_PATTERN to cover the
// full spectrum of secret-file naming conventions.
//
// Proxy pipe protection (, 2026-09-01): blocks any `*-proxy do*` command
// piped into jq/python/etc. to prevent overloading the proxy server with
// repeated calls. Agent must call proxy ONCE (autosave in /tmp/*-proxy-autosave/),
// then read the saved file for parsing.
//
// False-positive fix (, 2026-09-02): the pipe check now strips quoted
// substrings before testing for `|`.  A `|` inside a single-quoted JSON
// payload or double-quoted JS expression is a literal character, NOT a
// shell pipe operator — only naked `|` outside quotes triggers the block.
//
// Proxy stderr suppression (, 2026-09-01): blocks `2>/dev/null` on any
// `*-proxy` command. The 100% Transparency mantra demands that proxy errors
// are NEVER silenced — agents MUST see failures, diagnostics, and status
// output. This covers tg-proxy, tick-proxy, whats-proxy, mail-proxy,
// browser-proxy, ts-proxy, and any future proxy.
//
// Layer 1 — File paths: any bash command referencing a secret-like file is
// blocked UNLESS the path is an `.example` variant. Covers .env, .secret,
// .credentials, .token, .auth and their .json/.env/no-extension variants.
// Path-anchored to avoid false positives on env var names like MY_ENV_VAR=1.
// Word-boundary after keyword prevents false positives on substrings
// (e.g., "messenger.json" does NOT match "secret").
//
// Layer 2 — Runtime loading (secret-file scope):
//   - Python dotenv: `python -c "from dotenv import..."` / `import dotenv`
//     / `from decouple import` / `from environ import` — blocks code that
//     LOADS .env files via libraries. Does NOT block `os.environ` access
//     (too broad, would break legitimate env debugging).
//   - Bash source: `source .env` / `. .env` — blocks sourcing .env files
//     directly. Excludes `.env.example*`.
//   - Node.js dotenv: `node -e 'require("dotenv")...'` / `import "dotenv"`
//     — blocks inline Node code loading dotenv.
//
// NOT blocked (exclusions): `os.environ`/`os.getenv` in Python inline
// (too broad), `python script.py` (can't inspect file contents), env var
// names (`MY_ENV_VAR=1`), `env`/`printenv` builtins, `.example` files.
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

// ──── Env var disclosure protection (, 2026-09-04) ────
// Blocks 5 categories of environment variable leakage:
//   1. Sensitive env var expansion: echo $API_KEY, printf "%s" $TOKEN, etc.
//   2. Filtered env extraction: env | grep TOKEN, printenv | grep SECRET, etc.
//   3. Process environ reading: cat /proc/*/environ, strings /proc/self/environ
//   4. Python/Node env dumps: python -c "import os; print(os.environ)"
//   5. History file access: cat ~/.bash_history, grep TOKEN ~/.zsh_history
// NOTE: pattern 4 (shell config sourcing: source ~/.bashrc) is intentionally
// EXCLUDED — already covered by "ask" permission in opencode.jsonc + BASH_SOURCE_ENV_PATTERN.

/** Only block sleep/timeout when duration exceeds this (seconds). */
const POLL_THRESHOLD_SECS = 20;

const SUDO_PATTERN = /\bsudo\b/;
const SLEEP_PATTERN = /\bsleep\s+([\d.]+)/;
/** Matches `wait` bash builtin only — NOT flags like `--wait-for-cdp`. */
const WAIT_PATTERN = /(?<![a-zA-Z-])\bwait\b/;
const TIMEOUT_PATTERN = /\btimeout\s+([\d.]+)/;

// .env file protection (original): match any file path ending with .env* but NOT .env.example*
// Anchored to paths (contain / or start with ~/ or ./) to avoid matching env var names.
// Examples matched: cat /foo/.env, less ~/.config/x/.env.local, head ./.env
// Examples NOT matched: cat /foo/.env.example, less x.env, export MY_ENV=1, env -i
const ENV_FILE_PATTERN = /(?:(?:^|\s)(?:[~/.][^\s]*\/[^\s]*\.env(?![\w.]*example)[^\s]*))/;

// Secret keyword patterns — ULTRA SIMPLE, block ANY token containing the keyword.
// No lookbehind, no word boundary, no flexibility. If the token contains
// "secret", "credential", "token", or "auth" — BLOCKED. Period.
// Catches ALL naming conventions: xxx-secret-yyy, xxx_secret_yyy, auth.json,
// client_secret.json, youtube_token.json, application_default_credentials.json, etc.
// EXCEPTION: .md files are ALWAYS allowed — documentation files commonly contain
// these keywords in their names (oauth-token-guide.md, secret-management.md, etc.)
const SECRET_KEYWORD_PATTERN = /secret.*\./i;      // = *secret*.*
const CREDENTIAL_KEYWORD_PATTERN = /credential.*\./i; // = *credential*.*
const TOKEN_KEYWORD_PATTERN = /token.*\./i;        // = *token*.*
const AUTH_KEYWORD_PATTERN = /auth.*\./i;          // = *auth*.*

// ──── Env var disclosure patterns (, 2026-09-04) ────
// Blocks 5 categories of environment variable leakage:
//   1. Sensitive env var expansion: echo $API_KEY, printf "%s" $TOKEN, etc.
//   2. Filtered env extraction: env | grep TOKEN, printenv | grep SECRET, etc.
//   3. Process environ reading: cat /proc/*/environ, strings /proc/self/environ
//   4. Python/Node env dumps: python -c "import os; print(os.environ)"
//   5. History file access: cat ~/.bash_history, grep TOKEN ~/.zsh_history
//
// Sensitive keywords: SECRET, TOKEN, KEY, PASSWORD, AUTH, CREDENTIAL (as words
// in env var names, separated by _). KEYBOARD_LAYOUT, TOKENIZER, AUTHOR_NAME
// are NOT matched (word boundary check via _ separator).

// 1. Sensitive env var expansion: $VAR or ${VAR} where VAR name contains
//    a sensitive keyword as a WORD (separated by _ or at start/end).
//    Matches: $API_KEY, ${SECRET_TOKEN}, $MY_PASSWORD, $DATABASE_AUTH
//    Does NOT match: $KEYBOARD_LAYOUT, $TOKENIZER, $AUTHOR_NAME, $HOME
const SENSITIVE_ENV_VAR_PATTERN =
  /\$\{?(?:[A-Z_]*_)?(?:SECRET|TOKEN|KEY|PASSWORD|AUTH|CREDENTIAL)(?:_|$)[A-Z_]*\}?/i;

// 2. Filtered env extraction: env|printenv|set|export -p|compgen -v piped
//    into grep|awk|sed|head|tail|less|more|cut|tr
const ENV_FILTER_PATTERN =
  /(?:env|printenv|set|export\s+-p|compgen\s+-v)\s*\|\s*(?:grep|awk|sed|head|tail|less|more|cut|tr)/;

// 3. Process environ reading: cat/strings/head/tail/less/more/xxd/hexdump/od
//    on /proc/*/environ (any PID including self, thread-self, or numeric)
const PROC_ENVIRON_PATTERN =
  /(?:cat|strings|head|tail|less|more|xxd|hexdump|od)\s+.*\/proc\/(?:\d+|self|thread-self)\/?environ/;

// 4. Python env dump: python/uv run python with -c/-e flag accessing os.environ
//    (dict access, method calls like .get/.items/.keys/.values, or bare usage)
const PYTHON_ENV_DUMP_PATTERN =
  /\b(?:python3?|uv\s+run\s+python3?)\s+(?:-[ce]\s+['"]?.*?)?\bos\.environ(?=[[.\s;)"`]|$)/;

// 5. Node.js env dump: node with -e/-c flag accessing process.env
const NODE_ENV_DUMP_PATTERN =
  /\bnode\s+-[ec]\s+['"].*?process\.env(?=\s|[;)"`]|$)/;

// 6. History file access: cat/less/head/tail/grep/rg/strings on shell history files
//    Matches ~/.bash_history, ~/.zsh_history, ~/.sh_history, ~/.local/share/fish/fish_history
const HISTORY_FILE_PATTERN =
  /(?:cat|less|head|tail|grep|rg|strings)\s+.*(?:\/\.(?:bash_history|zsh_history|sh_history)|\/fish\/fish_history)/;

/**
 * Check if a file path contains any secret keyword.
 * Returns { keyword: string } or null.
 * EXCEPTIONS:
 *   - .md files are ALWAYS allowed (documentation)
 *   - URLs (http://, https://) are NEVER blocked (path segments like /tokens/ are not secrets)
 *   - Tokens without a dot (no file extension) are NEVER blocked (env var names, API path segments)
 * Only matches files like *secret*.*, *token*.*, *credential*.*, *auth*. *
 */
function matchSecretKeyword(filePath) {
  if (!filePath) return null;
  if (filePath.endsWith(".md")) return null;
  for (const [name, pattern] of [
    ["secret", SECRET_KEYWORD_PATTERN],
    ["credential", CREDENTIAL_KEYWORD_PATTERN],
    ["token", TOKEN_KEYWORD_PATTERN],
    ["auth", AUTH_KEYWORD_PATTERN],
  ]) {
    if (pattern.test(filePath)) return { keyword: name };
  }
  return null;
}

/**
 * Operations that READ file content (vs. just referencing the path).
 * cp, mv, ls, chmod, ln, rm, file, stat are file-management — allowed.
 * cat, less, head, tail, rg, grep, bat, xxd, strings, nano, vim — blocked.
 */
const CONTENT_READ_PATTERN =
  /\b(?:cat|less|head|tail|bat|batcat|xxd|strings|nano|vim|nvim|view|more|od|hexdump|rg|grep)\b/;

/**
 * Check ALL command tokens for secret keywords.
 * ONLY blocks content-read operations on secret files.
 * File management (cp, mv, ls, chmod) is safe — agents need to
 * move/reference secret files without being blocked.
 * Returns { keyword, token } or null.
 */
function checkAllTokensForSecrets(cmd) {
  // Only block content-read operations — file management is safe
  if (!CONTENT_READ_PATTERN.test(cmd)) return null;

  const tokens = cmd.trim().split(/\s+/);
  for (const token of tokens) {
    if (token.startsWith("-") || token === "env" || token === "printenv") continue;
    const kw = matchSecretKeyword(token);
    if (kw) return { keyword: kw.keyword, token };
  }
  return null;
}

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

// Secret header injection: blocks curl/curls with -H containing $VAR
const SECRET_HEADER_PATTERN = /\bcurls?\s.*-H\s+['"][^'"]*\$[A-Z_]/;

// curl mutations + headers: block curl with POST/PUT/PATCH/DELETE or -H
const CURL_MUTATE = /\bcurl\b.*(?:POST|PUT|PATCH|DELETE|-H)/i;

// curls DELETE: block curls with DELETE
const CURLS_DELETE = /curls.*DELETE/i;

// send-keys confirmation injection: block y/Y/yes/o/oui/ok payloads
const SEND_KEYS_CONFIRM = /tmux\s+send-keys.*\s+['"](?:y|yes|o|oui|ok)['"]\s+Enter/i;

export default async function () {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return input;
      const cmd = output?.args?.command || input.input || "";
      if (!cmd.trim()) return input;

      // ──── SECURITY CHECKS (always run, even inside send-keys/ssh/bash payloads) ────
      // These patterns find their target ANYWHERE in the full command string.
      // No wrapper exemption — if `tmux send-keys "cat .env" Enter` is attempted,
      // the .env pattern matches and blocks. Same for ssh, bash -c, zsh -c, etc.
      // The agent must NEVER exfiltrate secrets, regardless of how the command is wrapped.

      // .env file protection: block any command referencing a .env* file
      // (secrets, tokens, passwords) unless it's a .env.example* file.
      // Covers cat, less, head, tail, bat, xxd, strings, cp, mv, diff, etc.
      const envMatch = cmd.match(ENV_FILE_PATTERN);
      if (envMatch) {
        const envPath = envMatch[0].trim();
        throw new Error(
          "🔒 .env secrets protection: access to .env files is blocked.\n" +
            "Secrets are NEVER accessible to agents — this is an absolute security rule.\n" +
            "If you need to understand a service's configuration, consult the source:\n" +
            "  → the corresponding `.env.example` file (has all keys, no secrets)\n" +
            "  → the project's `CONTRACT.md` or `config.py` (documents expected env vars)\n" +
            `  → the owning skill's SKILL.md (documents configuration patterns)\n\n` +
            `Blocked path: ${envPath}\n` +
            `Blocked command: ${cmd}`,
        );
      }

      // Secret keyword file protection: block any command referencing a file
      // that contains secret-related keywords (secret, credential, token, auth)
      // anywhere in its name. Catches: xxx-secret-yyy, secrets.json,
      // mycredentials.toml, refresh.token, session.auth.json, etc.
      const kwMatch = checkAllTokensForSecrets(cmd);
      if (kwMatch) {
        throw new Error(
          `🔒 Secret-file protection: file contains '${kwMatch.keyword}' keyword — access blocked.\n` +
            "Secrets are NEVER accessible to agents — this is an absolute security rule.\n" +
            "Blocked patterns: *secret*, *credential*, *token*, *auth* (any extension)\n" +
            "If you need to understand a service's configuration, consult the source:\n" +
            "  → the corresponding `.example` file (has all keys, no secrets)\n" +
            "  → the project's `CONTRACT.md` or `config.py` (documents expected env vars)\n" +
            `  → the owning skill's SKILL.md (documents configuration patterns)\n\n` +
            `Blocked file: ${kwMatch.token}\n` +
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

      // ──── Env var disclosure protection (, 2026-09-04) ────

      // 1. Sensitive env var expansion: block $API_KEY, ${SECRET_TOKEN}, etc.
      if (SENSITIVE_ENV_VAR_PATTERN.test(cmd)) {
        throw new Error(
          "🔒 Env var disclosure blocked: command contains expansion of a sensitive env var.\n" +
            "Sensitive keywords in var names: SECRET, TOKEN, KEY, PASSWORD, AUTH, CREDENTIAL.\n" +
            "Agents must NEVER echo/print/export variables containing secret keywords.\n" +
            "If you need a config value, read the `.env.example` file or `CONTRACT.md`.\n\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // 2. Filtered env extraction: block env|printenv|set|export|compgen piped to grep/awk/sed/etc.
      if (ENV_FILTER_PATTERN.test(cmd)) {
        throw new Error(
          "🔒 Filtered env extraction blocked: piping env dumps to filter commands is forbidden.\n" +
            "This pattern is used to extract specific env vars, which may contain secrets.\n" +
            "If you need a specific config value, read the `.env.example` file or `CONTRACT.md`.\n\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // 3. Process environ reading: block cat/strings/head/tail/less on /proc/*/environ
      if (PROC_ENVIRON_PATTERN.test(cmd)) {
        throw new Error(
          "🔒 /proc/*/environ reading blocked: agents must not read process environments.\n" +
            "Other processes may have secrets loaded in their environment.\n" +
            "If you need a service's config, read its `.env.example` file or `CONTRACT.md`.\n\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // 4. Python env dump: block python -c "import os; print(os.environ)"
      if (PYTHON_ENV_DUMP_PATTERN.test(cmd)) {
        throw new Error(
          "🔒 Python env dump blocked: accessing os.environ in inline Python is forbidden.\n" +
            "This can expose all environment variables, including loaded secrets.\n" +
            "If you need a config value, read the `.env.example` file or `CONTRACT.md`.\n\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // 5. Node.js env dump: block node -e "console.log(process.env)"
      if (NODE_ENV_DUMP_PATTERN.test(cmd)) {
        throw new Error(
          "🔒 Node.js env dump blocked: accessing process.env in inline Node is forbidden.\n" +
            "This can expose all environment variables, including loaded secrets.\n" +
            "If you need a config value, read the `.env.example` file or `CONTRACT.md`.\n\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // 6. History file access: block cat/grep on ~/.bash_history, ~/.zsh_history, etc.
      if (HISTORY_FILE_PATTERN.test(cmd)) {
        throw new Error(
          "🔒 History file access blocked: shell history may contain exported secrets.\n" +
            "Commands like `export API_KEY=xxx` are often stored in history files.\n" +
            "If you need to know what was run, check the session log instead.\n\n" +
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

      // Secret header injection: block curl/curls with -H containing $VAR
      if (SECRET_HEADER_PATTERN.test(cmd)) {
        throw new Error(
          "🔒 Secret header blocked — never put $VAR in curl/curls -H headers.\n" +
            "Use `with-env curls -p <provider>` in tmux (k-tmux) instead.\n" +
            "Read `k-clis/assets/providers.json` to find the provider name.\n\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // curls DELETE: block curls with DELETE
      if (CURLS_DELETE.test(cmd)) {
        throw new Error(
          "🔒 curls DELETE blocked — ask the user to do it via the dashboard.\n\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // curl blocked: agent must use curls instead
      if (CURL_MUTATE.test(cmd)) {
        throw new Error(
          "🔒 curl is forbidden — use `curls` instead.\n" +
            "Launch in tmux (k-tmux) for  approval or for secret injection with `with-env`.\n" +
            "Read `k-clis/assets/providers.json` to find the right provider name.\n\n" +
            "Examples:\n" +
            "  curls https://api.example.com/public          (no secret)\n" +
            "  with-env curls -p cloudflare https://api.cloudflare.com/...  (secret)\n\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // send-keys confirmation injection: block y/Y/yes/o/oui
      if (SEND_KEYS_CONFIRM.test(cmd)) {
        throw new Error(
          "🔒 Auto-injection of confirmation responses is blocked.\n" +
            "HITL confirmation must be interactive — never pre-inject 'y'/'Y'/'yes' via send-keys.\n\n" +
            `Blocked command: ${cmd}`,
        );
      }

      // ──── OPERATIONAL CHECKS (exempt inside send-keys/ssh/bash payloads) ────
      // These are "do it properly" rules, not security rules. When the agent
      // routes through tmux/ssh, the payload executes in the target — not here.
      // Security checks above already caught dangerous content in payloads.
      if (SEND_KEYS_REGEX.test(cmd)) return input;

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
