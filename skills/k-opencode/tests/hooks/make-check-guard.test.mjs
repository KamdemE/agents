// Test for make-check-guard.js — simulates tool.execute.before calls.
// Ultra-simple logic (KπX): find FIRST `make check` anywhere; if a blank
// (whitespace) appears after it → block. Otherwise allow.
// Run from the repo root: node skills/k-opencode/tests/hooks/make-check-guard.test.mjs
import { fileURLToPath } from "node:url";

// Hook lives in scripts/plugins/hooks/ — this test lives in tests/hooks/, so resolve
// relative to THIS file (../../scripts/plugins/hooks/), no hardcoded absolute path.
const hookPath = fileURLToPath(
  new URL("../../scripts/plugins/hooks/make-check-guard.js", import.meta.url),
);
const hook = await import(hookPath);
const plugin = await hook.default();
const before = plugin["tool.execute.before"];

const cases = [
  // --- happy path: bare `make check` must pass ---
  ["make check exact (doit passer)", "make check", false, "bash"],
  ["cd\\nmake check (2-lignes sans pipe, passe)", "cd ~/.agents\nmake check", false, "bash"],

  // --- anything after make check (blank) → block ---
  ["pipe", "make check 2>&1 | rg error", true, "bash"],
  ["redirect", "make check > /tmp/x", true, "bash"],
  ["&&", "make check && make push", true, "bash"],
  [";", "make check; make push", true, "bash"],
  ["args", "make check --foo", true, "bash"],
  ["2>&1", "make check 2>&1", true, "bash"],
  ["cd&& wrapper", "cd ~/.agents && make check 2>&1", true, "bash"],
  ["2-lignes + pipe (le cas qui a ÉCHOUÉ)", "cd ~/.agents\nmake check 2>&1 | rg error", true, "bash"],

  // --- shell wrappers (the reported hole) → now blocked ---
  ["bash -c wrapper", "bash -c 'cd ~/.agents/ && make check | grep error'", true, "bash"],
  ["zsh -c wrapper", "zsh -c 'cd ~/.agents/ && make check 2>&1 | rg error'", true, "bash"],
  ["sh -c wrapper", "sh -c 'cd ~/.agents && make check > /tmp/x'", true, "bash"],

  // --- distinct targets (no blank after check) → pass ---
  ["make check-skills (target diff, passe)", "make check-skills", false, "bash"],
  ["make check-jsonc (target diff, passe)", "make check-jsonc", false, "bash"],

  // --- string mention (accepted false positive under ultra-simple logic) ---
  ["grep 'make check' file (bloqué par logique ultra-simple, accepté)", "grep 'make check' file", true, "bash"],

  // --- non bash tool → pass ---
  ["non bash tool (passe)", "anything", false, "read"],
];

let pass = 0;
let fail = 0;
for (const [label, cmd, expectBlock, tool] of cases) {
  const output = { args: { command: cmd } };
  let blocked = false;
  let errMsg = "";
  try {
    await before({ tool }, output);
  } catch (e) {
    blocked = true;
    errMsg = e.message;
  }
  const ok = blocked === expectBlock;
  if (ok) {
    pass += 1;
  } else {
    fail += 1;
  }
  console.log(
    `${ok ? "PASS" : "FAIL"} | ${label} | expectBlock=${expectBlock} | got=${blocked ? "BLOCKED" : "allowed"}` +
      (errMsg ? `\n      ${errMsg.split("\n")[0]}` : ""),
  );
}
console.log(`\n${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
