"""
config.py — Canonical KpihX configuration skeleton
====================================================
Template for any Python project that needs:
  - YAML-based non-sensitive settings
  - .env-based secrets (local dev override)
  - Login-shell secret resolution (production, via bw-env)
  - Cached singleton + runtime override support

HOW TO USE:
  1. Copy to: src/<your_package>/config.py
  2. Copy config.yaml.example to: src/<your_package>/config.yaml
  3. Copy .env.example to: src/<your_package>/.env (fill real values for local dev)
  4. Replace ALL_CAPS placeholders below with your project's specifics
  5. Update REQUIRED_SECRETS with your secret names as they appear in bw-env

PLACEHOLDERS TO REPLACE:
  - YOUR_PACKAGE        → your package name (e.g., "my_mcp")
  - SECRET_ONE          → first required secret name (e.g., "OPENAI_API_KEY")
  - SECRET_TWO          → second required secret (remove if not needed)
  - DEFAULT_HOST        → sensible default for host (e.g., "localhost")
  - DEFAULT_PORT        → sensible default for port (e.g., 8080)
"""

from __future__ import annotations

import copy
import logging
import os
import subprocess
from functools import lru_cache
from pathlib import Path
from typing import Any

from dotenv import load_dotenv  # pip: python-dotenv

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
_PKG_DIR = Path(__file__).parent
_CONFIG_YAML = _PKG_DIR / "config.yaml"
_DOT_ENV = _PKG_DIR / ".env"

# ---------------------------------------------------------------------------
# Required secrets — names must match bw-env / GLOBAL_ENV_VARS vault entries
# ---------------------------------------------------------------------------
REQUIRED_SECRETS: list[str] = [
    "SECRET_ONE",
    "SECRET_TWO",
]

# ---------------------------------------------------------------------------
# Exceptions
# ---------------------------------------------------------------------------


class SecretsUnavailableError(RuntimeError):
    """Raised when a required secret cannot be resolved from any source."""


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------


def _load_yaml(path: Path) -> dict[str, Any]:
    """Load a YAML file; return empty dict if absent."""
    try:
        import yaml  # pip: pyyaml
    except ImportError as exc:
        raise ImportError("pyyaml is required — add it to your project deps") from exc

    if not path.exists():
        logger.debug("Config file not found, using defaults: %s", path)
        return {}
    with path.open() as f:
        data = yaml.safe_load(f) or {}
    return data


def _deep_merge(base: dict[str, Any], override: dict[str, Any]) -> dict[str, Any]:
    """
    Recursively merge `override` into a deep copy of `base`.
    Nested dicts are merged; all other types are replaced.
    """
    result = copy.deepcopy(base)
    for key, value in override.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = _deep_merge(result[key], value)
        else:
            result[key] = copy.deepcopy(value)
    return result


def _resolve_env(name: str) -> str | None:
    """
    Two-tier secret resolution:
      1. os.environ (already set — terminal session, explicit export, or .env loaded)
      2. zsh -l -c login shell (bw-env secrets injected via ~/.kshrc)

    Returns None if the secret is absent in both tiers.
    """
    # Tier 1: current process env (covers: terminal session, .env load, explicit export)
    value = os.environ.get(name)
    if value:
        return value

    # Tier 2: login shell — bw-env injects secrets at login time via ~/.kshrc
    try:
        result = subprocess.run(
            ["zsh", "-l", "-c", f'printf "%s" "${{{name}}}"'],
            capture_output=True,
            text=True,
            timeout=10,
        )
        value = result.stdout.strip()
        if value:
            logger.debug("Secret '%s' resolved via login shell.", name)
            return value
    except (FileNotFoundError, subprocess.TimeoutExpired) as exc:
        logger.warning("Login shell resolution failed for '%s': %s", name, exc)

    return None


def _write_to_dotenv(key: str, value: str) -> None:
    """
    Persist a secret to the local .env file (local dev helper).
    Creates .env if absent. Updates existing key if present.
    """
    lines: list[str] = []
    if _DOT_ENV.exists():
        lines = _DOT_ENV.read_text().splitlines(keepends=True)

    found = False
    for i, line in enumerate(lines):
        if line.startswith(f"{key}="):
            lines[i] = f"{key}={value}\n"
            found = True
            break
    if not found:
        lines.append(f"{key}={value}\n")

    _DOT_ENV.write_text("".join(lines))
    logger.debug("Persisted '%s' to %s", key, _DOT_ENV)


# ---------------------------------------------------------------------------
# Config class
# ---------------------------------------------------------------------------


