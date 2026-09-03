#!/usr/bin/env python3
"""Report the state of the RTK PreToolUse hook in a Claude Code settings.json.

Prints exactly one word on stdout:

  missing   no usable `rtk hook claude` PreToolUse registration for Bash
  bare      registered, but not by absolute path (PATH- or cwd-dependent)
  pinned    registered with an absolute path to rtk

A settings file that is absent or unparseable reports `missing`: the hook
cannot be running if Claude Code cannot read the file that registers it.

With --program, prints the program path of the registration it selected
instead, or nothing when there is none. The caller uses this to check that a
pinned path still exists -- pinning to a path that has gone away fails as
silently as never pinning at all.
"""

import json
import os
import re
import shlex
import sys


# A matcher built only from these characters is a name or a list of names;
# anything else puts it on the regular-expression path. This is Claude Code's
# rule, not ours -- see the table under "matcher" in its hooks documentation.
EXACT_MATCH_ONLY = re.compile(r"[A-Za-z0-9_\- ,|]+")


def matches_bash(matcher):
    """Whether a PreToolUse entry's matcher selects the Bash tool.

    Claude Code decides how to read a matcher from the characters in it:

    * `*`, an empty string, or an absent matcher fires on every tool.
    * Letters, digits, `_`, `-`, spaces, `,` and `|` only: an exact tool name,
      or a list of them separated by `|` or `,` with optional whitespace. So
      `Bash`, `Edit|Bash` and `Edit, Bash` all select Bash, and `Edit` does not.
    * Any other character: an unanchored JavaScript regular expression, tested
      with `RegExp.prototype.test`. Unanchored is the part worth care -- `ash.*`
      selects Bash, and matching it with an anchored test would report a live
      hook as missing.

    A pattern Python cannot compile returns False, which the caller reports as
    a missing hook. That is the safe direction for a setup check: it says "not
    verified" rather than claiming a hook is in place.
    """
    if matcher is None or matcher in ("", "*"):
        return True
    if not isinstance(matcher, str):
        return False
    if EXACT_MATCH_ONLY.fullmatch(matcher):
        return "Bash" in [name.strip() for name in re.split(r"[|,]", matcher)]
    try:
        return re.search(matcher, "Bash") is not None
    except re.error:
        return False


def hook_commands(settings):
    """Yield the command of every PreToolUse command hook that covers Bash."""
    hooks = settings.get("hooks")
    if not isinstance(hooks, dict):
        return
    entries = hooks.get("PreToolUse")
    if not isinstance(entries, list):
        return
    for entry in entries:
        if not isinstance(entry, dict):
            continue
        # A hook registered under a non-Bash matcher never sees a shell
        # command, so it is not evidence that anything gets rewritten.
        if not matches_bash(entry.get("matcher")):
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
    if os.path.basename(program) != "rtk":
        return None
    # Only an absolute path is independent of both PATH and the working
    # directory of whatever process spawns the hook. `./rtk` and `bin/rtk`
    # resolve against a cwd this script cannot predict, so they are as fragile
    # as the bare name.
    return "pinned" if os.path.isabs(program) else "bare"


def program_of(command):
    """The program path of a command classify() accepts, else None."""
    if classify(command) is None:
        return None
    return shlex.split(command)[0]


def main():
    argv = sys.argv[1:]
    want_program = False
    if argv and argv[0] == "--program":
        want_program = True
        argv = argv[1:]
    if len(argv) != 1:
        print("usage: rtk-hook-probe.py [--program] <settings.json>",
              file=sys.stderr)
        return 2
    try:
        with open(argv[0], encoding="utf-8") as handle:
            settings = json.load(handle)
    except (OSError, ValueError):
        if not want_program:
            print("missing")
        return 0
    if not isinstance(settings, dict):
        if not want_program:
            print("missing")
        return 0

    commands = list(hook_commands(settings))
    results = [(classify(c), c) for c in commands]
    results = [(state, c) for state, c in results if state]

    # A bare registration anywhere is the finding worth reporting, since that
    # is the one that fails silently.
    chosen = next((pair for pair in results if pair[0] == "bare"), None)
    if chosen is None:
        chosen = results[0] if results else None

    if want_program:
        if chosen is not None:
            print(program_of(chosen[1]))
        return 0

    print(chosen[0] if chosen is not None else "missing")
    return 0


if __name__ == "__main__":
    sys.exit(main())
