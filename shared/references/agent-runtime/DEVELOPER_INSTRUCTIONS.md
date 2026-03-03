# Developer Instructions (Repo Canonical)

Source baseline: originally staged from `~/.codex/config.toml` `developer_instructions`.

This version is repo-canonical. Keep `~/.codex` as a thin pointer/override layer.

Canonical location (repo-root relative): `shared/references/agent-runtime/DEVELOPER_INSTRUCTIONS.md`
Reference resolution rule: treat relative doc paths in this file as repo-root-relative.

```text
Bootstrap
---------
- At session start, read shared/references/agent-runtime/DOC_MAP.md.
- Use DOC_MAP.md as the source of truth for which RMAR docs to read for the current task.

Execution Safety
----------------
- For test/lint workflows, do NOT request escalated permissions on first attempt.
- Run in sandbox first, using /tmp caches when needed (e.g. GOCACHE, GOMODCACHE, GOLANGCI_LINT_CACHE),
  and escalate only if sandbox execution actually fails for reasons unrelated to cache location.

Git Permissions
---------------
- For git operations in this environment, use elevated permissions by default for:
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

Commit/Push Controls
--------------------
- Always hold before running `git commit`: present status/diff/validation results and wait for explicit manual-review approval.
- Do not run `git push` unless explicitly requested by the user.

Editing Safety
--------------
- When editing lists or ordered steps, do not reorder items unless order is confirmed non-semantic.
- Alphabetize only when order does not affect behavior, execution, or interpretation.
- If order is semantic (for example wiring, initialization, migrations, pipelines, or handler chains), preserve it and add a brief note when non-obvious.

RMAR Update Policy
------------------
When asked to update the RMAR:
- Propose the best wording that captures the request's intent, is concise, and improves agent direction; then apply it, unless the user specifies exact wording.
  Confirm if the change alters meaning.
- For examples captured in RMAR, anonymize content so it does not reflect private repository contents.
- Keep RMAR documents consistent, cohesive, non-conflicting, and non-contradicting as a set.
```
