#!/usr/bin/env bash
# ============================================================
# lib.sh — links/ helpers (thin wrapper over the shared libs/)
# ============================================================
# All the common JSONC load/strip/validate/infra helpers now live in the
# central shared library $HOME/.agents/libs/jsonc/jsonc_lib.sh (single source
# of truth — no duplication). This file sources it so scripts/links/* can use
# the shared configuration and infrastructure-resolution helpers.
#
# WHY JSONC: comments allowed → self-documenting. JSONC is the KπX config
# standard (see kpihx-labs / k-project → Config Standard). .env holds secrets.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../libs/jsonc/jsonc_lib.sh
source "$SCRIPT_DIR/../../libs/jsonc/jsonc_lib.sh"
