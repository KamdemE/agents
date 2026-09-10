# Google Workspace CLI — profile wrappers (source from $HOME/.kshrc)
# Canonical path; k-google/scripts/gws-profiles.sh — sourced by .kshrc.

# Default bare `gws` →  personal profile (kpihx-489121). Use gws-labs for homelab project.
gws() {
  gws-primary "$@"
}

gws-labs() {
  GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/<github-user>" \
  GOOGLE_WORKSPACE_PROJECT_ID="<github-user>" \
  command gws "$@"
}

gws-primary() {
  GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/kpihx" \
  GOOGLE_WORKSPACE_PROJECT_ID="kpihx-489121" \
  command gws "$@"
}
