"""
config.py — Canonical KpihX configuration skeleton
====================================================
Minimal, dependency-light config. No YAML loader, no ConfigManager
singleton — runtime values are plain constants or a frozen dataclass
declared directly here. Add layering only if the project genuinely
needs it (most don't).

IMPORTANT:
  - Keep this module runtime-focused.
  - Never store package/app metadata here (name, version, contract schema/version).
    Metadata belongs to pyproject.toml (or package.json for JS/TS).

HOW TO USE:
  1. Copy to: src/<your_package>/config.py
  2. Copy .env.example to: src/<your_package>/.env (fill real values for local dev)
  3. Replace ALL_CAPS placeholders below with your project's specifics
  4. Update REQUIRED_SECRETS with your secret names as they appear in Vaultwarden

PLACEHOLDERS TO REPLACE:
  - SECRET_ONE          → first required secret name (e.g., "OPENAI_API_KEY")
  - SECRET_TWO          → second required secret (remove if not needed)
  - DEFAULT_HOST        → sensible default for host (e.g., "localhost")
  - DEFAULT_PORT        → sensible default for port (e.g., 8080)
"""

from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv  # pip: python-dotenv

# ---------------------------------------------------------------------------
# Secrets — .env for local dev, process env / Vaultwarden login shell for prod
# ---------------------------------------------------------------------------
_PKG_DIR = Path(__file__).parent
_DOT_ENV = _PKG_DIR / ".env"
load_dotenv(_DOT_ENV, override=False)  # os.environ always wins over .env

REQUIRED_SECRETS: list[str] = [
    "SECRET_ONE",
    "SECRET_TWO",
]


class SecretsUnavailableError(RuntimeError):
    """Raised when a required secret cannot be resolved from any source."""


def get_secret(name: str, *, required: bool = True) -> str:
    """Resolve a secret from the process environment (populated by .env or the shell)."""
    value = os.environ.get(name)
    if value:
        return value
    if required:
        raise SecretsUnavailableError(
            f"Secret '{name}' is not available. Ensure Vaultwarden is unlocked or set it in {_DOT_ENV}."
        )
    return ""


# ---------------------------------------------------------------------------
# Runtime config — plain frozen dataclass, edit defaults directly
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Config:
    host: str = "DEFAULT_HOST"
    port: int = 8080
    log_level: str = "INFO"
    debug: bool = False


CONFIG = Config()

# Override at runtime only when a real need appears (tests, CLI flags):
#   from config import CONFIG, replace
#   test_cfg = replace(CONFIG, port=9999)
