#!/usr/bin/env python3
"""
Build a VSCode profile `extensions.json` from the global extension registry.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


HOME = Path.home()
SOURCE_PATH = HOME / ".vscode/extensions/extensions.json"
PROFILES_ROOT = HOME / ".config/Code/User/profiles"


def load_source_extensions() -> list[dict]:
    with SOURCE_PATH.open() as handle:
        return json.load(handle)


def load_requested_ids(args: argparse.Namespace) -> list[str]:
    ids: list[str] = []
    ids.extend(args.extension)

    for file_path in args.extension_file:
        with Path(file_path).expanduser().open() as handle:
            for line in handle:
                value = line.strip()
                if value and not value.startswith("#"):
                    ids.append(value)

    unique_ids: list[str] = []
    seen: set[str] = set()
    for extension_id in ids:
        if extension_id not in seen:
            seen.add(extension_id)
            unique_ids.append(extension_id)
    return unique_ids


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build one VSCode profile extensions.json from the global extension registry."
    )
    parser.add_argument(
        "--profile-hash",
        required=True,
        help="Target VSCode profile hash directory under $HOME/.config/Code/User/profiles/.",
    )
    parser.add_argument(
        "--extension",
        action="append",
        default=[],
        help="Extension id to keep. Repeat for multiple ids.",
    )
    parser.add_argument(
        "--extension-file",
        action="append",
        default=[],
        help="Text file containing one extension id per line.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print the resulting JSON instead of writing it.",
    )
    args = parser.parse_args()

    wanted_ids = load_requested_ids(args)
    if not wanted_ids:
        raise SystemExit("At least one --extension or --extension-file is required.")

    all_extensions = load_source_extensions()
    filtered = [
        extension for extension in all_extensions
        if extension.get("identifier", {}).get("id") in wanted_ids
    ]

    missing = [extension_id for extension_id in wanted_ids if extension_id not in {
        extension.get("identifier", {}).get("id") for extension in filtered
    }]
    if missing:
        raise SystemExit(f"Unknown extension ids in source registry: {', '.join(missing)}")

    ordered = sorted(
        filtered,
        key=lambda extension: wanted_ids.index(extension["identifier"]["id"]),
    )

    if args.dry_run:
        print(json.dumps(ordered, indent=4))
        return 0

    profile_dir = PROFILES_ROOT / args.profile_hash
    profile_dir.mkdir(parents=True, exist_ok=True)
    target_path = profile_dir / "extensions.json"
    with target_path.open("w") as handle:
        json.dump(ordered, handle, indent=4)
        handle.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
