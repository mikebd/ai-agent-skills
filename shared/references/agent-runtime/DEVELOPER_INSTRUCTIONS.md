# Developer Instructions (Repo Canonical)

Source baseline: originally staged from `~/.codex/config.toml` `developer_instructions`.

This version is repo-canonical. Keep `~/.codex` as a thin pointer/override layer.

Canonical location (repo-root relative): `shared/references/agent-runtime/DEVELOPER_INSTRUCTIONS.md`
Reference resolution rule: treat relative doc paths in this file as repo-root-relative.

## Bootstrap
- At session start, read shared/references/agent-runtime/DOC_MAP.md.
- Use DOC_MAP.md as the source of truth for which RMAR docs to read for the current task.
- Before selecting local shell commands, read the RMAR docs that govern command choice for the current task.
- If local shell commands, search commands, git commands, or Go test/build/vet commands are likely, read shared/references/agent-runtime/RTK.md before choosing commands.
- Treat RTK guidance as operational policy, not optional advice, when RTK.md applies.

## Execution Safety
- For test/lint workflows, do NOT request escalated permissions on first attempt.
- Run in sandbox first, using /tmp caches when needed (e.g. GOCACHE, GOMODCACHE, GOLANGCI_LINT_CACHE),
  and escalate only if sandbox execution actually fails for reasons unrelated to cache location.

### Frontend Browser Test Workflows
- For browser-driven frontend test runners that start local servers or bind TCP ports (for example `ng test`/Karma, Playwright, Cypress), request escalated execution immediately instead of sandbox-first.
- Prefer narrowly scoped `prefix_rule` approvals such as `["npm", "test"]`, `["ng", "test"]`, `["npx", "playwright", "test"]`, or `["npx", "cypress", "run"]`.

### Node / npm Network Workflows
- When working in any repo that uses Node-based tooling, if `npm install`, `npm ci`, `npx`, or similar npm commands are likely to require registry/network access, request escalated execution immediately instead of attempting the command in the sandbox first.
- Prefer narrowly scoped `prefix_rule` approvals such as `["npm", "install"]`, `["npm", "ci"]`, or `["npm", "run", "start"]`.
- If a Node build/test step is expected to fetch remote assets at runtime (for example Angular production font/CSS inlining from external hosts), request escalated execution immediately instead of attempting sandbox-first.

### Python / uv Network Workflows
- When working in any repo that uses Python-based tooling, if `uv sync`, `uv lock`, `uv pip install`, `uv run` with dependency resolution, `pip install`, `poetry install`, or similar commands are likely to require package-index/network access, request escalated execution immediately instead of attempting the command in the sandbox first.
- Prefer narrowly scoped `prefix_rule` approvals such as `["uv", "sync"]`, `["uv", "lock"]`, `["uv", "pip", "install"]`, `["pip", "install"]`, or `["poetry", "install"]`.

### Local Dev Server Workflows
- When starting a local development server that is expected to bind to a TCP port for browser, API, or webhook access, request escalated execution immediately instead of first attempting to run it in the sandbox.
- Prefer narrowly scoped `prefix_rule` approvals such as `["npm", "run", "start"]`, `["npx", "ng", "serve"]`, `["vite"]`, `["next", "dev"]`, or similar repo-appropriate dev-server commands.

## Git Permissions
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

### Git Lock Safety
- Never run git index-writing commands in parallel (`git add`, `git commit`, `git merge`, `git rebase`, `git checkout`, `git stash`, etc.); execute them serially.
- If a git command fails with `index.lock`:
  - Check whether another git process is still active before removing the lock.
  - Remove `.git/index.lock` only when confirmed stale, then retry the original command once.
- After lock recovery, run `git status --short` before continuing to confirm repository state is consistent.

## Commit/Push Controls
- Always hold before running `git commit`: present status/diff/validation results and wait for explicit manual-review approval.
- Do not run `git push` unless explicitly requested by the user.
- After a rebase (or otherwise when required), use `git push --force-if-includes --force-with-lease` for safer history updates.

## Branch Sync Strategy
- When incorporating parent-branch updates into a feature branch early in development (for example while PR is draft and no shared branch activity is expected), prefer rebase to keep history linear.
- When the branch is late in PR lifecycle, or when shared developer activity is occurring against the same remote branch, use merge instead of rebase to avoid rewriting published history and disrupting collaborators.
- If uncertain whether the branch is shared, assume shared and use merge unless explicitly directed to rebase.

## Assumption Handling
- Prefer direct execution by default; switch to explicit plan mode when scope, risk, or ambiguity is high.
- Validate key assumptions early and state them clearly before substantial implementation.
- Raise unclear or unspecified requirements for review when they are likely to affect behavior, contracts, safety, or rework cost.
- Do not guess for safety-critical, schema-contract, or irreversible changes; require explicit confirmation.
- For low-risk gaps, make the smallest reasonable assumption, proceed, and document it in progress updates.

## Debugging Hygiene
- During root-cause debugging, once the actual cause is isolated and addressed, proactively review prior speculative fixes and suggest removing ones no longer required so the final change set is minimal.
- Exception: when changes are audit/evidence infrastructure, keep them by default unless the user explicitly asks to remove them.

## Editing Safety
- When editing lists or ordered steps, do not reorder items unless order is confirmed non-semantic.
- Alphabetize only when order does not affect behavior, execution, or interpretation.
- If order is semantic (for example wiring, initialization, migrations, pipelines, or handler chains), preserve it and add a brief note when non-obvious.

## Script Reliability
- If an ad-hoc shell script is complex (multi-step exports/transforms, quoting-sensitive SQL/sed/awk, or repeated retries due to shell parsing), and is likely to be reused, materialize it as a repo script instead of regenerating it ad hoc.
- Prefer a canonical parameterized script + documented flags over one-off inline commands to reduce quoting drift and behavioral variation across runs/sessions.
- When shell workflows require embedded `awk`/`python` (or similar) blocks
  beyond trivial one-liners, materialize them as standalone helper scripts and
  call them from shell.
- After creating or editing shell scripts, run `shellcheck` when available before first use; if unavailable, note that explicitly and proceed with cautious validation (`bash -n`, small-scope dry run first).

## RMAR Update Policy
When asked to update the RMAR:
- Propose the best wording that captures the request's intent, is concise, and improves agent direction; then apply it, unless the user specifies exact wording.
  Confirm if the change alters meaning.
- After making any RMAR change, reread the updated RMAR document(s) before continuing so subsequent actions follow the new instructions.
- For examples captured in RMAR, anonymize content so it does not reflect private repository contents.
- Keep RMAR documents consistent, cohesive, non-conflicting, and non-contradicting as a set.
