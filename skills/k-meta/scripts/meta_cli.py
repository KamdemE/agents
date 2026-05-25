#!/usr/bin/env python3
"""Meta Graph API smoke — app token, WA phone, business (KπX Meta Dev)."""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

import requests

GRAPH = "https://graph.facebook.com/v21.0"
DEFAULT_CREDS = Path.home() / ".config/kpihx/meta/credentials.json"


def _load_creds(path: Path) -> dict:
    data = json.loads(path.read_text(encoding="utf-8"))

    def s(key: str) -> str:
        v = data.get(key, "")
        if not isinstance(v, str):
            raise SystemExit(f"{path}: {key} must be a string")
        return v.strip()

    out = {
        "app_id": s("app_id"),
        "app_secret": s("app_secret"),
        "business_id": s("business_id"),
        "wa_phone_number_id": s("wa_phone_number_id"),
        "wa_number": s("wa_number"),
    }
    for opt in ("waba_id", "system_user_access_token"):
        v = data.get(opt, "")
        if isinstance(v, str) and v.strip() and "PASTE_" not in v:
            out[opt] = v.strip()
    return out


def _from_env() -> dict:
    mapping = {
        "app_id": "META_APP_ID",
        "app_secret": "META_APP_SECRET",
        "business_id": "META_BUSINESS_ID",
        "wa_phone_number_id": "META_WA_PHONE_NUMBER_ID",
        "wa_number": "META_WA_NUMBER",
    }
    missing = [k for k, env in mapping.items() if not os.environ.get(env)]
    if missing:
        raise SystemExit(f"Missing env: {missing}")
    return {k: os.environ[v].strip() for k, v in mapping.items()}


def _get(url: str, params: dict | None = None) -> tuple[int, dict]:
    r = requests.get(url, params=params or {}, timeout=30)
    try:
        body = r.json()
    except Exception:
        body = {"raw": r.text[:500]}
    return r.status_code, body


def _app_access_token(creds: dict) -> str:
    code, body = _get(
        f"{GRAPH}/oauth/access_token",
        {
            "client_id": creds["app_id"],
            "client_secret": creds["app_secret"],
            "grant_type": "client_credentials",
        },
    )
    if code != 200 or "access_token" not in body:
        print(json.dumps({"step": "app_token", "http": code, "data": body}, indent=2))
        raise SystemExit(1)
    return body["access_token"]


def cmd_smoke(args: argparse.Namespace) -> int:
    creds = _load_creds(args.creds_file) if args.creds_file else _from_env()
    required = ("app_id", "app_secret", "business_id", "wa_phone_number_id", "wa_number")
    for k in required:
        v = creds.get(k, "")
        if not v or "PASTE_" in v:
            print(f"error: {k} not set in credentials", file=sys.stderr)
            return 1

    token = _app_access_token(creds)
    print(json.dumps({"step": "app_token", "http": 200, "ok": True}))

    core_codes: list[int] = []
    c, app_body = _get(f"{GRAPH}/{creds['app_id']}", {"fields": "name,id", "access_token": token})
    core_codes.append(c)
    print(json.dumps({"step": "app", "tier": "core", "http": c, "data": app_body}, indent=2))

    user_token = creds.get("system_user_access_token") or os.environ.get("META_SYSTEM_USER_ACCESS_TOKEN", "")
    wa_token = user_token or token
    c, wa_body = _get(
        f"{GRAPH}/{creds['wa_phone_number_id']}",
        {"fields": "display_phone_number,verified_name,quality_rating", "access_token": wa_token},
    )
    print(
        json.dumps(
            {
                "step": "wa_phone",
                "tier": "extended",
                "http": c,
                "token": "system_user" if user_token else "app",
                "data": wa_body,
            },
            indent=2,
        )
    )

    waba_id = creds.get("waba_id") or os.environ.get("META_WA_BUSINESS_ACCOUNT_ID", "")
    if waba_id:
        c2, waba_body = _get(
            f"{GRAPH}/{waba_id}/phone_numbers",
            {"access_token": wa_token},
        )
        print(
            json.dumps(
                {"step": "waba_phone_numbers", "tier": "extended", "http": c2, "data": waba_body},
                indent=2,
            )
        )

    if user_token:
        c3, biz_body = _get(
            f"{GRAPH}/{creds['business_id']}",
            {"fields": "name,id", "access_token": user_token},
        )
        print(
            json.dumps(
                {"step": "business", "tier": "extended", "http": c3, "data": biz_body},
                indent=2,
            )
        )
    else:
        print(
            json.dumps(
                {
                    "step": "business",
                    "tier": "extended",
                    "skipped": True,
                    "reason": "needs system_user_access_token or META_SYSTEM_USER_ACCESS_TOKEN",
                },
                indent=2,
            )
        )

    core_ok = all(x == 200 for x in core_codes)
    print(json.dumps({"summary": {"core_ok": core_ok, "json_ready": True}}, indent=2))
    return 0 if core_ok else 1


def main() -> int:
    p = argparse.ArgumentParser(description="Meta Graph smoke (kpihx)")
    p.add_argument("--creds-file", type=Path, default=DEFAULT_CREDS)
    p.set_defaults(func=cmd_smoke)
    args = p.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
