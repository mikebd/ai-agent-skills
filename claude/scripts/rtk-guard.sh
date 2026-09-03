#!/usr/bin/env bash
# Report whether the RTK Claude hook is installed, and whether RTK's own
# RTK.md artifacts duplicate this repo's RTK.md guidance.
#
# When the hook is installed, `rtk init -g` also writes <config>/RTK.md and
# imports it from <config>/CLAUDE.md. That guidance is redundant with the hook
# (which rewrites commands mechanically) and overlaps this repo's canonical
# shared/references/agent-runtime/RTK.md, so it is duplicated context in every
# session. `rtk init -g --hook-only --auto-patch` installs the hook without it.
#
# It also reports a PATH-fragile hook command, which fails silently rather than
# erroring when `rtk` is not on the PATH of the process spawning the hook.
#
# RTK is optional: a machine with no hook and no rtk passes, since not adopting
# RTK is a choice rather than a fault.
#
# Report-only: this script never modifies files.
# Exit 0 when nothing needs attention, 1 otherwise.
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
probe="${script_dir}/rtk-hook-probe.py"

# RTK is optional. A machine that has deliberately not adopted it should pass
# this check, not be told to install something. Only the combination "no hook
# registered AND no rtk" counts as opting out: a registered hook is checked on
# its merits either way, since a pinned hook keeps working when rtk is off the
# PATH of the shell running this script -- that is what pinning is for.
rtk_available=false
command -v rtk >/dev/null 2>&1 && rtk_available=true

config_dir="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
settings="${config_dir}/settings.json"
rtk_md="${config_dir}/RTK.md"
claude_md="${config_dir}/CLAUDE.md"

# Only a real `hooks.PreToolUse` registration of `rtk hook claude`, under a
# matcher that selects Bash, counts as installed. rtk writes no hook script of
# its own, so settings.json is the sole source of truth; matching stray `rtk`
# text, or a hook registered for some other tool or event, would report a hook
# that never sees a shell command.
#
# The hook is also fragile unless the command is an absolute path: a
# GUI-launched Claude Code (macOS app, IDE) often does not inherit the
# shell-profile PATH that makes `rtk` resolvable, and a relative path resolves
# against an unpredictable working directory. Either way the hook fails
# silently -- no error, no rewrites.
#
# Establishing both facts means understanding the structure of settings.json,
# which grep cannot do. Without python3 this check fails closed rather than
# guessing from matching lines.
hook_state=unverified
if command -v python3 >/dev/null 2>&1 && [ -f "${probe}" ]; then
  hook_state="$(python3 "${probe}" "${settings}" 2>/dev/null || echo missing)"
fi

hook_installed=false
path_fragile=false
case "${hook_state}" in
  pinned) hook_installed=true ;;
  bare) hook_installed=true; path_fragile=true ;;
esac

# A pin is only worth having while the path it names still exists. Homebrew
# moves from /usr/local to /opt/homebrew between Intel and Apple Silicon, and
# uninstalling rtk leaves the registration behind -- both leave a hook that
# looks correct and never runs.
broken_pin=""
if [ "${hook_state}" = pinned ] && command -v python3 >/dev/null 2>&1; then
  hook_program="$(python3 "${probe}" --program "${settings}" 2>/dev/null || true)"
  if [ -n "${hook_program}" ] && [ ! -x "${hook_program}" ]; then
    broken_pin="${hook_program}"
  fi
fi

duplicate=false
[ -f "${rtk_md}" ] && duplicate=true
if [ -f "${claude_md}" ] && grep -qE '^[[:space:]]*@.*RTK\.md[[:space:]]*$' "${claude_md}" 2>/dev/null; then
  duplicate=true
fi

case "${hook_state}" in
  pinned|bare)
    echo "hook:      installed (${config_dir})"
    ;;
  unverified)
    echo "hook:      cannot verify -- python3 not found"
    echo "           Confirming a PreToolUse registration under a Bash matcher"
    echo "           means parsing settings.json, which grep cannot do. This"
    echo "           check fails closed rather than report an unverified pass."
    ;;
  *)
    if [ "${rtk_available}" = false ]; then
      echo "hook:      not installed, and rtk is not on PATH"
      echo "           RTK is optional and is not in use here. Nothing to check."
      echo "           To adopt it: brew install rtk, then ./claude/scripts/rtk-install.sh"
    else
      echo "hook:      not installed"
      echo "           install: rtk init -g --hook-only --auto-patch"
    fi
    ;;
esac

if [ "${path_fragile}" = true ]; then
  rtk_abs="$(command -v rtk 2>/dev/null || true)"
  echo "PATH:      hook command is not an absolute path (fails silently)"
  if [ -n "${rtk_abs}" ]; then
    echo "           pin it: set \"command\": \"${rtk_abs} hook claude\""
  else
    echo "           pin it to rtk's absolute path in ${settings}"
  fi
  echo "           in ${settings}"
elif [ -n "${broken_pin}" ]; then
  rtk_abs="$(command -v rtk 2>/dev/null || true)"
  echo "PATH:      hook is pinned to a path that does not exist"
  echo "           ${broken_pin}"
  if [ -n "${rtk_abs}" ]; then
    echo "           re-pin it: set \"command\": \"${rtk_abs} hook claude\""
    echo "           in ${settings}"
  else
    echo "           rtk is not on PATH either; reinstall it, then re-run"
    echo "           ./claude/scripts/rtk-install.sh"
  fi
elif [ "${hook_installed}" = true ]; then
  echo "PATH:      hook command is absolute"
fi

if [ "${duplicate}" = false ]; then
  echo "RTK.md:    no duplicate artifacts"
  # A machine that has adopted RTK must not pass without working enforcement, so
  # anything short of a verified, pinned hook fails. A machine that has not
  # adopted it passes: no hook and no rtk is a choice, not a fault. "unverified"
  # is never a pass -- it means the check could not run, which is not the same
  # as having nothing to check.
  [ "${hook_state}" = pinned ] && [ -z "${broken_pin}" ] && exit 0
  [ "${hook_state}" = missing ] && [ "${rtk_available}" = false ] && exit 0
  exit 1
fi

echo "RTK.md:    duplicate artifacts present"
[ -f "${rtk_md}" ] && echo "           ${rtk_md}"
if [ -f "${claude_md}" ] && grep -qE '^[[:space:]]*@.*RTK\.md[[:space:]]*$' "${claude_md}" 2>/dev/null; then
  echo "           @RTK.md import in ${claude_md}"
fi

if [ "${hook_installed}" = true ]; then
  echo
  echo "The hook already enforces RTK command selection, so this guidance is"
  echo "redundant. This repo's shared/references/agent-runtime/RTK.md remains"
  echo "the canonical local policy. To remove the duplicates:"
  echo
  echo "  rm ${rtk_md}"
  echo "  # then delete the '@RTK.md' line from ${claude_md}"
  echo
  echo "Reinstall later with: rtk init -g --hook-only --auto-patch"
fi

exit 1
