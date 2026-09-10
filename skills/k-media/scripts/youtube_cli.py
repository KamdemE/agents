#!/usr/bin/env python3
"""YouTube Data API v3 — OAuth (<github-user> Desktop client) + smoke tests."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

# Minimal scopes for  ops (extra console scopes are OK but not required).
SCOPES = [
    "https://www.googleapis.com/auth/youtube.readonly",
    "https://www.googleapis.com/auth/youtube.upload",
]

DEFAULT_CLIENT = Path.home() / ".config/gws/<github-user>/client_secret.json"
DEFAULT_TOKEN = Path.home() / ".config/gws/<github-user>/youtube_token.json"


def _load_flow(client_path: Path):
    from google_auth_oauthlib.flow import InstalledAppFlow

    return InstalledAppFlow.from_client_secrets_file(str(client_path), scopes=SCOPES)


def _load_credentials(token_path: Path, client_path: Path):
    from google.auth.transport.requests import Request
    from google.oauth2.credentials import Credentials

    creds = None
    if token_path.exists():
        creds = Credentials.from_authorized_user_file(str(token_path), SCOPES)
    if creds and creds.valid:
        return creds
    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
        token_path.write_text(creds.to_json(), encoding="utf-8")
        return creds
    flow = _load_flow(client_path)
    creds = flow.run_local_server(port=0, open_browser=True)
    token_path.parent.mkdir(parents=True, exist_ok=True)
    token_path.write_text(creds.to_json(), encoding="utf-8")
    return creds


def _youtube_service(creds):
    from googleapiclient.discovery import build

    return build("youtube", "v3", credentials=creds, cache_discovery=False)


def cmd_auth(args: argparse.Namespace) -> int:
    creds = _load_credentials(args.token, args.client)
    print(
        json.dumps(
            {
                "status": "ok",
                "token_file": str(args.token),
                "scopes": list(creds.scopes or SCOPES),
            }
        )
    )
    return 0


def cmd_channels(args: argparse.Namespace) -> int:
    creds = _load_credentials(args.token, args.client)
    yt = _youtube_service(creds)
    resp = (
        yt.channels()
        .list(part="snippet,contentDetails,statistics", mine=True)
        .execute()
    )
    items = []
    for ch in resp.get("items", []):
        sn = ch.get("snippet", {})
        items.append(
            {
                "id": ch.get("id"),
                "title": sn.get("title"),
                "customUrl": sn.get("customUrl"),
                "subs": ch.get("statistics", {}).get("subscriberCount"),
            }
        )
    print(json.dumps({"channels": items}, indent=2, ensure_ascii=False))
    return 0 if items else 1


def cmd_upload(args: argparse.Namespace) -> int:
    from googleapiclient.http import MediaFileUpload

    path = Path(args.file)
    if not path.is_file():
        print(f"error: file not found: {path}", file=sys.stderr)
        return 1
    creds = _load_credentials(args.token, args.client)
    yt = _youtube_service(creds)
    body = {
        "snippet": {
            "title": args.title,
            "description": args.description,
            "categoryId": "22",
        },
        "status": {"privacyStatus": args.privacy},
    }
    media = MediaFileUpload(str(path), chunksize=1024 * 1024, resumable=True)
    req = yt.videos().insert(part="snippet,status", body=body, media_body=media)
    resp = None
    while resp is None:
        status, resp = req.next_chunk()
        if status:
            print(f"upload {int(status.progress() * 100)}%", file=sys.stderr)
    print(
        json.dumps(
            {
                "id": resp.get("id"),
                "title": resp.get("snippet", {}).get("title"),
                "privacy": resp.get("status", {}).get("privacyStatus"),
            },
            indent=2,
        )
    )
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description=" YouTube CLI (<github-user>)")
    p.add_argument("--client", type=Path, default=DEFAULT_CLIENT)
    p.add_argument("--token", type=Path, default=DEFAULT_TOKEN)
    sub = p.add_subparsers(dest="cmd", required=True)

    sub.add_parser("auth", help="OAuth consent + save token").set_defaults(
        func=cmd_auth
    )
    sub.add_parser("channels", help="List my channels").set_defaults(func=cmd_channels)
    up = sub.add_parser("upload", help="Upload video file")
    up.add_argument("--file", required=True)
    up.add_argument("--title", default=" smoke test")
    up.add_argument("--description", default="Automated smoke upload — safe to delete.")
    up.add_argument(
        "--privacy", choices=("private", "unlisted", "public"), default="unlisted"
    )
    up.set_defaults(func=cmd_upload)

    args = p.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
