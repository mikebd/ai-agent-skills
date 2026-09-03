#!/usr/bin/env python3
"""Report the state of the RTK PreToolUse hook in a Claude Code settings.json.

Prints exactly one word on stdout:

  missing   no usable `rtk hook claude` PreToolUse registration
  bare      registered, but invoked by bare name `rtk` (PATH-fragile)
  pinned    registered with an absolute path to rtk

A settings file that is absent or unparseable reports `missing`: the hook
cannot be running if Claude Code cannot read the file that registers it.
"""

import json
import shlex
import sys


def hook_commands(settings):
    """Yield the command string of every PreToolUse command hook."""
    hooks = settings.get("hooks")
    if not isinstance(hooks, dict):
        return
    entries = hooks.get("PreToolUse")
    if not isinstance(entries, list):
        return
    for entry in entries:
        if not isinstance(entry, dict):
            continue
        for hook in entry.get("hooks", []) or []:
            if not isinstance(hook, dict):
                continue
            if hook.get("type") != "command":
                continue
            command = hook.get("command")
            if isinstance(command, str):
                yield command


def classify(command):
    """Return 'pinned', 'bare', or None for one hook command string."""
    try:
        argv = shlex.split(command)
    except ValueError:
        return None
    if len(argv) < 3 or argv[1:3] != ["hook", "claude"]:
        return None
    program = argv[0]
    if program == "rtk":
        return "bare"
    if program.rsplit("/", 1)[-1] == "rtk":
        return "pinned"
    return None


def main():
    if len(sys.argv) != 2:
        print("usage: rtk-hook-probe.py <settings.json>", file=sys.stderr)
        return 2
    try:
        with open(sys.argv[1], encoding="utf-8") as handle:
            settings = json.load(handle)
    except (OSError, ValueError):
        print("missing")
        return 0
    if not isinstance(settings, dict):
        print("missing")
        return 0

    results = [c for c in (classify(x) for x in hook_commands(settings)) if c]
    # A bare registration anywhere is the finding worth reporting, since that
    # is the one that fails silently.
    if "bare" in results:
        print("bare")
    elif results:
        print("pinned")
    else:
        print("missing")
    return 0


if __name__ == "__main__":
    sys.exit(main())
