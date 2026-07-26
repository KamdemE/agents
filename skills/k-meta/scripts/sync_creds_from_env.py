#!/usr/bin/env python3
"""Copy Meta Dev fields from Vaultwarden into credentials.json (local one-shot)."""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

OUT = Path.home() / ".config/kpihx/meta/credentials.json"
MAP = {
    "app_id": "META_APP_ID",
    "app_secret": "META_APP_SECRET",
    "business_id": "META_BUSINESS_ID",
    "wa_phone_number_id": "META_WA_PHONE_NUMBER_ID",
    "wa_number": "META_WA_NUMBER",
}


def main() -> int:
    missing = [e for _, e in MAP.items() if not os.environ.get(e)]
    if missing:
        print(
            f"Missing env (unlock Vaultwarden / check Vault Meta Dev): {missing}",
            file=sys.stderr,
        )
        return 1
    payload = {k: os.environ[v].strip() for k, v in MAP.items()}
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    OUT.chmod(0o600)
    print(json.dumps({"written": str(OUT), "keys": list(payload.keys())}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