class Config:
    """
    Layered configuration singleton.

    Load order (later layers override earlier ones):
      1. Hardcoded defaults (in this class)
      2. config.yaml (non-sensitive settings)
      3. .env file    (local dev secret overrides — load_dotenv)
      4. os.environ   (explicit exports always win)

    Secrets are resolved lazily on first access via `get_secret()`.
    Use `update_config(**overrides)` for runtime patching (e.g., in tests).
    """

    # ------------------------------------------------------------------
    # Hardcoded defaults — override in config.yaml
    # ------------------------------------------------------------------
    _defaults: dict[str, Any] = {
        "server": {
            "host": "DEFAULT_HOST",
            "port": "DEFAULT_PORT",
        },
        "log": {
            "level": "INFO",
        },
    }

    def __init__(self, _data: dict[str, Any] | None = None) -> None:
        # Load .env first (override=False — os.environ wins over .env)
        load_dotenv(_DOT_ENV, override=False)

        # Merge: defaults → yaml → runtime overrides
        yaml_data = _load_yaml(_CONFIG_YAML)
        merged = _deep_merge(self._defaults, yaml_data)
        if _data:
            merged = _deep_merge(merged, _data)

        self._data = merged

    # ------------------------------------------------------------------
    # Generic accessors
    # ------------------------------------------------------------------

    def get(self, dotted_path: str, default: Any = None) -> Any:
        """
        Access nested config by dotted path.

        Example:
            cfg.get("server.host")       → "localhost"
            cfg.get("server.port", 9000) → 8080 (from yaml) or 9000 (if missing)
        """
        keys = dotted_path.split(".")
        node: Any = self._data
        for key in keys:
            if not isinstance(node, dict):
                return default
            node = node.get(key, default)
            if node is default:
                return default
        return node

    def to_dict(self) -> dict[str, Any]:
        """Return a deep copy of the merged config dict."""
        return copy.deepcopy(self._data)

    # ------------------------------------------------------------------
    # Typed property shortcuts — add one per top-level config group
    # ------------------------------------------------------------------

    @property
    def host(self) -> str:
        return str(self.get("server.host", "DEFAULT_HOST"))

    @property
    def port(self) -> int:
        return int(self.get("server.port", "DEFAULT_PORT"))

    @property
    def log_level(self) -> str:
        return str(self.get("log.level", "INFO"))

    # ------------------------------------------------------------------
    # Secret accessors — lazy resolution, cached per secret name
    # ------------------------------------------------------------------

    def get_secret(self, name: str, *, required: bool = True) -> str:
        """
        Resolve a secret by name via the two-tier strategy:
          os.environ → zsh -l -c login shell

        Args:
            name:     Secret name (e.g., "SECRET_ONE").
            required: If True, raise SecretsUnavailableError when absent.

        Returns:
            The secret value as a string.

        Raises:
            SecretsUnavailableError: If required=True and the secret is absent.
        """
        value = _resolve_env(name)
        if value:
            return value
        if required:
            raise SecretsUnavailableError(
                f"Secret '{name}' is not available. "
                f"Ensure bw-env is unlocked or set it in {_DOT_ENV}."
            )
        return ""

    # Convenience properties per required secret
    @property
    def secret_one(self) -> str:
        return self.get_secret("SECRET_ONE")

    # Add more as needed:
    # @property
    # def secret_two(self) -> str:
    #     return self.get_secret("SECRET_TWO")


# ---------------------------------------------------------------------------
# Cached singleton
# ---------------------------------------------------------------------------


@lru_cache(maxsize=1)
def load_config(**overrides: Any) -> Config:
    """
    Return the cached Config singleton.

    On first call: reads config.yaml + .env, merges layers.
    Subsequent calls: return the same instance (lru_cache).

    Use `update_config(**overrides)` to patch and reload.
    """
    return Config(_data=dict(overrides) if overrides else None)


def update_config(**overrides: Any) -> Config:
    """
    Clear the cache and reload config with runtime overrides.

    Typical use-cases:
      - Tests: patch specific values without touching files
      - CLI: override host/port from flags
      - Hot-reload: re-read config.yaml after file change

    Example:
        cfg = update_config(**{"server": {"port": 9999}})
        assert cfg.port == 9999
    """
    load_config.cache_clear()
    return load_config(**overrides)


# ---------------------------------------------------------------------------
# Module-level convenience — import these directly in other modules
# ---------------------------------------------------------------------------

def get_config() -> Config:
    """Shorthand: from config import get_config; cfg = get_config()"""
    return load_config()
