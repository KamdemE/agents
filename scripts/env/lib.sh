#!/usr/bin/env bash
# ============================================================
# lib.sh — env/ helpers (thin wrapper over the shared libs/)
# ============================================================
# All the common .env load/validate helpers now live in the central shared
# library $HOME/.agents/libs/env/env_lib.sh (single source of truth — no
# duplication). This file sources it so scripts/env/* stay thin and focused
# on their own logic (governance check / debug viewer).
#
# WHY .env: secrets live ONLY in ~/.agents/.env (gitignored); .env.example is
# the committed template. env_lib.* NEVER prints or reads VALUES (zero-touch).
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../libs/env/env_lib.sh
source "$SCRIPT_DIR/../../libs/env/env_lib.sh"
