#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="${repo_root}/codex/skills"
target_dir="${HOME}/.codex/skills"

mkdir -p "${target_dir}"

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "${source_dir}/" "${target_dir}/"
else
  # Fallback: replace target contents with source.
  rm -rf "${target_dir}"/*
  cp -a "${source_dir}/." "${target_dir}/"
fi

echo "Synced ${source_dir} -> ${target_dir}"
