# rm Discipline (GRAVÉ)

**Status:** Kernel sovereignty — non-negotiable.  
**Applies to:** ALL agents, ALL profiles, ALL contexts (Colab, Explore, Auto, Lite, Plan, sub-agents).  
**Enforcement:** `opencode.jsonc` (global bash + Auto agent), `AGENTS.md`, `k-opencode/SKILL.md`.

---

## The Rule

🔴 **NEVER USE `/usr/bin/rm` OR `/bin/rm` — EVER.**

- `rm` in PATH points to `~/.local/bin/rm` which is the **trash-safe wrapper** (`k-clis/assets/rm`). It moves files to trash instead of permanent deletion.
- `/usr/bin/rm` and `/bin/rm` are the **real GNU rm** that permanently destroys data. Using either is a **kernel sovereignty violation**.

## Why

The `rm` trash wrapper (`~/.local/bin/rm`) moves deleted files to the trash directory. This provides:
- **Recoverability:** Files can be restored if accidentally deleted
- **Safety net:** `trash-rm` / `rm rm` for explicit permanent deletion
- **Audit trail:** Trash contents can be inspected before emptying

Using `/usr/bin/rm` or `/bin/rm` bypasses this safety layer entirely — data is gone forever.

## Allowed vs Denied

| Command | Status | Why |
|---------|--------|-----|
| `rm <file>` | ✅ **Allowed** (ask for non-Auto, allow for Auto) | Goes through the trash wrapper |
| `rm *` | ✅ **Allowed** (ask) | Goes through the trash wrapper |
| `rm rm <pattern>` | ✅ **Allowed** | trash-cli's trash-rm for permanent deletion |
| `rm empty` | ✅ **Allowed** | Empty the trash |
| `/usr/bin/rm` | 🔴 **DENIED for ALL agents** | Bypasses trash — permanent destruction |
| `/bin/rm` | 🔴 **DENIED for ALL agents** | Same as above |
| `rm -rf` | 🔴 **DENIED for Auto** (blocked by `*rm*` wildcard) | Danger flag — must use trash wrapper |

## Implementation

### Global (non-Auto agents)
Specific paths are explicitly denied in `opencode.jsonc` → `"permission"` → `"bash"`:
```jsonc
"/usr/bin/rm": "deny",
"/usr/bin/rm *": "deny",
"/bin/rm": "deny",
"/bin/rm *": "deny",
```

### Auto agent
Auto uses a blanket `*rm*` deny + selective `rm` allow because its `"*": "allow"` would override specific path patterns:
```jsonc
"bash": {
  "*rm*": "deny",
  "rm": "allow",
  "rm *": "allow"
}
```

## How to permanently delete

If you genuinely need permanent deletion (e.g., sensitive files):
1. `rm <file>` — moves to trash
2. `rm rm <pattern>` — permanently removes from trash (trash-cli's `trash-rm`)
3. Or: `rm empty` — empties entire trash

## Violations

Any agent caught using `/usr/bin/rm` or `/bin/rm` is in **violation of kernel sovereignty**. Not for scripts, not for automation, not for cleanup. If a script calls these paths, refactor it to use the `rm` wrapper.
