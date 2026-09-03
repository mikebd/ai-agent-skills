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

config_dir="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
hook_script="${config_dir}/hooks/rtk-rewrite.sh"
settings="${config_dir}/settings.json"
rtk_md="${config_dir}/RTK.md"
claude_md="${config_dir}/CLAUDE.md"

hook_installed=false
if [ -f "${hook_script}" ]; then
  hook_installed=true
elif [ -f "${settings}" ] && grep -q 'rtk' "${settings}" 2>/dev/null; then
  hook_installed=true
fi

# The hook command is PATH-fragile when it invokes rtk by bare name: a
# GUI-launched Claude Code (macOS app, IDE) often does not inherit the
# shell-profile PATH that makes `rtk` resolvable, and the hook then fails
# silently -- no error, no rewrites.
path_fragile=false
if [ "${hook_installed}" = true ] && [ -f "${settings}" ]; then
  if grep -qE '"command"[[:space:]]*:[[:space:]]*"rtk[[:space:]]+hook' "${settings}" 2>/dev/null; then
    path_fragile=true
  fi
fi

duplicate=false
[ -f "${rtk_md}" ] && duplicate=true
if [ -f "${claude_md}" ] && grep -qE '^\s*@.*RTK\.md\s*$' "${claude_md}" 2>/dev/null; then
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
  [ "${path_fragile}" = true ] && exit 1
  exit 0
fi

echo "RTK.md:    duplicate artifacts present"
[ -f "${rtk_md}" ] && echo "           ${rtk_md}"
if [ -f "${claude_md}" ] && grep -qE '^\s*@.*RTK\.md\s*$' "${claude_md}" 2>/dev/null; then
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
