#!/usr/bin/env python3
"""
Codex hook: PreToolUse compatibility shim.

The live KπX Codex wiring no longer uses PreToolUse because the current Codex
runtime surface here does not expose structured file-edit events worth guarding.

This file remains as a no-op shim so already-running Codex sessions, or stale
deployed hook copies, do not break when they still try to execute the legacy
PreToolUse entrypoint.
"""
import sys


def main():
    sys.exit(0)


if __name__ == "__main__":
    main()
