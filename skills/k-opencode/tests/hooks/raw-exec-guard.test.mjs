// Test for raw-exec-guard.js — simulates tool.execute.before calls.
// Five static checks (, 2026-08-29 / 2026-09-01 / 2026-09-02):
//   1. raw `sudo` outside tmux — blocked
//   2. raw `sleep`/`wait`/`timeout` used as manual polling outside tmux — blocked (>20s)
//   3. secret file access (.env, .secret, .credentials, .token, .auth) — blocked unless .example*
//   4. proxy pipe (`*-proxy do*` piped into jq/python/etc.) — blocked
//      → 2026-09-02: pipe detection now strips quoted content first to avoid
//        false positives on `|` inside JSON payloads / JS expressions
//   5. proxy stderr suppression (`*-proxy` + `2>/dev/null`) — blocked
// All are EXEMPT when the command is already a compliant `tmux send-keys -t ...`
// call (the quoted payload runs IN the pane, never in the agent's own shell).
// Duration threshold (, 2026-08-30): sleep/timeout only blocked when
// duration > 20s (POLL_THRESHOLD_SECS). `wait` always blocked (indeterminate).
// False-positive guard: `--wait-for-cdp` and similar flags are NOT blocked.
// Secret-file protection (, 2026-09-01, v1.21.0): commands referencing
// secret-like files blocked unless path matches *.example*. Covers .env,
// .secret, .credentials, .token, .auth + .json/.env/no-extension variants.
// Word-boundary after keyword prevents false positives on substrings.
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

  // --- .env file protection (, 2026-09-01) ---
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

  // non-secret files with "env" in name → allowed
  ["cat myenv.txt (passe)", "cat /foo/myenv.txt", false, "bash"],
  ["echo env.prod (passe)", "echo \"env.prod\"", false, "bash"],

  // --- secret-file protection (v1.21.0: expanded patterns) ---
  // .secret / .secrets → blocked
  ["cat secrets.json (bloqué)", "cat /home/user/.agents/config/secrets.json", true, "bash"],
  ["less .secret (bloqué)", "less /foo/.secret", true, "bash"],
  ["rg KEY secrets.json (bloqué)", "rg API_KEY /tmp/secrets.json", true, "bash"],
  ["head .secret.local (bloqué)", "head .secret.local", true, "bash"],

  // .credentials / .credential → blocked
  ["cat credentials.json (bloqué)", "cat ~/.config/proxy/credentials.json", true, "bash"],
  ["less .credential (bloqué)", "less /foo/.credential", true, "bash"],
  ["cat creds.credentials (bloqué)", "cat /tmp/app/creds.credentials", true, "bash"],

  // .token / .tokens → blocked
  ["cat token.json (bloqué)", "cat /home/user/.config/app/token.json", true, "bash"],
  ["less .tokens (bloqué)", "less /foo/.tokens", true, "bash"],
  ["rg KEY token.json (bloqué)", "rg SECRET /tmp/auth/token.json", true, "bash"],
  ["cat refresh.tokens (bloqué)", "cat /tmp/tokens.refresh", true, "bash"],

  // .auth → blocked
  ["cat auth.json (bloqué)", "cat ~/.config/proxy/auth.json", true, "bash"],
  ["less .auth (bloqué)", "less /foo/.auth", true, "bash"],
  ["cat session.auth (bloqué)", "cat /tmp/session.auth", true, "bash"],

  // .env.* variants (beyond bare .env) → blocked
  ["cat .env.local (bloqué)", "cat /foo/.env.local", true, "bash"],
  ["cat .env.production (bloqué)", "cat /foo/.env.production", true, "bash"],
  ["cat .env.staging.json (bloqué)", "cat /foo/.env.staging.json", true, "bash"],

  // .secret.json, .credentials.json, .token.json, .auth.json → blocked
  ["cat .secret.json (bloqué)", "cat /home/user/.secret.json", true, "bash"],
  ["cat .credentials.json (bloqué)", "cat /home/user/.credentials.json", true, "bash"],
  ["cat .token.json (bloqué)", "cat /home/user/.token.json", true, "bash"],
  ["cat .auth.json (bloqué)", "cat /home/user/.auth.json", true, "bash"],

  // .env.example → allowed
  ["cat .env.example (passe)", "cat /foo/.env.example", false, "bash"],
  ["cat .env.example.local (passe)", "cat /foo/.env.example.local", false, "bash"],
  ["less .env.example (passe)", "less ~/.config/x/.env.example", false, "bash"],

  // example files for non-.env secrets → BLOCKED (still contain secret keywords)
  ["cat secrets.example.json (bloqué)", "cat /foo/secrets.example.json", true, "bash"],
  ["cat credentials.example (bloqué)", "cat /foo/credentials.example", true, "bash"],
  ["cat token.example.json (bloqué)", "cat /foo/token.example.json", true, "bash"],
  ["cat auth.example.json (bloqué)", "cat /foo/auth.example.json", true, "bash"],

  // keyword as substring → BLOCKED (ultra-strict: ANY token containing keyword)
  ["cat messenger.json (passe — no keyword)", "cat /foo/messenger.json", false, "bash"],
  ["cat tokenizer.py (bloqué — contains 'token')", "cat /foo/tokenizer.py", true, "bash"],
  ["cat authored.txt (bloqué — contains 'auth')", "cat /foo/authored.txt", true, "bash"],
  ["cat netherlands.json (passe — 'env' not in keyword list)", "cat /foo/netherlands.json", false, "bash"],

  // .md files with secret keywords → ALWAYS allowed (documentation exception)
  ["cat auth.md (passe — .md exception)", "cat /foo/auth.md", false, "bash"],
  ["cat token-guide.md (passe — .md exception)", "cat /foo/token-guide.md", false, "bash"],
  ["cat secret-management.md (passe — .md exception)", "cat /foo/secret-management.md", false, "bash"],
  ["cat credentials.md (passe — .md exception)", "cat /foo/credentials.md", false, "bash"],
  ["cat oauth-token.md (passe — .md exception)", "cat /foo/oauth-token.md", false, "bash"],
  ["less authentication.md (passe — .md exception)", "less /foo/authentication.md", false, "bash"],
  ["head api-key.md (passe — .md exception)", "head /foo/api-key.md", false, "bash"],
  ["rg search token-setup.md (passe — .md exception, search pattern has no keyword)", "rg search /foo/token-setup.md", false, "bash"],
  ["rg TOKEN token-setup.md (bloqué — search pattern 'TOKEN' has keyword)", "rg TOKEN /foo/token-setup.md", true, "bash"],
  ["cat ~/docs/secret-patterns.md (passe — .md exception)", "cat ~/docs/secret-patterns.md", false, "bash"],

  // --- Real-world secret files (, 2026-09-03) ---
  // Google Cloud application default credentials
  ["cat application_default_credentials.json (bloqué — gcloud ADC)", "cat $HOME/.config/gcloud/application_default_credentials.json", true, "bash"],
  ["python3 load gcloud ADC (bloqué)", "python3 -c \"import json; d=json.load(open('$HOME/.config/gcloud/application_default_credentials.json')); print(d)\"", true, "bash"],
  // YouTube / GWS tokens
  ["cat youtube_token.json (bloqué)", "cat $HOME/.config/gws/<github-user>/youtube_token.json", true, "bash"],
  ["ls + cat youtube_token.json (bloqué — chain)", "ls -la $HOME/.config/gws/<github-user>/youtube_token.json 2>&1; cat $HOME/.config/gws/<github-user>/youtube_token.json", true, "bash"],
  // Client secrets
  ["cat client_secret.json (bloqué)", "cat $HOME/.config/gws/kpihx/client_secret.json", true, "bash"],
  ["cat client_secret.json labs (bloqué)", "cat $HOME/.config/gws/<github-user>/client_secret.json", true, "bash"],
  // Multi-path secret access
  ["diff two secret files (bloqué)", "diff $HOME/.config/gws/kpihx/client_secret.json $HOME/.config/gws/<github-user>/client_secret.json", true, "bash"],
  // rg/grep on secret files
  ["rg in application_default_credentials.json (bloqué)", "rg client_id $HOME/.config/gcloud/application_default_credentials.json", true, "bash"],
  ["grep in youtube_token.json (bloqué)", "grep refresh_token $HOME/.config/gws/<github-user>/youtube_token.json", true, "bash"],
  ["cat credentials_manager.py (bloqué — '_' is a separator, not a word char)", "cat /foo/credentials_manager.py", true, "bash"],

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

  // --- proxy pipe: | inside quotes → NOT blocked (false positive fix, 2026-09-02) ---
  [
    "browser-proxy do page-evaluate with JS ternary | in expression (passe — pipe is inside quotes)",
    "browser-proxy do page-evaluate '{\"expression\":\"el ? el.tagName : \\\"not found\\\"\"}'",
    false,
    "bash",
  ],
  [
    "browser-proxy do with | inside JSON payload (passe — pipe is inside single-quoted JSON)",
    "whats-proxy do chat-list '{\"filter\": \"a|b\"}' -a 123",
    false,
    "bash",
  ],
  [
    "browser-proxy do with | inside double-quoted arg (passe — pipe is inside double quotes)",
    "browser-proxy do page-evaluate \"{\\\"expr\\\": \\\"x | y\\\"}\"",
    false,
    "bash",
  ],
  [
    "whats-proxy do pipe outside quotes is STILL blocked",
    "whats-proxy do chat-list '{\"filter\":\"a|b\"}' | jq '.data'",
    true,
    "bash",
  ],
  [
    "browser-proxy do with | inside single-quoted arg AND real pipe outside (blocked — real pipe)",
    "browser-proxy do page-evaluate '{\"expression\":\"a|b\"}' | head -5",
    true,
    "bash",
  ],

  // --- proxy stderr suppression (, 2026-09-01) ---
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

  // --- env var disclosure protection (, 2026-09-04) ---

  // 1. Sensitive env var expansion
  ["echo $API_KEY (bloqué)", "echo $API_KEY", true, "bash"],
  ["echo ${SECRET_TOKEN} (bloqué)", "echo ${SECRET_TOKEN}", true, "bash"],
  ["printf $TOKEN (bloqué)", "printf '%s' $TOKEN", true, "bash"],
  ["echo $MY_SECRET_PASSWORD (bloqué)", "echo $MY_SECRET_PASSWORD", true, "bash"],
  ["echo $DATABASE_AUTH (bloqué)", "echo $DATABASE_AUTH", true, "bash"],
  ["echo $AWS_CREDENTIAL (bloqué)", "echo $AWS_CREDENTIAL", true, "bash"],
  ["echo $ACCESS_TOKEN (bloqué)", "echo $ACCESS_TOKEN", true, "bash"],
  ["echo $PRIVATE_KEY (bloqué)", "echo $PRIVATE_KEY", true, "bash"],
  ["echo $HOME (passe)", "echo $HOME", false, "bash"],
  ["echo $USER (passe)", "echo $USER", false, "bash"],
  ["echo $KEYBOARD_LAYOUT (passe)", "echo $KEYBOARD_LAYOUT", false, "bash"],
  ["echo $TOKENIZER (bloqué — substring 'token' in token)", "echo $TOKENIZER", true, "bash"],
  ["echo $AUTHOR_NAME (bloqué — substring 'auth' in author)", "echo $AUTHOR_NAME", true, "bash"],
  ["echo $PATH (passe)", "echo $PATH", false, "bash"],
  ["echo hello (passe)", "echo hello", false, "bash"],
  ["echo $SHELL (passe)", "echo $SHELL", false, "bash"],

  // 2. Filtered env extraction
  ["env | grep TOKEN (bloqué)", "env | grep TOKEN", true, "bash"],
  ["printenv | grep SECRET (bloqué)", "printenv | grep SECRET", true, "bash"],
  ["set | grep PASSWORD (bloqué)", "set | grep PASSWORD", true, "bash"],
  ["export -p | grep KEY (bloqué)", "export -p | grep KEY", true, "bash"],
  ["compgen -v | grep AUTH (bloqué)", "compgen -v | grep AUTH", true, "bash"],
  ["env | head -5 (bloqué)", "env | head -5", true, "bash"],
  ["env | awk '/TOKEN/' (bloqué)", "env | awk '/TOKEN/ {print}'", true, "bash"],
  ["printenv | sed -n '/KEY/p' (bloqué)", "printenv | sed -n '/KEY/p'", true, "bash"],
  ["env | tail -10 (bloqué)", "env | tail -10", true, "bash"],
  ["env | less (bloqué)", "env | less", true, "bash"],
  ["env | cut -d= -f1 (bloqué)", "env | cut -d= -f1", true, "bash"],
  ["env HOME (passe — no pipe)", "env HOME", false, "bash"],
  ["printenv USER (passe — no pipe)", "printenv USER", false, "bash"],
  ["ls -la (passe)", "ls -la /tmp", false, "bash"],

  // 3. /proc/*/environ reading
  ["cat /proc/self/environ (bloqué)", "cat /proc/self/environ", true, "bash"],
  ["cat /proc/1234/environ (bloqué)", "cat /proc/1234/environ", true, "bash"],
  ["strings /proc/self/environ (bloqué)", "strings /proc/self/environ", true, "bash"],
  ["head /proc/1/environ (bloqué)", "head /proc/1/environ", true, "bash"],
  ["tail /proc/self/environ (bloqué)", "tail /proc/self/environ", true, "bash"],
  ["less /proc/self/environ (bloqué)", "less /proc/self/environ", true, "bash"],
  ["xxd /proc/self/environ (bloqué)", "xxd /proc/self/environ", true, "bash"],
  ["hexdump /proc/42/environ (bloqué)", "hexdump /proc/42/environ", true, "bash"],
  ["od /proc/self/environ (bloqué)", "od /proc/self/environ", true, "bash"],
  ["cat /proc/self/cmdline (passe)", "cat /proc/self/cmdline", false, "bash"],
  ["cat /proc/self/status (passe)", "cat /proc/self/status", false, "bash"],
  ["ls /proc/self/ (passe)", "ls /proc/self/", false, "bash"],

  // 4. Python/Node env dumps
  ["python -c os.environ (bloqué)", "python3 -c \"import os; print(os.environ)\"", true, "bash"],
  ["python -c os.environ['SECRET'] (bloqué)", "python3 -c \"import os; print(os.environ['SECRET'])\"", true, "bash"],
  ["python -c os.environ.get (bloqué)", "python3 -c \"import os; print(os.environ.get('KEY'))\"", true, "bash"],
  ["python -c os.environ.items (bloqué)", "python3 -c \"import os; print(list(os.environ.items()))\"", true, "bash"],
  ["uv run python -c os.environ (bloqué)", "uv run python -c \"import os; print(os.environ)\"", true, "bash"],
  ["node -e process.env (bloqué)", "node -e \"console.log(process.env)\"", true, "bash"],
  ["node -e process.env.SECRET (bloqué)", "node -e \"console.log(process.env.SECRET)\"", true, "bash"],
  ["node -e process.env['TOKEN'] (bloqué)", "node -e \"console.log(process.env['TOKEN'])\"", true, "bash"],
  ["python script.py (passe)", "python3 script.py", false, "bash"],
  ["node script.js (passe)", "node script.js", false, "bash"],
  ["python -c os.getcwd (passe)", "python3 -c \"import os; print(os.getcwd())\"", false, "bash"],
  ["node -e console.log('hi') (passe)", "node -e \"console.log('hi')\"", false, "bash"],

  // 5. History file access
  ["cat ~/.bash_history (bloqué)", "cat ~/.bash_history", true, "bash"],
  ["cat ~/.zsh_history (bloqué)", "cat ~/.zsh_history", true, "bash"],
  ["less ~/.bash_history (bloqué)", "less ~/.bash_history", true, "bash"],
  ["head ~/.zsh_history (bloqué)", "head ~/.zsh_history", true, "bash"],
  ["tail ~/.bash_history (bloqué)", "tail ~/.bash_history", true, "bash"],
  ["grep TOKEN ~/.bash_history (bloqué)", "grep TOKEN ~/.bash_history", true, "bash"],
  ["rg SECRET ~/.zsh_history (bloqué)", "rg SECRET ~/.zsh_history", true, "bash"],
  ["strings ~/.bash_history (bloqué)", "strings ~/.bash_history", true, "bash"],
  ["cat ~/.local/share/fish/fish_history (bloqué)", "cat ~/.local/share/fish/fish_history", true, "bash"],
  ["cat ~/.bashrc (passe)", "cat ~/.bashrc", false, "bash"],
  ["cat ~/.zshrc (passe)", "cat ~/.zshrc", false, "bash"],
  ["cat ~/.config/app/history.json (passe)", "cat ~/.config/app/history.json", false, "bash"],
  ["cat /var/log/syslog (passe)", "cat /var/log/syslog", false, "bash"],

  // --- env disclosure inside tmux send-keys → allowed (payload runs in pane) ---
  [
    "echo $API_KEY inside tmux send-keys (autorisé — payload livré au pane)",
    "tmux send-keys -t ubuntu:0.2 'echo $API_KEY' Enter",
    false,
    "bash",
  ],
  [
    "cat /proc/self/environ inside tmux send-keys (autorisé)",
    "tmux send-keys -t ubuntu:0.2 'cat /proc/self/environ' Enter",
    false,
    "bash",
  ],
  [
    "env | grep TOKEN inside tmux send-keys (autorisé)",
    "tmux send-keys -t ubuntu:0.2 'env | grep TOKEN' Enter",
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
