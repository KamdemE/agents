// humanize_lib.js — shared humanize / PROSE guards for .agents JS hooks (ESM).
//
// Central place for the Tier PROSE bloquant dash checks and related helpers.
// This mirrors libs/humanize/humanize_lib.sh EXACTLY, language apart — see
// libs/AGENTS.md for the mandatory "keep the 3 twins in sync" rule.
// Callers import from the repo libs dir, e.g.
//   import { containsBlockedDash } from "file://$HOME/Labs/.agents/libs/humanize/humanize_lib.js";
//
// Validated by the user — 4 PROSE regex (Tier PROSE bloquant):
//   EM_DASH_TRIPLE     = /---/            LaTeX em-dash
//   EM_DASH_UNICODE    = /\u2014/         — U+2014
//   EN_DASH_SPACED     = / \u2013 /       – U+2013 spaced (blocked)
//   DOUBLE_DASH_SPACED = / -- /           markdown substitut
//
// Hardened: also blocks escaped/encoded forms: \\u2014, \\U00002014, \\xE2\\x80\\x94, \\N{EM DASH}, chr(8212)/chr(0x2014)
// Alternative dure for EN DASH: block spaced en-dash ONLY,
// allow interval form [0-9]–[0-9] or [A-Za-z]–[A-Za-z] collé.
//
// Provided here (ESM exports; camelCase per libs/AGENTS.md twin rule):
//   isAllowedEnDash(text)              -> boolean : true=allowed, false=blocked
//   containsBlockedDash(text)          -> { blocked, pattern, snippet } (also blocks escapes)
//   decodeUnicodeEscapesForCheck(text) -> string  : decode escapes to real chars for second-pass check
//   containsBlockedDashWithEscapes(text) -> alias of containsBlockedDash (compat)
//   isCodeFile(path)            -> boolean : true if code (whitelisted)
//   isProseFile(path)           -> boolean : true if prose extension
//   stripTmuxWrapper(cmd)       -> string  : strip send-keys wrapper → payload
//   extractBashPayload(cmd)     -> string  : alias of stripTmuxWrapper
//
// Reference:  validated — single source of truth for PROSE dash
// Single source for SEND_KEYS_REGEX: skills/k-opencode/scripts/plugins/libs/tmux-patterns.js

// --- Tier PROSE bloquant patterns ---
export const EM_DASH_TRIPLE = "---";
export const EM_DASH_UNICODE = "\u2014"; // —
export const EN_DASH_SPACED = " \u2013 "; // space–space
export const DOUBLE_DASH_SPACED = " -- "; // space--space

// Compiled regex for detection (mirrors shell grep / Python re)
export const EM_DASH_TRIPLE_RE = /---/;
export const EM_DASH_UNICODE_RE = /\u2014/;
export const DOUBLE_DASH_SPACED_RE = / -- /;
export const EN_DASH_SPACED_RE = / \u2013 /;

// --- Escaped / encoded bypasses (hardened, K\u03c0X) ---
// Covers: \\u2012..2015, \\U00002012..00002015, \\xE2\\x80\\x92..95, \\N{EM DASH}, chr(8210..13 / 0x2012..15)
export const ESCAPED_U4_RE = /\\u201[2-5]/i;
export const ESCAPED_U8_RE = /\\U0000201[2-5]/i;
export const ESCAPED_X_RE = /\\xE2\\x80\\x9[2-5]/i;
export const ESCAPED_N_RE = /\\N\{(?:EM DASH|EN DASH|FIGURE DASH|HORIZONTAL BAR)\}/i;
export const ESCAPED_CHR_RE = /chr\s*\(\s*(?:821[0-3]|0x201[2-5])\s*\)/i;

// SEND_KEYS_REGEX — mirrors tmux-patterns.js single source
export const SEND_KEYS_REGEX = /tmux\s+send-keys\s+(?:-l\s+|-p\s+)?-t\s+[%$@\w.:-]+/;

// Interval form: alnum–alnum collé (no spaces) — allowed
export const INTERVAL_RE = /[A-Za-z0-9]\u2013[A-Za-z0-9]/;

// --- Code extensions whitelisted (isCodeFile → true = skip) ---
const CODE_EXTS = new Set([
  "py", "js", "ts", "tsx", "jsx", "go", "rs", "java", "c", "cpp",
  "h", "hpp", "sh", "bash", "zsh", "json", "yaml", "yml", "toml",
  "lock", "svg", "png", "jpg", "jpeg", "pdf", "pyc", "class", "o",
  "so", "dylib", "db", "sqlite",
]);

