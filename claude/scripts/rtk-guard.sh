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
# Report-only: this script never modifies files.
# Exit 0 when nothing needs attention, 1 otherwise.
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
probe="${script_dir}/rtk-hook-probe.py"

config_dir="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
settings="${config_dir}/settings.json"
rtk_md="${config_dir}/RTK.md"
claude_md="${config_dir}/CLAUDE.md"

# Only a real `hooks.PreToolUse` registration of `rtk hook claude` counts as
# installed. rtk writes no hook script of its own, so settings.json is the sole
# source of truth, and matching stray `rtk` text anywhere in it would report a
# hook that Claude Code will never invoke.
#
# The hook is also PATH-fragile when it invokes rtk by bare name: a
# GUI-launched Claude Code (macOS app, IDE) often does not inherit the
# shell-profile PATH that makes `rtk` resolvable, and the hook then fails
# silently -- no error, no rewrites.
hook_state=missing
if command -v python3 >/dev/null 2>&1 && [ -f "${probe}" ]; then
  hook_state="$(python3 "${probe}" "${settings}" 2>/dev/null || echo missing)"
elif [ -f "${settings}" ] && grep -q '"PreToolUse"' "${settings}" 2>/dev/null; then
  # Fallback without python3: line-oriented and unable to confirm that the
  # command sits under PreToolUse, so it can over-report on a settings file
  # that registers rtk under some other event.
  if grep -qE '"command"[[:space:]]*:[[:space:]]*"rtk[[:space:]]+hook[[:space:]]+claude"' "${settings}" 2>/dev/null; then
    hook_state=bare
  elif grep -qE '"command"[[:space:]]*:[[:space:]]*"[^"]*/rtk[[:space:]]+hook[[:space:]]+claude"' "${settings}" 2>/dev/null; then
    hook_state=pinned
  fi
fi

hook_installed=false
path_fragile=false
[ "${hook_state}" != missing ] && hook_installed=true
[ "${hook_state}" = bare ] && path_fragile=true

duplicate=false
[ -f "${rtk_md}" ] && duplicate=true
if [ -f "${claude_md}" ] && grep -qE '^[[:space:]]*@.*RTK\.md[[:space:]]*$' "${claude_md}" 2>/dev/null; then
  duplicate=true
fi

if [ "${hook_installed}" = true ]; then
  echo "hook:      installed (${config_dir})"
else
  echo "hook:      not installed"
  echo "           install: rtk init -g --hook-only --auto-patch"
fi

if [ "${path_fragile}" = true ]; then
  rtk_abs="$(command -v rtk 2>/dev/null || true)"
  echo "PATH:      hook invokes bare 'rtk' (fails silently off-PATH)"
  if [ -n "${rtk_abs}" ]; then
    echo "           pin it: set \"command\": \"${rtk_abs} hook claude\""
  else
    echo "           pin it to rtk's absolute path in ${settings}"
  fi
  echo "           in ${settings}"
elif [ "${hook_installed}" = true ]; then
  echo "PATH:      hook command is absolute"
fi

if [ "${duplicate}" = false ]; then
  echo "RTK.md:    no duplicate artifacts"
  # A clean machine must not pass the setup check without RTK enforcement, so
  # a missing or PATH-fragile hook fails even with nothing to de-duplicate.
  [ "${hook_installed}" = true ] && [ "${path_fragile}" = false ] && exit 0
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
