"""
Core: Device Detector

Detects the current machine via Tailscale (primary) or hostname (fallback),
then looks up the corresponding k-<infra> skill from `assets/infras.yml`.

Usage:
    hostname, skill_name, device_os = detect_device()
    # (hostname, skill_name) = (None, None) if no match found.
"""
from __future__ import annotations

import json
import os
import socket
import subprocess
from typing import Any

# ---------------------------------------------------------------------------
# constants
# ---------------------------------------------------------------------------

HOME = os.environ["HOME"]
INFRAS_MAP_PATH = os.path.join(HOME, ".agents", "assets", "infras.json")


# ---------------------------------------------------------------------------
# internal helpers
# ---------------------------------------------------------------------------


def _load_infra_map() -> dict[str, str]:
    """Load infras.json → {normalised_hostname: skill_name}."""
    try:
        with open(INFRAS_MAP_PATH) as f:
            raw: dict[str, Any] = json.load(f)
        infras: dict[str, Any] = raw.get("infras", {})
        return {k.strip().lower(): v for k, v in infras.items()}
    except Exception:
        return {}


def _tailscale_hostname() -> str | None:
    """Fetch current Tailscale node name via `tailscale status --json`."""
    try:
        r = subprocess.run(
            ["tailscale", "status", "--json"],
            capture_output=True, text=True, timeout=5,
        )
        if r.returncode != 0:
            return None
        data = json.loads(r.stdout)
        self_node = data.get("Self")
        if not self_node:
            return None
        dns = self_node.get("DNSName", "")
        return dns.split(".")[0] if dns else None
    except (FileNotFoundError, subprocess.TimeoutExpired, json.JSONDecodeError):
        return None


def _hostname_fallback() -> str:
    """Fallback to system hostname when Tailscale is unavailable."""
    return socket.gethostname().lower()


# ---------------------------------------------------------------------------
# public API
# ---------------------------------------------------------------------------


def detect_device() -> tuple[str | None, str | None, str | None]:
    """
    Detect current machine and map it to a k-infra skill.

    Returns:
        (hostname, skill_name | None, device_os | None)
        e.g. ('kpihx-ubuntu', 'k-ubuntu', 'linux')
    """
    hostname = _tailscale_hostname() or _hostname_fallback()

    infra_map = _load_infra_map()
    skill_name = infra_map.get(hostname.lower())

    # Detect OS from Tailscale if available
    device_os: str | None = None
    try:
        r = subprocess.run(
            ["tailscale", "status", "--json"],
            capture_output=True, text=True, timeout=5,
        )
        if r.returncode == 0:
            device_os = json.loads(r.stdout).get("Self", {}).get("OS")
    except Exception:
        pass

    return hostname, skill_name, device_os


def device_context_block() -> str:
    """
    Return a compact device info block for hook injection.

    Returns multiline string or empty string if no device identified.
    Appended to startup context BEFORE the MANDATORY STARTUP CONTEXT section.
    """
    hostname, skill_name, device_os = detect_device()
    if not hostname:
        return ""

    lines = [
        f"--- DEVICE: {hostname} ---",
        f"Machine: {hostname}",
    ]
    if skill_name:
        lines.append(f"Infra skill: {skill_name}")
    if device_os:
        lines.append(f"OS: {device_os}")
    lines.append("--- /DEVICE ---")
    return "\n".join(lines)


def infra_skill_path(skill_name: str | None) -> str | None:
    """Return absolute path to the detected infra skill's SKILL.md, or None."""
    if not skill_name:
        return None
    path = os.path.join(HOME, ".agents", "skills", skill_name, "SKILL.md")
    return path if os.path.isfile(path) else None
