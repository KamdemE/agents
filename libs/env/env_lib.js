// env_lib.js — shared .env helpers for .agents JS scripts (hooks).
//
// Central place for everything common to .agents Node scripts that deal with
// .env / .env.example files (secrets — KπX NEVER reads/prints values, only key
// names + whether a value is present/empty). This mirrors libs/env/env_lib.sh
// EXACTLY, language apart — see libs/AGENTS.md for the "keep the 3 twins in
// sync" rule. Callers import this module instead of re-implementing.
//
// Provided here (ESM exports; operate on key NAMES and presence, never values):
//   envKeys(path)            -> string[] : non-commented KEY names (sorted, unique)
//   envHasValue(path, key)   -> boolean  : true if <key> has a non-empty value
//   envValidateFormat(path)  -> boolean  : true if every line is blank/comment/KEY=...
//   envKeysNotInExample(env, example) -> string[] : KEYs in env missing from example
//   envIsMissingKey(env, example)     -> boolean  : some KEY of env has no counterpart
//
// SECURITY: these helpers ONLY ever return KEY NAMES or presence booleans.
// They NEVER return or read the VALUES. Keep it that way (secrets zero-touch).
//
// Caller convention: hooks import from the repo libs dir, e.g.
//   import { envKeys } from "file:///<agents>/libs/env/env_lib.js";

import fs from "node:fs";

const KEY_RE = /^([A-Za-z_][A-Za-z0-9_]*)=.*$/;

function readTextOrNull(filePath) {
  try {
    return fs.readFileSync(filePath, "utf8");
  } catch {
    return null;
  }
}

function nonCommentLines(text) {
  const out = [];
  for (const raw of text.split("\n")) {
    const line = raw.trim();
    if (!line || line.startsWith("#")) continue;
    out.push(line);
  }
  return out;
}

/** Return sorted, unique, non-commented KEY names of an env file. */
export function envKeys(filePath) {
  const text = readTextOrNull(filePath);
  if (text === null) return [];
  const keys = new Set();
  for (const line of nonCommentLines(text)) {
    const m = line.match(KEY_RE);
    if (m) keys.add(m[1]);
  }
  return [...keys].sort();
}

/** Return true if <key> exists AND has a non-empty value. */
export function envHasValue(filePath, key) {
  const text = readTextOrNull(filePath);
  if (text === null) return false;
  for (const line of nonCommentLines(text)) {
    if (line.startsWith(`${key}=`) && line.length > key.length + 1) return true;
  }
  return false;
}

/** Return true if every non-blank, non-comment line looks like KEY=value. */
export function envValidateFormat(filePath) {
  const text = readTextOrNull(filePath);
  if (text === null) return false;
  for (const line of nonCommentLines(text)) {
    if (!line.match(KEY_RE)) return false;
  }
  return true;
}

/** Return KEY names present in <env> but missing (even as empty) from <example>. */
export function envKeysNotInExample(env, example) {
  const envKeysSet = new Set(envKeys(env));
  const exampleKeys = new Set(envKeys(example));
  return [...envKeysSet].filter((k) => !exampleKeys.has(k)).sort();
}

/** Return true if some KEY of <env> has NO counterpart (even empty) in <example>. */
export function envIsMissingKey(env, example) {
  return envKeysNotInExample(env, example).length > 0;
}
