#!/usr/bin/env bash
# Install the RTK PreToolUse hook for Claude Code, pinned to rtk's absolute path.
#
# Two steps that must both happen:
#   1. `rtk init -g --hook-only --auto-patch` installs the hook WITHOUT RTK's
#      own RTK.md, which would otherwise duplicate this repo's canonical
#      shared/references/agent-runtime/RTK.md in every session.
#   2. The hook command is rewritten from the bare name `rtk` to an absolute
#      path. A GUI-launched Claude Code often does not inherit the shell-profile
#      PATH that makes `rtk` resolvable (notably Apple Silicon Homebrew's
#      /opt/homebrew/bin), and an unresolvable hook fails silently -- no error,
#      no rewrites.
#
# Idempotent. Backs up settings.json as it was before this script ran -- taken
# before the first mutation, so restoring it undoes the whole run, not just the
# pin. Use --dry-run to preview.
set -euo pipefail

dry_run=false
for arg in "$@"; do
  case "${arg}" in
    --dry-run) dry_run=true ;;
    -h|--help)
      echo "Usage: $(basename "$0") [--dry-run]"
      echo "Installs the RTK hook for Claude Code and pins it to rtk's absolute path."
      exit 0
      ;;
    *)
      echo "Unknown option: ${arg}" >&2
      echo "Usage: $(basename "$0") [--dry-run]" >&2
      exit 2
      ;;
  esac
done

config_dir="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
settings="${config_dir}/settings.json"

if ! command -v rtk >/dev/null 2>&1; then
  echo "rtk not found on PATH. Install it first: https://github.com/rtk-ai/rtk" >&2
  exit 1
fi
rtk_abs="$(command -v rtk)"
echo "rtk:       ${rtk_abs}"

backup=""
take_backup() {
  # settings.json as it was before this script modified anything.
  # Called before each mutation; only the first call does the work.
  [ -n "${backup}" ] && return 0
  [ -f "${settings}" ] || return 0
  backup="${settings}.$(date +%Y%m%d%H%M%S).bak"
  cp "${settings}" "${backup}"
}

# --- Step 1: install the hook if absent -------------------------------------
hook_present=false
if [ -f "${settings}" ] && grep -q '"rtk[[:space:]][[:space:]]*hook\|/rtk[[:space:]][[:space:]]*hook' "${settings}" 2>/dev/null; then
  hook_present=true
fi

if [ "${hook_present}" = true ]; then
  echo "hook:      already present"
else
  if [ "${dry_run}" = true ]; then
    echo "hook:      would run: rtk init -g --hook-only --auto-patch"
  else
    mkdir -p "${config_dir}"
    take_backup
    [ -f "${settings}" ] || printf '{}\n' > "${settings}"
    rtk init -g --hook-only --auto-patch >/dev/null
    echo "hook:      installed"
  fi
fi

# In a dry run the hook was not actually written, so the file cannot be
# inspected for the pin. Report what the real run would do and stop.
if [ "${dry_run}" = true ] && [ "${hook_present}" = false ]; then
  echo "PATH:      would pin to ${rtk_abs}"
  echo
  echo "Dry run. Nothing written."
  exit 0
fi

if [ ! -f "${settings}" ]; then
  echo "settings:  ${settings} not created"
  exit 0
fi

# --- Step 2: pin the hook command to an absolute path -----------------------
bare='"command": "rtk hook claude"'
pinned="\"command\": \"${rtk_abs} hook claude\""

content="$(cat "${settings}")"
if [ "${content}" = "${content/${bare}/}" ]; then
  # The exact literal is absent: either already pinned, or hand-formatted.
  if grep -qE '"command"[[:space:]]*:[[:space:]]*"rtk[[:space:]]+hook' "${settings}" 2>/dev/null; then
    echo "PATH:      hook is PATH-fragile but not in the expected format"
    echo "           edit ${settings} by hand and set:"
    echo "           ${pinned}"
    exit 1
  fi
  echo "PATH:      already pinned to an absolute path"
else
  if [ "${dry_run}" = true ]; then
    echo "PATH:      would pin to ${rtk_abs}"
  else
    take_backup
    printf '%s\n' "${content/${bare}/${pinned}}" > "${settings}"
    echo "PATH:      pinned to ${rtk_abs}"
  fi
fi

# --- Verify -----------------------------------------------------------------
if [ "${dry_run}" = true ]; then
  echo
  echo "Dry run. Nothing written."
  exit 0
fi

if command -v python3 >/dev/null 2>&1; then
  if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "${settings}" 2>/dev/null; then
    echo "json:      valid"
  else
    echo "json:      INVALID after edit -- restore from the backup above" >&2
    exit 1
  fi
fi

[ -n "${backup}" ] && echo "backup:    ${backup} (state before this run)"

echo
echo "Restart Claude Code, then confirm the hook fires:"
echo "  git status && rtk gain --history"
echo
echo "To remove the hook entirely: rtk init -g --uninstall"
