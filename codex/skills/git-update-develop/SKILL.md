---
name: git-update-develop
description: "Safely update a git repo's develop branch: abort on uncommitted changes, require current branch be develop, pull origin develop, summarize incoming commits, and highlight .env.example, config, and documentation (README/docs) changes. Use when a user asks to update develop and review potential local config/env updates."
---

# Git Update Develop

## Overview

Use this skill to update a repository's `develop` branch safely and surface config/env and documentation changes that may need local follow-up. It requires you to already be on `develop`.

## Workflow

1. Run the script from the repo you want to update.
2. If the working tree is dirty, stop and commit or stash before proceeding.
3. Confirm you are already on `develop` before running the script; it will abort on any other branch.
4. Review the incoming commit summary and any highlighted changes.
5. Update local settings or documentation follow-ups as needed.

## Quick Start

```bash
# Run from a repo that is already on develop
/home/mikebd/.codex/skills/git-update-develop/scripts/git-update-develop.sh
```

## What the script does

- Abort if there are any staged or unstaged changes.
- Abort unless the current branch is `develop`.
- `git pull origin develop`
- Summarize incoming commits (if any) with Codex CLI (required).
- Highlight:
  - `.env.example` changes
  - Config-like files (common extensions and config/settings paths)
  - Documentation changes (README and docs/ or other .md files)
  - Added/changed lines that look like env/config reads

## Notes

- If your repo uses a different primary branch name, edit the script.
- Codex CLI must be installed and logged in; the script will abort if it cannot produce an LLM summary.
- Optional: set `CODEX_MODEL` to control the model used by `codex exec`.
- Add/adjust config or doc patterns in the script if your project uses special conventions.

## Resources

### scripts/
- `git-update-develop.sh`: main workflow script.
