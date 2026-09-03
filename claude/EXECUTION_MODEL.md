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
| `<agent-home>` | `${CLAUDE_CONFIG_DIR:-~/.claude}` |

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

Scoped approvals go in `permissions.allow` in `<agent-home>/settings.json` (user
scope) or a project's `.claude/settings.json`. Translate the command prefixes
named in `DEVELOPER_INSTRUCTIONS.md`:

```text
npm run start       -> Bash(npm run start:*)
npm test            -> Bash(npm test:*)
ng test             -> Bash(ng test:*)
npx ng serve        -> Bash(npx ng serve:*)
npx playwright test -> Bash(npx playwright test:*)
npx cypress run     -> Bash(npx cypress run:*)
uv lock             -> Bash(uv lock:*)
```

See [`settings.json.example`](./settings.json.example) for a ready-to-merge
starting point covering these plus the git operations listed under "Git
Permissions".

### Package installs are a separate, deliberate opt-in

The remaining prefixes in `DEVELOPER_INSTRUCTIONS.md` reach a package index and
run code that neither you nor the agent wrote:

```text
npm install         -> Bash(npm install:*)
npm ci              -> Bash(npm ci:*)
uv sync             -> Bash(uv sync:*)
uv pip install      -> Bash(uv pip install:*)
pip install         -> Bash(pip install:*)
poetry install      -> Bash(poetry install:*)
```

These are **not** in `settings.json.example`, and that omission is deliberate.
`npm install` runs `preinstall`/`install`/`postinstall` lifecycle scripts, and
`pip install` and `uv pip install` take an agent-chosen package or source.
Allowlisted, any of them turns a prompt-injected repository into arbitrary code
execution with the agent's permissions, and the approval prompt is the only
thing standing in the way.

`DEVELOPER_INSTRUCTIONS.md` names these as the correct prefixes to scope *when
you pre-authorize them* — it does not require pre-authorizing them at all. The
default here is to let the prompt do its job, which costs one approval per
session on a workflow that is rarely in the inner loop.

To opt in anyway, on a machine and repository set you trust, merge the block
above into `permissions.allow` yourself:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm ci:*)",
      "Bash(uv sync:*)"
    ]
  }
}
```

Prefer the lockfile-respecting commands (`npm ci`, `uv sync`, `poetry install`)
over the ones that resolve whatever they are handed (`npm install`,
`pip install`, `uv pip install`); they still execute package code, but only the
code your lockfile already pins.

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

## RTK: hook-enforced

Claude Code is RTK's default hook target. `rtk init` installs a PreToolUse hook
that rewrites shell commands to their RTK equivalents before they execute, so
RTK stays active without the agent selecting `rtk` subcommands by hand. This is
the mode [`RTK.md`](../shared/references/agent-runtime/RTK.md) calls
*hook-enforced*.

Install once, per machine:

```bash
./claude/scripts/rtk-install.sh --dry-run   # preview
./claude/scripts/rtk-install.sh             # install + pin
```

[`scripts/rtk-install.sh`](./scripts/rtk-install.sh) does both required steps:
it runs `rtk init -g --hook-only --auto-patch`, then rewrites the hook command
from the bare name `rtk` to an absolute path. The pin is not optional on macOS —
see [Which surfaces this covers](#which-surfaces-this-covers). The script is
idempotent, backs up `settings.json` before editing, preserves your existing
settings, and validates the JSON afterwards when Python 3 is available. If it
finds a hook in a format it does not recognize, it refuses to edit and prints
the line to set by hand.

Equivalent manual steps, if you would rather not run the script:

```bash
rtk init -g --hook-only --auto-patch   # 1. hook + settings.json patch, nothing else
command -v rtk                         # 2. note the absolute path it prints
#    3. edit <agent-home>/settings.json and change the hook's
#       "command": "rtk hook claude"  ->  "command": "<absolute-path> hook claude"
```

Either way, verify with [`scripts/rtk-guard.sh`](./scripts/rtk-guard.sh), which
exits non-zero until the hook is installed, pinned, and free of duplicate RTK.md
guidance. It counts the hook as installed only when `settings.json` carries a
real `hooks.PreToolUse` registration of `rtk hook claude` — rtk writes no hook
script of its own, so nothing else is evidence that Claude Code will invoke it.
The structural check runs through
[`scripts/rtk-hook-probe.py`](./scripts/rtk-hook-probe.py); without Python 3 the
guard falls back to a line-oriented grep that cannot confirm the command sits
under `PreToolUse`.

Use `--hook-only` deliberately. Plain `rtk init -g` additionally writes
`<agent-home>/RTK.md` and adds an `@RTK.md` import to `<agent-home>/CLAUDE.md`,
which puts RTK's upstream command-selection guidance into every session's
context.
Under the hook that guidance is redundant — the hook already performs the
selection — and it overlaps this repo's
[`RTK.md`](../shared/references/agent-runtime/RTK.md), which is the canonical
local policy and carries the raw-command exceptions, the `rtk_proxy.sh`
fallback, and the Go test guidance. `--hook-only` installs the enforcement
without the duplicated instructions.

`--hook-only` also skips the optional filters template at
`~/.config/rtk/filters.toml`; run `rtk config --create` if you want it.

### Which surfaces this covers

The install writes a user-scope `PreToolUse` hook into
`<agent-home>/settings.json`:

```json
{"hooks":{"PreToolUse":[{"matcher":"Bash",
  "hooks":[{"type":"command","command":"rtk hook claude"}]}]}}
