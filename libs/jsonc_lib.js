// jsonc_lib.js — shared JSONC helpers for .agents JS scripts (hooks).
//
// Central place for everything common to .agents Node scripts that deal with
// JSONC assets (config-with-comments — the KπX standard, see k-project and
// `libs/jsonc_lib.sh` for the shell twin, `libs/jsonc_lib.py` for Python).
//
// Provided here (ESM exports):
//   stripJsonc(src)      -> string : remove // and /* */ comments (respects strings)
//   loadJsoncObj(path)   -> object : parse a JSONC file into a plain object ({} on failure)
//   loadJsonc(path)      -> any    : parse a JSONC file into its JSON value (null on failure)
//
// Caller convention: hooks import from the repo libs dir, e.g.
//   import { stripJsonc } from "file:///<agents>/libs/jsonc_lib.js";

import fs from "node:fs";

/** Remove line and block comments from a JSONC string, respecting string literals. */
export function stripJsonc(src) {
  let out = "";
  let inString = false;
  let inBlock = false;
  for (let i = 0; i < src.length; i++) {
    const c = src[i];
    const n = src[i + 1];
    if (inBlock) {
      if (c === "*" && n === "/") { inBlock = false; i++; }
      continue;
    }
    if (inString) {
      out += c;
      if (c === "\\") { out += src[++i] ?? ""; }
      else if (c === '"') { inString = false; }
      continue;
    }
    if (c === '"') { inString = true; out += c; continue; }
    if (c === "/" && n === "/") { while (i < src.length && src[i] !== "\n") i++; continue; }
    if (c === "/" && n === "*") { inBlock = true; i++; continue; }
    out += c;
  }
  return out;
}

/** Parse a JSONC file (comments stripped) and return its JSON value, or null on failure. */
export function loadJsonc(filePath) {
  try {
    return JSON.parse(stripJsonc(fs.readFileSync(filePath, "utf8")));
  } catch {
    return null;
  }
}

/** Parse a JSONC file into a plain object, or {} on any failure. */
export function loadJsoncObj(filePath) {
  const value = loadJsonc(filePath);
  return value !== null && typeof value === "object" && !Array.isArray(value)
    ? value
    : {};
}
