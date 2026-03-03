#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "usage: rtk_proxy.sh <command> [args...]" >&2
  exit 2
fi

if ! command -v rtk >/dev/null 2>&1; then
  echo "rtk_proxy.sh: rtk not found in PATH" >&2
  exit 127
fi

# This wrapper is for verbose, non-native RTK commands where compact
# post-processing is still useful and exact streaming output is not required.
# For exact/raw output needs, run the command directly or via `rtk proxy`.
out_file="$(mktemp)"
cleanup() {
  rm -f "$out_file"
}
trap cleanup EXIT

set +e
"$@" >"$out_file" 2>&1
cmd_status=$?
set -e

# Use RTK's file-oriented compaction for large output.
rtk read "$out_file"

exit "$cmd_status"