```

It therefore applies to any Claude Code surface that reads that settings file
*and* runs its Bash tool on this machine — the terminal CLI and the IDE
extensions. It does not apply to sessions whose tools execute on a remote host
(claude.ai/code and other cloud-run sessions), which have neither this settings
file nor the `rtk` binary.

As installed, `command` is the bare name `rtk`, so the hook resolves it through
the PATH of whatever process spawns it. A shell-launched session inherits the
PATH that made `rtk` available in the first place. A GUI-launched application
frequently does not inherit shell-profile PATH, which puts every common install
location out of reach:

| Install | Path | Typically on GUI PATH? |
| --- | --- | --- |
| Homebrew, Apple Silicon | `/opt/homebrew/bin/rtk` | no |
| Homebrew, Intel Mac | `/usr/local/bin/rtk` | sometimes |
| Cargo | `~/.cargo/bin/rtk` | no |
| Linuxbrew | `/home/linuxbrew/.linuxbrew/bin/rtk` | no |

Apple Silicon Homebrew is the default case for a Mac team and the worst one:
`/opt/homebrew/bin` is added by a shell profile, so a desktop-launched session
will not find `rtk`. The hook then does nothing — it fails silently, with no
error and no rewrites, which reads exactly like RTK working but saving little.
Pinning the absolute path in the hook `command` removes the dependency entirely
and costs nothing on any surface.

Verify per surface rather than assuming: run `command -v rtk` in a session
there, then `git status` followed by `rtk gain --history`, and check the
invocation was recorded.

If a full `rtk init -g` was already run, [`scripts/rtk-guard.sh`](./scripts/rtk-guard.sh)
reports the duplicate artifacts and prints the commands to remove them. It is
report-only and never edits files; it exits non-zero when duplication is
present, so it also works as a setup check.

What this means during a session:

- Write plain commands. `git status`, `go test ./...`, `cat file`, and
  `grep -rn pat .` are rewritten to `rtk git status`, `rtk go test ./...`,
  `rtk read file`, and `rtk grep -rn pat .`.
- Do not hand-translate commands to RTK form to satisfy the selection rules in
  `RTK.md`; the hook already does it. An explicit `rtk ...` command is not an
  error — already-RTK commands pass through unwrapped — but it is redundant.
- An `env VAR=x <cmd>` prefix is preserved; only the inner command is
  rewritten.
- `shared/scripts/rtk_proxy.sh` is not rewritten, so the verbose-command
  fallback in `RTK.md` still behaves as documented.
- `rtk hook check '<command>'` shows how any command would be rewritten,
  without running it.

## Notes

- Local wrapper docs that carry machine-specific or secret-bearing values live
  under `<agent-home>` (for example
  `<agent-home>/POSTGRES_AUDIT.local.md`), never in this repository.
- `<agent-home>/LOCAL-MACHINE.md` is the Claude Code location for the
  machine-local operational notes described in `DEVELOPER_INSTRUCTIONS.md`.
