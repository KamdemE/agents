// Test for raw-exec-guard.js — simulates tool.execute.before calls.
// Four static checks (KπX, 2026-08-29 / 2026-09-01):
//   1. raw `sudo` outside tmux — blocked
//   2. raw `sleep`/`wait`/`timeout` used as manual polling outside tmux — blocked (>20s)
//   3. .env file access (secrets) — blocked unless path is .env.example*
//   4. proxy pipe (`*-proxy do*` piped into jq/python/etc.) — blocked
//   5. proxy stderr suppression (`*-proxy` + `2>/dev/null`) — blocked
// All are EXEMPT when the command is already a compliant `tmux send-keys -t ...`
// call (the quoted payload runs IN the pane, never in the agent's own shell).
// Duration threshold (KπX, 2026-08-30): sleep/timeout only blocked when
// duration > 20s (POLL_THRESHOLD_SECS). `wait` always blocked (indeterminate).
// False-positive guard: `--wait-for-cdp` and similar flags are NOT blocked.
// .env protection (KπX, 2026-09-01): commands referencing *.env* files blocked
// unless path matches *.env.example*. Closes the gap where `cat`/`less`/etc.
// could read secrets via shell (opencode.jsonc glob only covers edit+read).
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

  // --- .env file protection (KπX, 2026-09-01) ---
  // .env files → blocked
  ["cat .env (bloqué)", "cat ~/.config/mail-proxy/.env", true, "bash"],
  ["cat /foo/.env (bloqué)", "cat /foo/.env", true, "bash"],
  ["less .env.local (bloqué)", "less ./.env.local", true, "bash"],
  ["head .env.production (bloqué)", "head ./config/prod/.env.production", true, "bash"],
  ["rg SECRET in .env (bloqué)", "rg SECRET /tmp/.env.staging", true, "bash"],
  ["diff .env files (bloqué)", "diff ~/.config/x/.env ~/.config/x/.env.local", true, "bash"],
  ["cp .env (bloqué)", "cp /foo/.env /bar/.env.bak", true, "bash"],
  ["strings .env (bloqué)", "strings /proc/self/.env", true, "bash"],
  ["xxd .env (bloqué)", "xxd /home/user/.env", true, "bash"],
  ["cat /home/user/.config/tg-proxy/.env (bloqué)", "cat /home/user/.config/tg-proxy/.env", true, "bash"],

  // .env.example → allowed
  ["cat .env.example (passe)", "cat /foo/.env.example", false, "bash"],
  ["cat .env.example.local (passe)", "cat /foo/.env.example.local", false, "bash"],
  ["less .env.example (passe)", "less ~/.config/x/.env.example", false, "bash"],

  // env var names (NOT file paths) → allowed
  ["env -i bash (passe)", "env -i bash", false, "bash"],
  ["printenv HOME (passe)", "printenv HOME", false, "bash"],
  ["export MY_ENV=1 (passe)", "export MY_ENV=1", false, "bash"],

  // non-.env files with "env" in name → allowed
  ["cat myenv.txt (passe)", "cat /foo/myenv.txt", false, "bash"],
  ["echo env.prod (passe)", "echo \"env.prod\"", false, "bash"],

  // .env inside tmux send-keys → allowed (payload runs in pane, not agent shell)
  [
    "cat .env inside tmux send-keys (autorisé — payload livré au pane)",
    "tmux send-keys -t ubuntu:0.2 'cat ~/.config/mail-proxy/.env' Enter",
    false,
    "bash",
  ],

  // --- proxy pipe protection → blocked ---
  [
    "whats-proxy do with jq pipe (bloqué)",
    "whats-proxy do chat-list '{}' -a 33605957785 | jq '.data.chats'",
    true,
    "bash",
  ],
  [
    "browser-proxy do with python pipe (bloqué)",
    "browser-proxy do page-screenshot '{}' | python3 -c 'import sys; print(sys.stdin.read()[:100])'",
    true,
    "bash",
  ],
  [
    "whats-proxy do with grep pipe (bloqué)",
    "whats-proxy do whatsup '{}' -a 33605957785 | grep 'needs_reply'",
    true,
    "bash",
  ],
  [
    "whats-proxy do with sed pipe (bloqué)",
    "whats-proxy do chat-list '{}' | sed 's/\"name\"/\"nom\"/g'",
    true,
    "bash",
  ],
  [
    "tick-proxy do with head pipe (bloqué)",
    "tick-proxy do list-tasks '{}' | head -20",
    true,
    "bash",
  ],
  [
    "whats-proxy do without pipe (passe)",
    "whats-proxy do chat-list '{}' -a 33605957785",
    false,
    "bash",
  ],
  [
    "whats-proxy do with -o (passe, -o is explicit save)",
    "whats-proxy do whatsup '{}' -a 33605957785 -o /tmp/result.json",
    false,
    "bash",
  ],

  // --- proxy stderr suppression (KπX, 2026-09-01) ---
  [
    "tg-proxy 2>/dev/null (bloqué)",
    "tg-proxy do send-message '{\"chat_id\": 123}' 2>/dev/null",
    true,
    "bash",
  ],
  [
    "whats-proxy do 2>/dev/null (bloqué)",
    "whats-proxy do chat-list '{}' 2>/dev/null",
    true,
    "bash",
  ],
  [
    "tick-proxy 2>/dev/null (bloqué)",
    "tick-proxy do list-tasks '{}' 2>/dev/null",
    true,
    "bash",
  ],
  [
    "browser-proxy 2>/dev/null (bloqué)",
    "browser-proxy do page-screenshot '{}' 2>/dev/null",
    true,
    "bash",
  ],
  [
    "mail-proxy 2>/dev/null (bloqué)",
    "mail-proxy do read '{\"uid\": 42}' 2>/dev/null",
    true,
    "bash",
  ],
  [
    "whats-proxy 2 >/dev/null (bloqué, spaced redirect)",
    "whats-proxy do chat-list '{}' 2 > /dev/null",
    true,
    "bash",
  ],
  [
    "non-proxy 2>/dev/null (passe)",
    "curl -s https://example.com 2>/dev/null",
    false,
    "bash",
  ],
  [
    "proxy 2>/dev/null inside tmux send-keys (autorisé)",
    "tmux send-keys -t ubuntu:0.2 'whats-proxy do chat-list {} 2>/dev/null' Enter",
    false,
    "bash",
  ],
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
