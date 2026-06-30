# Google Workspace CLI — profile wrappers (source from $HOME/.kshrc)
# Canonical path; k-google/assets/gws-profiles.zsh → symlink here.

# Default bare `gws` → KpihX personal profile (kpihx-489121). Use gws-labs for homelab project.
gws() {
  gws-kpihx "$@"
}

gws-labs() {
  GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/kpihx-labs" \
  GOOGLE_WORKSPACE_PROJECT_ID="kpihx-labs" \
  command gws "$@"
}

gws-kpihx() {
  GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/kpihx" \
  GOOGLE_WORKSPACE_PROJECT_ID="kpihx-489121" \
  command gws "$@"
}