const PROSE_EXTS = new Set(["md", "tex", "txt", "rst", "adoc", "mdx", "html"]);

function extOf(filePath) {
  const base = String(filePath).split("/").pop() || "";
  const dot = base.lastIndexOf(".");
  if (dot === -1) return "";
  return base.slice(dot + 1).toLowerCase();
}

/** Return true if path has a code whitelisted extension (should be skipped). */
export function isCodeFile(filePath) {
  const ext = extOf(filePath);
  if (!ext) return false;
  return CODE_EXTS.has(ext);
}

/** Return true if path has a prose extension (md, tex, txt, ...). */
export function isProseFile(filePath) {
  const ext = extOf(filePath);
  return PROSE_EXTS.has(ext);
}

/**
 * Return true if en-dash usage is allowed, false if blocked.
 * Logic (dure alternative):
 *   - " – " (space–space) → blocked → false
 *   - "–" with no surrounding spaces AND alnum on both sides (interval) → allowed → true
 *   - no en-dash → allowed → true
 *   - any other en-dash without spaced form → allowed (only spaced is bloquant)
 * Mirrors humanize_lib.sh:is_allowed_en_dash and humanize_lib.py:is_allowed_en_dash.
 */
export function isAllowedEnDash(text) {
  if (text.includes(EN_DASH_SPACED)) return false;
  if (!text.includes("\u2013")) return true;
  // Has en-dash but not spaced → allowed per dure alternative
  return true;
}

/**
 * Decode escaped / encoded dash forms to their literal unicode for second-pass check.
 * Replaces: \u2012..\u2015, \U00002012.., \xE2\x80\x92..95, \N{EM DASH}/etc, chr(8210..)
 * Returns decoded string (original if no escapes). Used as defense-in-depth after raw check.
 */
export function decodeUnicodeEscapesForCheck(text) {
  let s = String(text);
  s = s.replace(/\\u201([2-5])/gi, (_, d) => {
    const code = parseInt("201" + d, 16);
    return String.fromCharCode(code);
  });
  s = s.replace(/\\U0000201([2-5])/gi, (_, d) => {
    const code = parseInt("201" + d, 16);
    return String.fromCharCode(code);
  });
  s = s.replace(/\\xE2\\x80\\x9([2-5])/gi, (_, d) => {
    const map = { "2": "\u2012", "3": "\u2013", "4": "\u2014", "5": "\u2015" };
    return map[d] || _;
  });
  s = s.replace(/\\N\{(?:EM DASH|HORIZONTAL BAR)\}/gi, "\u2014");
  s = s.replace(/\\N\{EN DASH\}/gi, "\u2013");
  s = s.replace(/\\N\{FIGURE DASH\}/gi, "\u2012");
  s = s.replace(/chr\s*\(\s*(821[0-3])\s*\)/gi, (_, n) => String.fromCharCode(parseInt(n, 10)));
  s = s.replace(/chr\s*\(\s*0x201([2-5])\s*\)/gi, (_, d) => String.fromCharCode(parseInt("201" + d, 16)));
  return s;
}

// Internal: check escaped patterns and return blocked if found (with dynamic pattern name)
function _checkEscaped(text) {
  let m;
  m = text.match(ESCAPED_U4_RE);
  if (m) {
    const hex = m[0].replace(/^\\u/i, "").toUpperCase();
    return { blocked: true, pattern: `ESCAPED_U${hex}`, snippet: m[0] };
  }
  m = text.match(ESCAPED_U8_RE);
  if (m) {
    const hex = m[0].replace(/^\\U0*/i, "").toUpperCase();
    // normalize to U2014 form
    return { blocked: true, pattern: `ESCAPED_U${hex}`, snippet: m[0] };
  }
  m = text.match(ESCAPED_X_RE);
  if (m) {
    // map third byte 92..95 to 2012..2015
    const tail = m[0].slice(-2).toLowerCase();
    const map = { "92": "2012", "93": "2013", "94": "2014", "95": "2015" };
    const code = map[tail] || "2014";
    return { blocked: true, pattern: `ESCAPED_X_${code}`, snippet: m[0] };
  }
  m = text.match(ESCAPED_N_RE);
  if (m) {
    const up = m[0].toUpperCase();
    const tag = up.includes("EM DASH") ? "EM_DASH" : up.includes("EN DASH") ? "EN_DASH" : up.includes("FIGURE") ? "FIGURE_DASH" : "HORIZONTAL_BAR";
    return { blocked: true, pattern: `ESCAPED_N_${tag}`, snippet: m[0] };
  }
  m = text.match(ESCAPED_CHR_RE);
  if (m) {
    const inner = m[0].replace(/chr\s*\(\s*/i, "").replace(/\s*\)/, "");
    const isHex = inner.toLowerCase().startsWith("0x");
    const code = isHex ? inner.toUpperCase() : inner;
    return { blocked: true, pattern: `ESCAPED_CHR_${code}`, snippet: m[0] };
  }
  return null;
}

