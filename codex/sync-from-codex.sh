#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $(basename "$0") <skill-name>" >&2
  exit 1
fi

skill_name="$1"
if [[ "${skill_name}" == *"/"* ]] || [[ "${skill_name}" == *".."* ]]; then
  echo "Skill name must be a simple directory name." >&2
  exit 1
fi

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
codex_skills_dir="${HOME}/.codex/skills"
source_dir="${codex_skills_dir}/${skill_name}"
target_dir="${repo_root}/codex/skills/${skill_name}"

if [ ! -d "${codex_skills_dir}" ]; then
  echo "Codex skills directory not found at ${codex_skills_dir}" >&2
  exit 1
fi

if [ ! -d "${source_dir}" ]; then
  echo "Skill not found in ${codex_skills_dir}: ${skill_name}" >&2
  exit 1
fi

mkdir -p "${target_dir}"

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "${source_dir}/" "${target_dir}/"
else
  # Fallback: replace target contents with source.
  rm -rf "${target_dir}"/*
  cp -a "${source_dir}/." "${target_dir}/"
fi

echo "Synced ${source_dir} -> ${target_dir}"
