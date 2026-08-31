// Test for raw-exec-guard.js — simulates tool.execute.before calls.
// Two static checks only (KπX, 2026-08-29 — 3rd "kill after 30s" idea
// explicitly rejected as out of scope): raw `sudo` outside tmux, and raw
// `sleep`/`wait`/`timeout` used as manual polling outside tmux. Both are
// EXEMPT when the command is already a compliant `tmux send-keys -t ...`
// call (the quoted payload runs IN the pane, never in the agent's own
// shell).
// Duration threshold (KπX, 2026-08-30): sleep/timeout only blocked when
// duration > 20s (POLL_THRESHOLD_SECS). `wait` always blocked (indeterminate).
// False-positive guard: `--wait-for-cdp` and similar flags are NOT blocked.
// Run from the repo root: node skills/k-opencode/tests/hooks/raw-exec-guard.test.mjs
import { fileURLToPath } from "node:url";

const hookPath = fileURLToPath(
  new URL("../../scripts/plugins/hooks/raw-exec-guard.js", import.meta.url),
);
const hook = await import(hookPath);
const plugin = await hook.default();
const before = plugin["tool.execute.before"];

const cases = [
  // --- raw sudo outside tmux → blocked ---
  ["raw sudo (bloqué)", "sudo apt update", true, "bash"],
  ["raw sudo with args (bloqué)", "sudo -n true", true, "bash"],
  ["sudo inside bash -c wrapper (bloqué, search-anywhere)", "bash -c 'sudo ls /'", true, "bash"],
  ["sudo mid-chain (bloqué)", "cd /tmp && sudo rm -rf /tmp/x", true, "bash"],

  // --- sudo as substring of another word → NOT blocked (word boundary) ---
  ["pseudo (mot différent, passe)", "echo pseudo-random", false, "bash"],
  ["sudoers (mot différent, passe)", "cat /etc/sudoers.d/readme", false, "bash"],

  // --- sudo wrapped in a compliant tmux send-keys → allowed ---
  [
    "sudo inside tmux send-keys payload (autorisé — payload livré au pane)",
    "TMUX_TIMEOUT=20 TMUX_LINES=15 tmux send-keys -t ubuntu:0.2 'sudo apt update' Enter",
    false,
    "bash",
  ],

  // --- raw sleep outside tmux → blocked ONLY if > 20s ---
  ["raw sleep 60s (bloqué, >20)", "sleep 60", true, "bash"],
  ["raw sleep 21s (bloqué, >20)", "sleep 21", true, "bash"],
  ["raw sleep 20s (passe, not >20)", "sleep 20", false, "bash"],
  ["raw sleep 5s (passe, <20)", "sleep 5", false, "bash"],
  ["raw sleep 0.5s (passe, <20)", "sleep 0.5", false, "bash"],
  ["sleep mid-chain 60s (bloqué, >20)", "nohup cmake --build . & sleep 60", true, "bash"],
  ["sleep mid-chain 5s (passe, <20)", "nohup cmake --build . & sleep 5", false, "bash"],

  // --- raw wait outside tmux → always blocked (indeterminate, no duration) ---
  ["raw wait with $! (bloqué)", "wait $!", true, "bash"],
  ["raw wait standalone (bloqué)", "wait", true, "bash"],

  // --- wait as flag/substring → NOT blocked (false-positive guard) ---
  ["--wait-for-cdp (passe, flag not wait command)", "edge-launch --wait-for-cdp", false, "bash"],
  ["--wait-for-cdp with other args (passe)", "curl --wait-for-cdp 5000", false, "bash"],
  ["--wait-for-something (passe)", "app --wait-for-signal", false, "bash"],
  ["await (mot différent, passe)", "grep -r 'await fetch' src/", false, "bash"],

  // --- raw timeout outside tmux → blocked ONLY if > 20s ---
  ["raw timeout 30s (bloqué, >20)", "timeout 30 curl example.com", true, "bash"],
  ["raw timeout 21s (bloqué, >20)", "timeout 21 curl example.com", true, "bash"],
  ["raw timeout 20s (passe, not >20)", "timeout 20 curl example.com", false, "bash"],
  ["raw timeout 5s (passe, <20)", "timeout 5 curl example.com", false, "bash"],
  ["raw timeout 0.5s (passe, <20)", "timeout 0.5 curl example.com", false, "bash"],

  // --- sleep/wait/timeout wrapped in tmux send-keys → allowed ---
  [
    "sleep inside tmux send-keys payload (autorisé)",
    "tmux send-keys -t ubuntu:1.0 'sleep 60 && echo done' Enter",
    false,
    "bash",
  ],

  // --- ordinary commands → pass ---
  ["ls ordinaire (passe)", "ls -la /tmp", false, "bash"],
  ["git status (passe)", "git status", false, "bash"],

  // --- non bash tool → pass ---
  ["non bash tool (passe)", "sudo anything", false, "read"],
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
