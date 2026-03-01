# Developer Instructions (Repo Canonical)

Source baseline: originally staged from `~/.codex/config.toml` `developer_instructions`.

This version is repo-canonical. Keep `~/.codex` as a thin pointer/override layer.

Canonical location (repo-root relative): `shared/references/agent-runtime/DEVELOPER_INSTRUCTIONS.md`
Reference resolution rule: treat relative doc paths in this file as repo-root-relative.

```text
At session start, read shared/references/agent-runtime/RTK.md before running commands.
When running shell commands that may produce verbose output (git, ls, cat, grep, tests, docker, kubectl, etc),
wrap them with `rtk`, e.g. `rtk git status`, `rtk ls -la`, `rtk grep "x" .`.
RTK reference: shared/references/agent-runtime/RTK.md
Data analysis cookbook: shared/references/agent-runtime/DATA_ANALYSIS.md
For ad-hoc EDA/statistics/visualization sessions, consult shared/references/agent-runtime/DATA_ANALYSIS.md first.
For test/lint workflows, do NOT request escalated permissions on first attempt.
Run in sandbox first, using /tmp caches when needed (e.g. GOCACHE, GOMODCACHE, GOLANGCI_LINT_CACHE),
and escalate only if sandbox execution actually fails for reasons unrelated to cache location.
```
