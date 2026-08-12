# Healthcheck Governance & Post-Modification Protocol (MANDATORY)

After ANY modification to Neovim config files (`init.lua`, `plugins.lua`, `lsp.lua`, `keymaps.lua`, `trash.lua`, or any `lua/kpihx/*.lua`):

1. **Run `:checkhealth`** live in tmux (not headless).
2. **Identify the source** of each ❌ or ⚠️:
   - If it comes from `lua/kpihx/` or cites KπX config → fix it.
   - If it comes from a plugin's `health.lua` (`lua/<plugin>/health.lua`) → it's a plugin-side false positive. **Do NOT patch plugins in `lazy/`** — those get wiped on update. Just explain to KπX that it's a known upstream issue with no functional impact.
3. **Notify KπX** with a summary of what was fixed and what plugin-level noise was identified.
4. **Update k-nvim SKILL.md** if config changed.

> **Policy:** KπX only owns `k-nvim/config/`. Plugin healthcheck noise is ignored.
> Never modify files inside `~/.local/share/nvim/lazy/`.

## Agent autonomy (MANDATORY)

When the user asks you to fix nvim errors, you MUST:
1. Reload nvim yourself (send `:qa!` then `nvim` to the tmux pane), never wait for the user.
2. Run `:checkhealth` **live in tmux** — NEVER headless.
3. Scroll through EVERY section using `G` / `gg` / `:N`. Capture all sections.
4. Fix ❌ errors from **KπX config only**. Ignore plugin noise.
5. Report detailed results before asking for further instructions.
6. Do NOT ask the user for permission at each step — execute autonomously.

## Post-modification healthcheck protocol (MANDATORY)

After ANY modification to Neovim config files (`init.lua`, `plugins.lua`, `lsp.lua`, `keymaps.lua`, `trash.lua`, or any `lua/kpihx/*.lua`), the agent MUST:

1. **Run the exact command, no variation allowed:**
   ```
   nvim --headless "+checkhealth" "+w! /tmp/nvim-health.md" "+qa" 2>/dev/null && cat /tmp/nvim-health.md | grep -E "❌|✗|FAIL|ERROR|WARNING|⚠️"
   ```

2. **Extract and present ONLY errors and warnings** — everything that is not ✅:
   - Lines containing `❌`, `✗`, `FAIL`, `ERROR`, `WARNING`, `⚠️`
   - Present them as-is, no truncation, no grep -v filtering, no head/tail

3. **For EACH issue, provide a COMPLETE analysis:**
   - **Exact error message** — verbatim from checkhealth
   - **Root cause** — trace the full dependency chain: what plugin requires what, which package provides it, why it is missing on this specific system.
   - **Why it happens NOW** — config change? removed dependency? version mismatch? missing system package? Never say "pre-existing" without explaining why it was pre-existing and what keeps it unfixed.
   - **Impact assessment** — what exactly breaks or degrades. Which nvim features stop working? Be specific.
   - **Fix proposal** — at least one concrete, executable fix with exact commands. If multiple fixes exist, list them with pros/cons. If there is a reason not to apply the fix (e.g., "would touch system python"), explain that reason and propose alternatives.
   - **Why the fix works** — the mechanism: what does the fix command actually do, where does it install what, why does that resolve the issue.

4. **Never hide, skip, truncate, or beautify any error or warning.** Every single one must appear in the report with its full analysis.

5. **Update SKILL.md** with the changelog before running the check — the check is the final verification.

## Known false positives (plugin-level, ignore)

These `:checkhealth` items come from plugin health files, not KπX config. They have **zero impact on daily use**:
- `nvim-treesitter: installdir not in runtimepath` → symlink normalization issue upstream, not fixed yet
- `which-key` keymap overlaps (`<gc>`/`<gcc>`, `<ys>`/`<yss>`) → inherent to vim modal editing
- `tmux focus-events` → terminal limitation, fix in `.tmux.conf` needs `tmux source-file`
- Any `report_*` deprecation warnings in plugins → plugin needs update, no action needed
