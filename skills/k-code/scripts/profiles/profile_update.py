#!/usr/bin/env python3
"""
Update VSCode profile registry and workspace associations.

VSCode must be closed before writing `storage.json`, otherwise the running
process may overwrite external edits.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


HOME = Path.home()
STORAGE_PATH = HOME / ".config/Code/User/globalStorage/storage.json"


def load_storage() -> dict:
    with STORAGE_PATH.open() as handle:
        return json.load(handle)


def parse_register(value: str) -> tuple[str, str]:
    if ":" not in value:
        raise argparse.ArgumentTypeError("expected <hash>:<name>")
    profile_hash, name = value.split(":", 1)
    profile_hash = profile_hash.strip()
    name = name.strip()
    if not profile_hash or not name:
        raise argparse.ArgumentTypeError("both <hash> and <name> are required")
    return profile_hash, name


def parse_assign(value: str) -> tuple[str, str]:
    if ":" not in value:
        raise argparse.ArgumentTypeError("expected <workspace-path>:<profile-hash>")
    workspace, profile_hash = value.rsplit(":", 1)
    workspace = workspace.strip()
    profile_hash = profile_hash.strip()
    if not workspace or not profile_hash:
        raise argparse.ArgumentTypeError("both <workspace-path> and <profile-hash> are required")
    return workspace, profile_hash


def workspace_uri(workspace: str) -> str:
    path = Path(workspace).expanduser().resolve()
    return path.as_uri()


def ensure_profile(data: dict, profile_hash: str, name: str) -> None:
    profiles = data.setdefault("userDataProfiles", [])
    for profile in profiles:
        if profile.get("location") == profile_hash:
            profile["name"] = name
            return
    profiles.append({"location": profile_hash, "name": name})


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Update VSCode storage.json profile registry and workspace associations."
    )
    parser.add_argument(
        "--register",
        action="append",
        default=[],
        type=parse_register,
        metavar="HASH:NAME",
        help="Register or rename a custom profile.",
    )
    parser.add_argument(
        "--promote-default-to",
        metavar="PROFILE_HASH",
        help="Reassign all workspaces currently on __default__profile__ to this custom profile hash.",
    )
    parser.add_argument(
        "--assign",
        action="append",
        default=[],
        type=parse_assign,
        metavar="WORKSPACE:HASH",
        help="Assign one workspace path to a specific profile hash.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the resulting JSON instead of writing it.",
    )
    args = parser.parse_args()

    data = load_storage()

    for profile_hash, name in args.register:
        ensure_profile(data, profile_hash, name)

    workspaces = data.setdefault("profileAssociations", {}).setdefault("workspaces", {})

    if args.promote_default_to:
        for uri, profile_hash in list(workspaces.items()):
            if profile_hash == "__default__profile__":
                workspaces[uri] = args.promote_default_to

    for workspace, profile_hash in args.assign:
        workspaces[workspace_uri(workspace)] = profile_hash

    if args.dry_run:
        print(json.dumps(data, indent=2))
        return 0

    with STORAGE_PATH.open("w") as handle:
        json.dump(data, handle, indent=2)
        handle.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
