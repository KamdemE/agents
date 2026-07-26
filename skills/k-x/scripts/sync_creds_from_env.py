#!/usr/bin/env python3
"""One-shot: copy X OAuth 1.0a fields from Vaultwarden into credentials.json (run locally only)."""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

OUT = Path.home() / ".config/kpihx/x/credentials.json"
KEYS = {
    "api_key": "X_API_KEY",
    "api_key_secret": "X_API_KEY_SECRET",
    "access_token": "X_ACCESS_TOKEN",
    "access_token_secret": "X_ACCESS_TOKEN_SECRET",
}


def main() -> int:
    missing = [env for _, env in KEYS.items() if not os.environ.get(env)]
    if missing:
        print(
            f"Missing env (unlock Vaultwarden first): {', '.join(missing)}",
            file=sys.stderr,
        )
        return 1
    payload = {k: os.environ[v].strip() for k, v in KEYS.items()}
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    OUT.chmod(0o600)
    print(json.dumps({"written": str(OUT), "keys": list(payload.keys())}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
