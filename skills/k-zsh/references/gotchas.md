# k-zsh Known Gotchas (full write-ups)

Moved here from `SKILL.md` per the 300-line skill body limit (`rules/skill-governance.md`). SKILL.md keeps short pointers to this file — full detail lives here, verbatim, never trimmed.

## ⚠️ Known Gotcha — `source ~/.kshrc` is a NO-OP for already-loaded shells (2026-08-16)

`kshrc.base` has **two independent idempotency guards**: `__KSHRC_LOADED`
(universal section) and `__KSHRC_INTERACTIVE_LOADED` (interactive section —
aliases, prompt, `precmd`/`PROMPT_COMMAND`, tmux auto-attach, etc.). Once a
guard variable is set to `1` in a given shell process, sourcing `.kshrc`
again in **that same shell** will **silently skip** the whole guarded block —
no error, no warning, the `source` command just "succeeds" visually (you get
your normal prompt back) while changing nothing.

**Concrete incident that exposed this:** the `tmux-notify` stateful reflex
(see `k-tmux/SKILL.md` → `## Stateful Integration`) depends on a `precmd`
hook added to the INTERACTIVE section of `kshrc.base`. Two long-lived tmux
panes (`ubuntu:1.0` and `ubuntu:3.0`) had opened their shell **before** that
hook was added. KπX manually ran `source ~/.kshrc` in one of them expecting
it to pick up the new hook — it did NOT: the pane returned to its prompt
several times afterward (confirmed via full scrollback read), yet
`/tmp/tmux-pane-done.log` never received a single entry for that pane,
because the `__KSHRC_INTERACTIVE_LOADED` guard (set hours earlier, before the
hook existed) blocked the whole re-definition. Full incident: `k-tmux`
`references/insights.md` and `k-context` session log, same date.

**The correct fix — clear BOTH guards before re-sourcing:**
```bash
unset __KSHRC_LOADED __KSHRC_INTERACTIVE_LOADED; source ~/.kshrc
```
Or, simpler and always safe: start a fresh shell in that pane (`exec zsh`, or
close/reopen the pane) — a new shell process never carries a stale guard.

**Rule of thumb:** `source ~/.kshrc` alone is only guaranteed to pick up
changes in a shell that has **never loaded it before in this process**. To
refresh an EXISTING interactive shell after modifying the interactive section
of `kshrc.base` (or any per-infra `kshrc` copy), always `unset` both guards
first, or restart the shell.

---

## ⚠️ Known Gotcha — opencode web's embedded terminal hijacked into the shared tmux session (2026-08-16)

The **Auto-tmux (interactive only)** block at the end of the interactive
section (`kshrc.base` and all 7 infra `kshrc` copies) attaches ANY new
interactive shell with a TTY and no `$TMUX` set into the infra's persistent
tmux session. This is correct for real terminals (SSH, local terminal apps)
but was WRONG for one specific case: **opencode web's embedded terminal
panel**.

**Root cause (confirmed from opencode's own source,
`packages/opencode/src/pty/index.ts`):** opencode web's terminal feature
spawns a genuine PTY (`bun-pty`) for its terminal panel, meant to be an
**isolated session** streamed 1:1 to the browser via WebSocket
(`Pty.Service`). opencode sets `OPENCODE_TERMINAL=1` **unconditionally** on
every such PTY's environment:
```ts
const env = {
  ...process.env, ...input.env, ...shellEnv.env,
  TERM: "xterm-256color",
  OPENCODE_TERMINAL: "1",
}
```
Because this PTY has a real TTY and no `$TMUX`, the Auto-tmux guard used to
fire on it too — hijacking the isolated PTY into the SAME shared desktop
tmux session used by everything else. Concrete symptoms observed: (1)
multiple simultaneous tmux clients on one session causing resize
glitches/flicker in both the web panel and the desktop tmux, (2) input
cross-contamination — keystrokes typed in the web terminal panel forwarded
into the shared session, landing on whatever pane happens to be active
elsewhere (a live agent's pane, an editor, anything), (3) since the
Auto-tmux block calls `tmux attach` as a plain child (never `exec`'d), if the
web tab closes and the PTY client detaches, the underlying zsh process falls
through past the guard and keeps running idle — plausibly compounding a
known upstream leak (`anomalyco/opencode#19225`: "opencode web leaks
hundreds of idle /bin/zsh PTYs... until system-wide terminal creation
fails").

**The fix — skip Auto-tmux when `$OPENCODE_TERMINAL` is set:**
```bash
if [ -z "$TMUX" ] && [ -z "$OPENCODE_TERMINAL" ] && command -v tmux >/dev/null 2>&1 && [ -t 0 ]; then
  ...
fi
```
Applied to `kshrc.base` and all 7 infra copies (`k-phones`, `k-blglaptop139`,
`k-deep-pc6`, `k-dockerhost`, `k-pve`, `k-pve-debian`, `k-ubuntu`). opencode
web's terminal now behaves as its own standalone shell (as designed); every
OTHER interactive shell (real SSH/local terminals) keeps the current
auto-attach behavior untouched. Full incident + tmux `remain-on-exit`
runtime-drift companion finding: `k-tmux/references/insights.md`, same date.
