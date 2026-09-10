# First tmux after reboot (post-login) — mandatory workflow

> **Do not trust an immediate `tmux ls` right after login.** `@continuum-boot` is **off** and `tmux.service` is **disabled** — there is no login-time server. **`no server running`** until you run step 2 (`tmux` from a real terminal).

**After every reboot, in order:**

1. **Check server (optional)** — `tmux ls`
   - `no server running` → normal; go to step 2.
   - Only `default` or wrong layout → step 4 after attach.

2. **Start tmux once from a real terminal** (Cursor, GNOME Terminal, etc.) — not via the user `tmux.service` unit:
   ```bash
   tmux
   ```
   Auto-restore (`@continuum-restore on`) runs **only on this new server start** (first client loads plugins → `continuum_restore.sh` after ~1s).

3. **Verify sessions** — `tmux ls` inside or outside tmux. Expect your named sessions (`live`, `pve`, …) if the last save was good.

4. **If empty or only a bare `default`** — manual restore:
   ```bash
   # inside tmux: Ctrl-a Ctrl-r
   ```
   If `last` points at a tiny/empty save (reboot loop), pick an older file:
   ```bash
   ls -lt $HOME/.tmux/resurrect/tmux_resurrect_*.txt | head
   wc -c $HOME/.tmux/resurrect/$(readlink -f $HOME/.tmux/resurrect/last)
   ```
   See tmux-resurrect docs for restoring a specific timestamped file.

5. **Before the next reboot** — inside tmux: `Ctrl-a Ctrl-s`, then confirm `last` is non-trivial:
   ```bash
   wc -c $HOME/.tmux/resurrect/$(readlink -f $HOME/.tmux/resurrect/last)
   ```
   Do **not** rely on shutdown `ExecStop` save — journals show `save.sh: no server running` when the unit stops.

**Diagnose boot/shutdown (optional):**

```bash
journalctl --user -u tmux.service -b 0 --no-pager | tail -30
```

**Config (2026-05-25):** `@continuum-boot off` + `systemctl --user disable tmux.service`. Restore happens when  runs step 2. Forensics: `references/insights.md`.
