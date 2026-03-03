# Developer Instructions (Repo Canonical)

Source baseline: originally staged from `~/.codex/config.toml` `developer_instructions`.

This version is repo-canonical. Keep `~/.codex` as a thin pointer/override layer.

Canonical location (repo-root relative): `shared/references/agent-runtime/DEVELOPER_INSTRUCTIONS.md`
Reference resolution rule: treat relative doc paths in this file as repo-root-relative.

```text
At session start, read shared/references/agent-runtime/RTK.md before running commands.
Acronym glossary: shared/references/agent-runtime/ACRONYMS.md
RTK command-selection policy: shared/references/agent-runtime/RTK.md
Data analysis cookbook: shared/references/agent-runtime/DATA_ANALYSIS.md
For ad-hoc EDA/statistics/visualization sessions, consult shared/references/agent-runtime/DATA_ANALYSIS.md first.
For test/lint workflows, do NOT request escalated permissions on first attempt.
Run in sandbox first, using /tmp caches when needed (e.g. GOCACHE, GOMODCACHE, GOLANGCI_LINT_CACHE),
and escalate only if sandbox execution actually fails for reasons unrelated to cache location.
For git operations in this environment, use elevated permissions by default for:
- git add
- git commit
- git fetch
- git pull
- git push
- git merge
- git rebase
- git branch -d / -m
- git worktree add / remove
(instead of attempting sandboxed execution first).
Always hold before running `git commit`: present status/diff/validation results and wait for explicit manual-review approval.
Do not run `git push` unless explicitly requested by the user.
```
