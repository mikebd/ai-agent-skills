# Claude Code Execution Model Overlay

Read this when the active agent is Claude Code and
[`DEVELOPER_INSTRUCTIONS.md`](../shared/references/agent-runtime/DEVELOPER_INSTRUCTIONS.md)
calls for constrained execution, elevated execution, a scoped approval, or an
`<agent-home>` path.

Reference resolution rule: treat relative doc paths in this file as
repo-root-relative unless written as an explicit relative link.

## Term mapping

Claude Code has no per-command sandbox/escalation split of the kind Codex uses.
It gates tool calls through permission rules and a session permission mode.

| Neutral term | Claude Code mechanism |
| --- | --- |
| Constrained execution | The default permission mode: each un-allowlisted `Bash` call raises an interactive approval prompt. |
| Elevated execution | A command permitted without prompting, because a `permissions.allow` rule matches it or the user approved it for the session. |
| Scoped approval | A `Bash(<prefix>:*)` entry in `permissions.allow` in `settings.json`. |
| `<agent-home>` | `~/.claude` |

## What "request elevated execution immediately" means here

Codex's sandbox-first default can burn a failed attempt before escalating.
Claude Code prompts instead of silently failing, so the practical translation
of the workflow rules in `DEVELOPER_INSTRUCTIONS.md` is:

- Do not try to work around a prompt by rewriting the command into something
  narrower that will not actually do the job.
- For the workflows flagged as needing elevated execution (browser test
  runners, npm/uv network installs, local dev servers), state plainly that the
  command needs network or port access, run it once, and let the prompt
  resolve — or pre-authorize it via the allowlist below.
- The "constrained-first" default in `DEVELOPER_INSTRUCTIONS.md` still applies
  to test/lint workflows: prefer /tmp caches (GOCACHE, GOMODCACHE,
  GOLANGCI_LINT_CACHE) over asking for broader access.

## Scoped approvals

Scoped approvals go in `permissions.allow` in `~/.claude/settings.json` (user
scope) or a project's `.claude/settings.json`. Translate the command prefixes
named in `DEVELOPER_INSTRUCTIONS.md`:

```text
npm install         -> Bash(npm install:*)
npm ci              -> Bash(npm ci:*)
npm run start       -> Bash(npm run start:*)
npm test            -> Bash(npm test:*)
ng test             -> Bash(ng test:*)
npx ng serve        -> Bash(npx ng serve:*)
npx playwright test -> Bash(npx playwright test:*)
npx cypress run     -> Bash(npx cypress run:*)
uv sync             -> Bash(uv sync:*)
uv lock             -> Bash(uv lock:*)
uv pip install      -> Bash(uv pip install:*)
pip install         -> Bash(pip install:*)
poetry install      -> Bash(poetry install:*)
```

See [`settings.json.example`](./settings.json.example) for a ready-to-merge
starting point covering these plus the git operations listed under "Git
Permissions".

`git commit` and `git push` are deliberately absent from that allowlist. Under
"Commit/Push Controls" in `DEVELOPER_INSTRUCTIONS.md`, `git commit` must hold
for explicit manual-review approval and `git push` must be user-requested. In
Claude Code the permission prompt *is* that hold, so allowlisting either
command would remove the control the rule exists to enforce.

Keep each rule as narrow as the workflow allows. Do not widen a rule to a bare
executable (for example `Bash(npm:*)`) to avoid a second prompt.

## Permission modes

- Leave the session in its default permission mode. Do not ask the user to
  switch to a mode that skips permission prompts in order to satisfy a
  workflow rule in `DEVELOPER_INSTRUCTIONS.md`; add a narrow allowlist entry
  instead.
- `git push` remains user-initiated regardless of allowlist state, per
  "Commit/Push Controls" in `DEVELOPER_INSTRUCTIONS.md`. Allowlisting a git
  command does not authorize running it unprompted.

## Notes

- Local wrapper docs that carry machine-specific or secret-bearing values live
  under `~/.claude` (for example `~/.claude/POSTGRES_AUDIT.local.md`), never in
  this repository.
- `~/.claude/LOCAL-MACHINE.md` is the Claude Code location for the
  machine-local operational notes described in `DEVELOPER_INSTRUCTIONS.md`.
