#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z "${repo_root}" ]]; then
  echo "Not inside a git repository." >&2
  exit 1
fi

cd "${repo_root}"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is dirty. Commit or stash your changes before updating develop." >&2
  git status --short
  exit 1
fi

current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "${current_branch}" != "develop" ]]; then
  echo "Current branch is '${current_branch}'. Switch to 'develop' before running this script." >&2
  exit 1
fi

# Prefer ripgrep if available; fall back to grep -E.
filter_lines() {
  local pattern="$1"
  if command -v rg >/dev/null 2>&1; then
    rg -n "${pattern}" || true
  else
    grep -n -E "${pattern}" || true
  fi
}

echo "Fetching origin/develop..."
git fetch origin develop

incoming_commits=$(git log --oneline --decorate --no-color HEAD..origin/develop || true)
if [[ -n "${incoming_commits}" ]]; then
  echo
  echo "Incoming commits (HEAD..origin/develop):"
  echo "${incoming_commits}"

  if ! command -v codex >/dev/null 2>&1; then
    echo
    echo "Codex CLI not found; LLM summary is required. Install/log in and retry." >&2
    exit 1
  fi

  echo
  echo "LLM summary (Codex):"
  summary_tmp=$(mktemp)
  cleanup() {
    rm -f "${summary_tmp}"
  }
  trap cleanup EXIT

  commit_stats=$(git log --no-color --decorate --stat HEAD..origin/develop || true)
  prompt=$(
    cat <<'PROMPT'
Summarize these incoming git commits for a developer:
- Use 4-7 bullets.
- Highlight any config/env or doc changes.
- Call out potential breaking changes or migrations.
- Keep it concise.

COMMITS AND STATS:
PROMPT
  )
  prompt="${prompt}\n${commit_stats}"

  codex_args=(exec --output-last-message "${summary_tmp}" --skip-git-repo-check)
  if [[ -n "${CODEX_MODEL:-}" ]]; then
    codex_args+=(-m "${CODEX_MODEL}")
  fi

  if ! printf "%b" "${prompt}" | codex "${codex_args[@]}" - >/dev/null 2>&1; then
    echo "Codex summary failed (not logged in or error). Aborting." >&2
    exit 1
  fi

  if [[ -s "${summary_tmp}" ]]; then
    cat "${summary_tmp}"
  else
    echo "Codex did not return a summary. Aborting." >&2
    exit 1
  fi
else
  echo
  echo "No incoming commits."
fi

incoming_files=$(git diff --name-only HEAD..origin/develop || true)

highlight_section() {
  local title="$1"
  local matches="$2"
  if [[ -n "${matches}" ]]; then
    echo
    echo "${title}"
    echo "${matches}"
  fi
}

# .env.example changes
highlight_section "Changes to .env.example:" "$(echo "${incoming_files}" | filter_lines "(^|/)\.env\.example$")"

# Config-like files/paths
highlight_section "Config-related file changes:" "$(echo "${incoming_files}" | filter_lines "(^|/)(config|configs|conf|settings)(/|$)|\.(ya?ml|json|toml|ini|env|cfg|conf|properties)$")"

# Documentation changes
highlight_section "Documentation changes:" "$(echo "${incoming_files}" | filter_lines "(^|/)README\.md$|(^|/)docs(/|$)|\.md$")"

# Heuristic: env/config usage changes in code
config_lines=$(git diff -U0 HEAD..origin/develop -- . | filter_lines "(ENV\[|getenv|os\.Getenv|process\.env|dotenv|config\.|settings\.|viper|koanf|pflag|flag\.)")
highlight_section "Config/env usage changes in code (heuristic):" "${config_lines}"

echo
echo "Pulling origin develop..."
git pull origin develop