/**
 * Check text for any Tier PROSE bloquant dash pattern.
 * Returns { blocked, pattern, snippet } — snippet is first matched literal.
 * Priority: ESCAPED_* -> EM_DASH_TRIPLE → EM_DASH_UNICODE → DOUBLE_DASH_SPACED → EN_DASH_SPACED -> decoded second pass
 * Mirrors humanize_lib.sh:contains_blocked_dash and humanize_lib.py:contains_blocked_dash.
 */
export function containsBlockedDash(text) {
  // Defense layer 1: raw escaped forms (even before decode)
  const esc = _checkEscaped(text);
  if (esc) return esc;

  let m;
  // EM_DASH_TRIPLE: a `---` INSIDE a line is the LaTeX em-dash (blocked);
  // a line that IS exactly `---` is the YAML front-matter delimiter /
  // markdown HR (allowed) — mirrors the standalone-HR exemption that
  // scripts/check-dashes.sh already applies line by line. Fixed 2026-08-08:
  // the raw /---/ match used to block every YAML front-matter block.
  const tripleInline = String(text)
    .split(/\r?\n/)
    .find(
      (line) =>
        line.trim() !== EM_DASH_TRIPLE && line.includes(EM_DASH_TRIPLE)
    );
  if (tripleInline !== undefined) {
    return { blocked: true, pattern: "EM_DASH_TRIPLE", snippet: EM_DASH_TRIPLE };
  }

  m = text.match(EM_DASH_UNICODE_RE);
  if (m) return { blocked: true, pattern: "EM_DASH_UNICODE", snippet: m[0] };

  m = text.match(DOUBLE_DASH_SPACED_RE);
  if (m) return { blocked: true, pattern: "DOUBLE_DASH_SPACED", snippet: m[0] };

  // EN_DASH_SPACED — only spaced form is blocked (dure alternative)
  m = text.match(EN_DASH_SPACED_RE);
  if (m) return { blocked: true, pattern: "EN_DASH_SPACED", snippet: m[0] };

  // Defense layer 2: decode escapes then re-check literals (catches \u2014 -> — etc)
  const decoded = decodeUnicodeEscapesForCheck(text);
  if (decoded !== text) {
    m = decoded.match(EM_DASH_UNICODE_RE);
    if (m) return { blocked: true, pattern: "ESCAPED_DECODED_EM_DASH", snippet: m[0] };
    m = decoded.match(EN_DASH_SPACED_RE);
    if (m) return { blocked: true, pattern: "ESCAPED_DECODED_EN_DASH_SPACED", snippet: m[0] };
    // Also catch decoded figure/horizontal bar as em/en variants (2012/2015)
    if (decoded.includes("\u2012") || decoded.includes("\u2015")) {
      const ch = decoded.includes("\u2012") ? "\u2012" : "\u2015";
      return { blocked: true, pattern: "ESCAPED_DECODED_DASH", snippet: ch };
    }
  }

  return { blocked: false, pattern: null, snippet: null };
}

/** Alias for compat — callers that used containsBlockedDashWithEscapes */
export function containsBlockedDashWithEscapes(text) {
  return containsBlockedDash(text);
}

/**
 * Strip outer tmux send-keys wrapper and return inner payload.
 * If cmd matches SEND_KEYS_REGEX, extracts first quoted payload; else returns cmd.
 * Crude extraction for hook reuse — mirrors humanize_lib.sh:strip_tmux_wrapper.
 */
export function stripTmuxWrapper(cmd) {
  if (!SEND_KEYS_REGEX.test(cmd)) return cmd;

  let m = cmd.match(/send-keys[^']*'([^']*)'/);
  if (m) return m[1];

  m = cmd.match(/send-keys[^"]*"([^"]*)"/);
  if (m) return m[1];

  return cmd;
}

/** Alias of stripTmuxWrapper — crude heredoc/quoted payload extraction. */
export function extractBashPayload(cmd) {
  return stripTmuxWrapper(cmd);
}
