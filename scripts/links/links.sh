#!/usr/bin/env bash
# ============================================================
# link-defs.sh — single source of truth for .agents-owned symlinks
# ============================================================
# Shared link definitions used by BOTH:
#   - scripts/link-create.sh   (creates/recreates the symlinks)
#   - scripts/check-links.sh   (verifies they are not broken/reversed)
#
# 🔴 RULE (see rules/ + AGENTS.md + k-context): any symlink to a skill
#    or tied to the agents kernel must ALWAYS be centralized via
#    $HOME/.agents — and MUST be registered HERE so that:
#      `make link`  (creates)  and  `make check-links` (verifies)
#    both cover it automatically.
#
# Format: one entry per line in LINKS:
#     "<link_path>|<target_path>"
#   link_path   = the OS-location symlink (e.g. $HOME/.config/...)
#   target_path = the canonical .agents source (e.g. $HOME/.agents/skills/...)
#
# ADD NEW LINKS HERE (top section, grouped by owning skill) — that is
# the ONLY place to register a link. Both create & check read this file.
#
# Source:  .agents/scripts/link-defs.sh
# Caller:  link-create.sh / check-links.sh (via `source`)
# ============================================================

# --- k-opencode --------------------------------------------------------------
LINKS=(
  "$HOME/.config/opencode/AGENTS.md|$HOME/.agents/AGENTS.md"
  "$HOME/.config/opencode/agents|$HOME/.agents/agents"
  "$HOME/.config/opencode/opencode.jsonc|$HOME/.agents/skills/k-opencode/assets/opencode.jsonc"
  "$HOME/.config/opencode/tui.json|$HOME/.agents/skills/k-opencode/assets/tui.json"
  "$HOME/.config/opencode/commands/context.md|$HOME/.agents/skills/k-opencode/assets/plugins/context/context.md"
  "$HOME/.config/opencode/plugins|$HOME/.agents/skills/k-opencode/scripts/plugins/context"

  # --- k-zsh -------------------------------------------------------------------
  "$HOME/.zshrc|$HOME/.agents/skills/k-zsh/assets/zshrc"
  "$HOME/.zshenv|$HOME/.agents/skills/k-zsh/assets/zshenv"
  "$HOME/.zprofile|$HOME/.agents/skills/k-zsh/assets/zprofile"
  "$HOME/.bashrc|$HOME/.agents/skills/k-zsh/assets/bashrc"
  "$HOME/.profile|$HOME/.agents/skills/k-zsh/assets/profile"

  # --- k-ubuntu ---------------------------------------------------------------
  "$HOME/.kshrc|$HOME/.agents/skills/k-ubuntu/assets/kshrc"
  "$HOME/.config/mimeapps.list|$HOME/.agents/skills/k-ubuntu/assets/mimeapps.list"

  # --- k-tmux ------------------------------------------------------------------
  "$HOME/.tmux.conf|$HOME/.agents/skills/k-tmux/assets/tmux.conf"

  # --- k-git -------------------------------------------------------------------
  "$HOME/.gitconfig|$HOME/.agents/skills/k-git/assets/gitconfig"

  # --- k-25 --------------------------------------------------------------------
  "$HOME/.local/bin/adb-s25|$HOME/.agents/skills/k-25/scripts/adb-s25"
  "$HOME/.local/bin/adb-s25-pair|$HOME/.agents/skills/k-25/scripts/adb-s25-pair"

  # --- k-ai --------------------------------------------------------------------
  "$HOME/.local/bin/k-piper|$HOME/.agents/skills/k-ai/scripts/k-piper.sh"
  "$HOME/.local/bin/k-whisper|$HOME/.agents/skills/k-ai/scripts/k-whisper.sh"
  "$HOME/.local/bin/k-translate|$HOME/.agents/skills/k-ai/scripts/k-translate.sh"

  # --- k-hermes ----------------------------------------------------------------
  "$HOME/.local/bin/hermes|$HOME/.agents/skills/k-hermes/assets/hermes.sh"

  # --- k-qmd -------------------------------------------------------------------
  "$HOME/.local/bin/qmdr|$HOME/.agents/skills/k-qmd/scripts/qmdr"

  # --- k-clis ------------------------------------------------------------------
  "$HOME/.local/bin/rm|$HOME/.agents/skills/k-clis/assets/rm"

  # --- k-browser ---------------------------------------------------------------
  "$HOME/.local/bin/msedge-cdp|$HOME/.agents/skills/k-browser/assets/msedge-cdp.sh"

  # --- k-dxo -------------------------------------------------------------------
  "$HOME/.local/bin/ollama6|$HOME/.agents/skills/k-dxo/scripts/ollama6"
  "$HOME/.local/bin/tmux6|$HOME/.agents/skills/k-dxo/assets/tmux6"

  # --- k-openclaw --------------------------------------------------------------
  "$HOME/.local/bin/openclaw-opencode|$HOME/.agents/skills/k-openclaw/assets/openclaw-opencode"

  # --- k-code (Code) -----------------------------------------------------------
  "$HOME/.config/Code/User/settings.json|$HOME/.agents/skills/k-code/assets/settings.json"
  "$HOME/.config/Code/User/keybindings.json|$HOME/.agents/skills/k-code/assets/keybindings.json"
  "$HOME/.config/Code/User/mcp.json|$HOME/.agents/skills/k-code/assets/mcp.json"
  "$HOME/.config/Code/User/chatLanguageModels.json|$HOME/.agents/skills/k-code/assets/chatLanguageModels.json"
  "$HOME/.config/Code/User/snippets|$HOME/.agents/skills/k-code/assets/snippets"

  # --- k-code (Cursor) ---------------------------------------------------------
  "$HOME/.config/Cursor/User/settings.json|$HOME/.agents/skills/k-code/assets/settings.json"
  "$HOME/.config/Cursor/User/keybindings.json|$HOME/.agents/skills/k-code/assets/keybindings.json"
  "$HOME/.config/Cursor/User/mcp.json|$HOME/.agents/skills/k-code/assets/mcp.json"
  "$HOME/.config/Cursor/User/chatLanguageModels.json|$HOME/.agents/skills/k-code/assets/chatLanguageModels.json"
  "$HOME/.config/Cursor/User/snippets|$HOME/.agents/skills/k-code/assets/snippets"

  # --- k-google ----------------------------------------------------------------
  "$HOME/.config/gws/gws-profiles.zsh|$HOME/.agents/skills/k-google/assets/gws-profiles.zsh"

  # --- k-nvim ------------------------------------------------------------------
  "$HOME/.config/nvim/init.lua|$HOME/.agents/skills/k-nvim/config/init.lua"
  "$HOME/.config/nvim/lua/kpihx|$HOME/.agents/skills/k-nvim/config/lua/kpihx"
  "$HOME/.config/nvim/lazy-lock.json|$HOME/.agents/skills/k-nvim/config/lazy-lock.json"

  # --- openclaw (workspace identity) -------------------------------------------
  # SOUL.md → .agents/AGENTS.md (kernel identity); USER.md → kpihx/SKILL.md (operator profile)
  "$HOME/.openclaw/workspace/SOUL.md|$HOME/.agents/AGENTS.md"
  "$HOME/.openclaw/workspace/USER.md|$HOME/.agents/skills/kpihx/SKILL.md"
  "$HOME/.openclaw/workspace/AGENTS.md|$HOME/.agents/AGENTS.md"
  "$HOME/.openclaw/workspace/HEARTBEAT.md|$HOME/.agents/openclaw/HEARTBEAT.md"
  "$HOME/.openclaw/workspace/IDENTITY.md|$HOME/.agents/openclaw/IDENTITY.md"

  # --- hermes (home + memories identity) ---------------------------------------
  "$HOME/.hermes/SOUL.md|$HOME/.agents/AGENTS.md"
  "$HOME/.hermes/memories/USER.md|$HOME/.agents/skills/kpihx/SKILL.md"
  "$HOME/her/SOUL.md|$HOME/.agents/AGENTS.md"
  "$HOME/hermes/SOUL.md|$HOME/.agents/AGENTS.md"

  # --- .agents canonical copies (openclaw / hermes) ----------------------------
  "$HOME/.agents/openclaw/SOUL.md|$HOME/.agents/AGENTS.md"
  "$HOME/.agents/hermes/SOUL.md|$HOME/.agents/AGENTS.md"

  # --- systemd user units (k-hermes / k-dxo / k-openclaw / k-opencode / k-rclone / k-ubuntu) ---
  # (also verified by check_systemd.sh; registered here for completeness)
  "$HOME/.config/systemd/user/hermes-gateway.service|$HOME/.agents/skills/k-hermes/assets/hermes-gateway.service"
  "$HOME/.config/systemd/user/ollama6-tunnel.service|$HOME/.agents/skills/k-dxo/assets/ollama6-tunnel.service"
  "$HOME/.config/systemd/user/openclaw-gateway.service|$HOME/.agents/skills/k-openclaw/assets/openclaw-gateway.service"
  "$HOME/.config/systemd/user/opencode-lens.service|$HOME/.agents/skills/k-opencode/assets/opencode-lens.service"
  "$HOME/.config/systemd/user/opencode-web.service|$HOME/.agents/skills/k-opencode/assets/opencode-web.service"
  "$HOME/.config/systemd/user/rclone-deep-pc6.service|$HOME/.agents/skills/k-dxo/assets/rclone-deep-pc6.service"
  "$HOME/.config/systemd/user/rclone-gdrive.service|$HOME/.agents/skills/k-rclone/assets/rclone-gdrive.service"
  "$HOME/.config/systemd/user/rclone-gdrive-x.service|$HOME/.agents/skills/k-rclone/assets/rclone-gdrive-x.service"
  "$HOME/.config/systemd/user/tg-bot.service|$HOME/.agents/skills/k-ubuntu/assets/tg-bot.service"
)
