// env_lib.js — shared .env helpers for .agents JS scripts (hooks).
//
// Central place for everything common to .agents Node scripts that deal with
// .env / .env.example files (secrets — KπX NEVER prints or returns values, only key
// names + whether a value is present/empty). This mirrors libs/env/env_lib.sh
// EXACTLY, language apart — see libs/AGENTS.md for the "keep the 3 twins in
// sync" rule. Callers import this module instead of re-implementing.
//
// Provided here (ESM exports; expose key NAMES and presence, never values):
//   envKeys(path)            -> string[] : non-commented KEY names (sorted, unique)
//   envHasValue(path, key)   -> boolean  : true if <key> has a non-empty value
//   envHasExactEmptyValue(path, key) -> boolean : true if <key>'s final value is exactly empty
//   envValidateFormat(path)  -> boolean  : true if every line is blank/comment/KEY=...
//   envKeysNotInExample(env, example) -> string[] : KEYs in env missing from example
//   envIsMissingKey(env, example)     -> boolean  : some KEY of env has no counterpart
//   envLoad(path)                     -> boolean  : load strict KEY=value data safely
//
// SECURITY: these helpers ONLY ever return KEY NAMES or presence booleans.
// They NEVER return VALUES. They may inspect values internally only to determine
// presence or load a value into the caller environment.
//
// Caller convention: hooks import from the repo libs dir, e.g.
//   import { envKeys } from "file:///<agents>/libs/env/env_lib.js";

import fs from "node:fs";

const KEY_RE = /^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/;
const KEY_NAME_RE = /^[A-Za-z_][A-Za-z0-9_]*$/;

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
    if (!raw.trim() || raw.startsWith("#")) continue;
    out.push(raw);
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
  if (!KEY_NAME_RE.test(key)) return false;
  const text = readTextOrNull(filePath);
  if (text === null) return false;
  let rawValue = null;
  for (const line of nonCommentLines(text)) {
    const match = line.match(KEY_RE);
    if (match && match[1] === key) rawValue = match[2];
  }
  return ![null, "", '""', "''"].includes(rawValue);
}

/** Return true if <key>'s final assignment is exactly KEY=. */
export function envHasExactEmptyValue(filePath, key) {
  if (!KEY_NAME_RE.test(key)) return false;
  const text = readTextOrNull(filePath);
  if (text === null) return false;
  let rawValue = null;
  for (const line of nonCommentLines(text)) {
    const match = line.match(KEY_RE);
    if (match && match[1] === key) rawValue = match[2];
  }
  return rawValue === "";
}

/** Return true if every non-blank, non-comment line looks like KEY=value. */
export function envValidateFormat(filePath) {
  const text = readTextOrNull(filePath);
  if (text === null) return false;
  for (const line of nonCommentLines(text)) {
    if (!KEY_RE.test(line)) return false;
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

/** Load strict KEY=value data without evaluating shell syntax. */
export function envLoad(filePath) {
  const text = readTextOrNull(filePath);
  if (text === null) return false;
  const assignments = [];
  for (const line of nonCommentLines(text)) {
    const match = line.match(KEY_RE);
    if (!match) return false;
    const [, key, rawValue] = match;
    let value = rawValue;
    if (value.length >= 2 && (value.startsWith('"') && value.endsWith('"') || value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    assignments.push([key, value]);
  }
  for (const [key, value] of assignments) process.env[key] = value;
  return true;
}
