#!/usr/bin/env python3
"""X (Twitter) API v2 — OAuth 1.0a user context (KπX X Dev / Vaultwarden)."""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

import requests
from requests_oauthlib import OAuth1

API = "https://api.x.com/2"
DEFAULT_CREDS_FILE = Path.home() / ".config/kpihx/x/credentials.json"


def _oauth1_from_env() -> OAuth1:
    keys = ("X_API_KEY", "X_API_KEY_SECRET", "X_ACCESS_TOKEN", "X_ACCESS_TOKEN_SECRET")
    missing = [k for k in keys if not os.environ.get(k)]
    if missing:
        raise SystemExit(
            f"Missing env: {', '.join(missing)} — unlock Vault (Vaultwarden) or use --creds-file"
        )
    return OAuth1(
        os.environ["X_API_KEY"],
        os.environ["X_API_KEY_SECRET"],
        os.environ["X_ACCESS_TOKEN"],
        os.environ["X_ACCESS_TOKEN_SECRET"],
    )


def _oauth1_from_file(path: Path) -> OAuth1:
    data = json.loads(path.read_text(encoding="utf-8"))

    def _s(key: str) -> str:
        val = data.get(key, "")
        if not isinstance(val, str):
            raise SystemExit(f"credentials.json: {key} must be a string")
        return val.strip()

    return OAuth1(
        _s("api_key"),
        _s("api_key_secret"),
        _s("access_token"),
        _s("access_token_secret"),
    )


def _auth(args: argparse.Namespace) -> OAuth1:
    if args.creds_file and args.creds_file.exists():
        return _oauth1_from_file(args.creds_file)
    return _oauth1_from_env()


def _print_resp(r: requests.Response) -> int:
    try:
        body = r.json()
    except Exception:
        body = {"raw": r.text[:500]}
    print(json.dumps({"http": r.status_code, "data": body}, indent=2, ensure_ascii=False))
    if r.status_code == 402:
        print(
            "\nhint: X API credits depleted — add credits in https://developer.x.com/ (Pay-per-use).",
            file=sys.stderr,
        )
    return 0 if r.ok else 1


def cmd_me(args: argparse.Namespace) -> int:
    r = requests.get(
        f"{API}/users/me",
        auth=_auth(args),
        params={"user.fields": "public_metrics,verified,username,name,id"},
        timeout=30,
    )
    return _print_resp(r)


def cmd_tweet(args: argparse.Namespace) -> int:
    if args.dry_run:
        print(json.dumps({"dry_run": True, "text": args.text}, indent=2))
        return 0
    r = requests.post(f"{API}/tweets", auth=_auth(args), json={"text": args.text}, timeout=30)
    return _print_resp(r)


def cmd_tweets(args: argparse.Namespace) -> int:
    user_id = args.user_id or os.environ.get("X_USER_ID")
    if not user_id:
        me = requests.get(
            f"{API}/users/me",
            auth=_auth(args),
            params={"user.fields": "id"},
            timeout=30,
        )
        if not me.ok:
            return _print_resp(me)
        user_id = me.json()["data"]["id"]
    r = requests.get(
        f"{API}/users/{user_id}/tweets",
        auth=_auth(args),
        params={"max_results": args.limit, "tweet.fields": "created_at,text"},
        timeout=30,
    )
    return _print_resp(r)


def main() -> int:
    p = argparse.ArgumentParser(description="KpihX X API CLI")
    p.add_argument(
        "--creds-file",
        type=Path,
        default=None,
        help=f"Optional JSON (default path for copy: {DEFAULT_CREDS_FILE})",
    )
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("me", help="GET /2/users/me").set_defaults(func=cmd_me)
    tw = sub.add_parser("tweet", help="POST /2/tweets")
    tw.add_argument("text")
    tw.add_argument("--dry-run", action="store_true")
    tw.set_defaults(func=cmd_tweet)
    tl = sub.add_parser("tweets", help="GET user tweets (may require API credits)")
    tl.add_argument("--user-id", default=None)
    tl.add_argument("--limit", type=int, default=5)
    tl.set_defaults(func=cmd_tweets)
    args = p.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
