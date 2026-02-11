---
name: git-update-branch
description: "Safely update the current git branch: abort on uncommitted changes, require a non-detached current branch, fetch/pull for that branch only, summarize incoming commits, and highlight .env.example, config, and documentation (README/docs) changes. Use when a user asks to update their current branch and review potential local config/env updates."
---

# Git Update Branch

## Overview

Use this skill to update the repository's current branch safely and surface config/env and documentation changes that may need local follow-up.

## Workflow

1. Run the script from the repo you want to update.
2. If the working tree is dirty, stop and commit or stash before proceeding.
3. Confirm you are on a local branch (not detached HEAD) before running the script; it will abort otherwise.
4. Review the incoming commit summary and any highlighted changes.
   - DO NOT produce long lists of changed / added / removed files.
   - DO NOT focus on changes in vendor/ (or vendored files generally that are materialized in the repo),
     only highlight such changes if they have specific impact on production code, testing or operations.
5. Update local settings or documentation follow-ups as needed.

## Quick Start

```bash
# Run from a repo on the branch you want to update
/home/mikebd/.codex/skills/git-update-branch/scripts/git-update-branch.sh
```

## What the script does

- Abort if there are any staged or unstaged changes.
- Abort if current branch is detached (`HEAD`).
- `git fetch origin <current-branch>`
- Summarize incoming commits (if any) with Codex CLI (required).
- Highlight:
  - `.env.example` changes
  - Config-like files (common extensions and config/settings paths)
  - Documentation changes (README and docs/ or other .md files)
  - Added/changed lines that look like env/config reads
- `git pull origin <current-branch>`

## Notes

- Codex CLI must be installed and logged in; the script will abort if it cannot produce an LLM summary.
- Optional: set `CODEX_MODEL` to control the model used by `codex exec`.
- Add/adjust config or doc patterns in the script if your project uses special conventions.

## Resources

### scripts/
- `git-update-branch.sh`: main workflow script.
