# Daemon-Based CLI — Architecture Patterns

Reusable recipe for background-daemon CLI tools (verified in `whats-proxy` v0.2.0, `~/KpihX-Labs/whats_proxy/`). Any future "CLI that owns a long-lived session/connection" should follow this. The critical patterns below were each root-caused with empirical proof — do not "simplify" them back into broken forms.

## 1. Single-owner daemon lock: O_CREAT|O_EXCL, NEVER the socket

**The problem:** two `do` invocations can race and both spawn a daemon. The loser must exit; exactly one owns the session.

**The trap (empirically proven broken):** Unix sockets CANNOT arbitrate ownership. A second `server.listen(path)` on the same bound path **silently succeeds** — the new socket replaces the file, the old socket keeps listening on a deleted inode (orphaned but alive, unreachable, leaks forever). Socket-probe guards (probe-then-unlink, bind-error handling) all have TOCTOU windows. Verified with a live 2-process bind experiment.

**The fix (kernel-atomic):** an exclusive lockfile created with `openSync(lockPath, "wx")` (O_CREAT|O_EXCL). Exactly one process wins; everyone else gets EEXIST and exits(0). Stale locks (crashed owner) are recovered by probing the socket — if nothing answers, steal the lock and retry once.

```ts
async function acquireLock(lockFile: string, sockFile: string): Promise<boolean> {
  const tryLock = (): boolean => {
    try { const fd = openSync(lockFile, "wx"); closeSync(fd); writeFileSync(lockFile, String(process.pid)); return true; }
    catch { return false; }
  };
  if (tryLock()) return true;
  const { connect } = await import("node:net");
  const alive = await new Promise<boolean>((res) => {
    const p = connect(sockFile); p.on("connect", () => { p.end(); res(true); }); p.on("error", () => res(false));
  });
  if (alive) return false;
  try { unlinkSync(lockFile); return tryLock(); } catch { return false; }
}
```

**Ordering rule:** acquire lock → bind socket → THEN do slow async init (network connect, etc.). If you bind after slow init, the lock window is huge and stale-lock recovery misbehaves (every contender probes during the slow window, sees nothing, cascade-steals).

## 2. Readiness: bound socket ≠ ready; dispatch must wait for init

If the socket binds before the session object exists, an early dispatch races init. Either (a) build the context lazily and have dispatch poll for readiness, or (b) gate dispatch on an "initialized" flag. A client polling `ping` for readiness only proves the socket file exists — not that the daemon can serve. Prefer the daemon-side readiness wait (bounded, e.g. 150 × 200 ms) so clients never see transient "not ready" errors.

## 3. Idle-exit: exclude the liveness probe from activity

If the daemon supports idle-exit (`max_idle_minutes`), the `ping`/health-check RPC must NOT count as activity — clients poll it continuously, so counting it keeps the daemon alive forever (defeats idle-exit entirely). Track activity in the RPC handler with an explicit `if (method !== "ping") lastActivity = now`.

## 4. Test isolation: scope process discovery to the test's own state dir

A stress/race test that kills "all daemons" (`pkill -f`) can murder a real user daemon with a live session. Scope discovery to the test's own state dir: candidates via `pgrep -f "index.ts daemon"`, then confirm ownership per-pid via `ps eww -o args <pid>` containing the test's `WHATS_PROXY_STATE_DIR=<WORK>`. Never kill what you didn't spawn. (Note: `ps eww -o pid,args` WITHOUT a pid only shows the caller's own processes — always pass pids explicitly or use `ps -e`.)

## 5. Envelope discipline for CLI output

Stdout = pure machine-readable output (JSON/table) only. Notes ("Written to X", autosave paths), warnings, and errors go to stderr via the logger. This deviates from tg-proxy (which prints notes to stdout via console) deliberately — stdout purity enables piping (`whats-proxy do X | jq`).

## 6. Argument parsing: missing option VALUES are errors

`-o`/`-f` without a following value must error (exit 2) with a clear message — silent ignore is a UX bug (the user asked for a file that never appears). An invalid *format* value can fall back to JSON (matches the reference CLI's behavior) — but a missing value is always an error.

## Verification recipe

- `make stress`: N (32-48) simultaneous daemon spawns → exactly 1 survivor, 0 orphans after shutdown. Run 5-10× — the race is intermittent at high concurrency.
- Hermetic smoke: after the CLI edge-path tests, a sweep must confirm zero daemons survive (shutdown RPC → pid-file SIGTERM fallback → assert ping false).
- Idle-exit test: set `max_idle_minutes` to a fractional value (e.g. 0.05 = 3s), confirm the daemon self-exits, and that `ping` during the window does NOT reset the clock.
