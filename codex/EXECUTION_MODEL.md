# Codex Execution Model Overlay

Read this when the active agent is Codex and
[`DEVELOPER_INSTRUCTIONS.md`](../shared/references/agent-runtime/DEVELOPER_INSTRUCTIONS.md)
calls for constrained execution, elevated execution, a scoped approval, or an
`<agent-home>` path.

Reference resolution rule: treat relative doc paths in this file as
repo-root-relative unless written as an explicit relative link.

## Term mapping

| Neutral term | Codex mechanism |
| --- | --- |
| Constrained execution | The Codex sandbox (filesystem and network restricted per `sandbox_mode`). |
| Elevated execution | Running a command with escalated permissions, outside the sandbox. |
| Scoped approval | A `prefix_rule` approval keyed to a specific argv prefix. |
| `<agent-home>` | `${CODEX_HOME:-~/.codex}` |

## Scoped approvals

Codex expresses a scoped approval as a `prefix_rule` argv array. Translate the
command prefixes named in `DEVELOPER_INSTRUCTIONS.md` directly:

```text
npm install         -> ["npm", "install"]
npm ci              -> ["npm", "ci"]
npm run start       -> ["npm", "run", "start"]
npm test            -> ["npm", "test"]
ng test             -> ["ng", "test"]
npx ng serve        -> ["npx", "ng", "serve"]
npx playwright test -> ["npx", "playwright", "test"]
npx cypress run     -> ["npx", "cypress", "run"]
uv sync             -> ["uv", "sync"]
uv lock             -> ["uv", "lock"]
uv pip install      -> ["uv", "pip", "install"]
pip install         -> ["pip", "install"]
poetry install      -> ["poetry", "install"]
```

Keep each rule as narrow as the workflow allows. Do not widen a rule to a bare
executable (for example `["npm"]`) to avoid a second prompt.

## Which surfaces this covers

The Codex bootstrap in
[`agent-runtime/README.md`](../shared/references/agent-runtime/README.md)
configures `developer_instructions` in `${CODEX_HOME:-~/.codex}/config.toml`.
That key is consumed by the **Codex CLI**. It is not consumed by every surface
that shares the `~/.codex` directory.

Verified 2026-09-02, ChatGPT desktop Codex on Linux x86_64, `rtk 0.45.0`:

| Observation | Result |
| --- | --- |
| Reads `~/.codex` (config.toml, AGENTS.md, skills, rules) | yes |
| `developer_instructions` present in `config.toml` | yes |
| That text reaches the model's instructions | **no** |
| `~/.codex/AGENTS.md` reaches the model's instructions | **no** |
| Knows what RMAR/DOC_MAP.md are, unprompted | **no** |
| Commands execute locally | yes |
| `rtk` on PATH | yes |
| Network reachable | **no** (`curl` returned 000) |
| Approval prompt before running a command block | none |

So on that surface RMAR and BC never activate, and the failure is silent —
identical in shape to an unresolvable RTK hook. Confirm rather than assume,
per surface and per platform, with this probe:

> Without running any commands or reading any files: what does DOC_MAP.md
> govern, and what is RMAR? If you don't know, say "don't know".

An answer of "don't know" means the bootstrap did not reach the agent,
whatever `config.toml` contains.

### Consequences for this overlay

- The term mapping below describes the Codex CLI's sandbox and `prefix_rule`
  approvals. The desktop surface above prompted for nothing and confined writes
  to the workspace while allowing machine-wide reads, so treat that mapping as
  CLI-scoped until verified elsewhere.
- Where network egress is blocked outright rather than gated by approval, the
  "request elevated execution immediately" rules for npm/uv/dev-server
  workflows in
  [`DEVELOPER_INSTRUCTIONS.md`](../shared/references/agent-runtime/DEVELOPER_INSTRUCTIONS.md)
  have nothing to escalate to. Report the block rather than retrying.

### Activating on a surface that ignores `developer_instructions`

Not yet verified. The likely path is a project-level `AGENTS.md` at the root of
the working directory, which is Codex's documented per-project instruction file
and what `rtk init --codex` targets in its non-global mode. An agent-home
`~/.codex/AGENTS.md` was **not** picked up in the test above. Test a
project-level file with the same probe before relying on it.

Use absolute paths in whichever file carries the bootstrap. A `~/` prefix
depends on the reader performing tilde expansion, which is not guaranteed
across surfaces.

## RTK: instruction-enforced

RTK has no Codex hook. `rtk init --codex` writes `$CODEX_HOME/RTK.md` and adds
a reference to `$CODEX_HOME/AGENTS.md`; it does not patch any hook or intercept
commands. Codex is therefore *instruction-enforced* in the sense used by
[`RTK.md`](../shared/references/agent-runtime/RTK.md): the command selection
rules in that document are the only mechanism keeping RTK in use.

Consequences:

- Apply the strict command selection rules deliberately, per command. Nothing
  will rewrite a raw `git status` into `rtk git status`.
- Run the session preflight (`command -v rtk`, then `rtk --version`) rather than
  assuming RTK is active.
- State the reason briefly whenever a raw command is chosen over an RTK-native
  one, so bypasses stay auditable.
- Ignore the hook-oriented subcommands (`cc-economics`, `discover`, `learn`,
  `session`, `hook-audit`); they read Claude Code history and hook telemetry
  that Codex does not produce.

## Notes

- `rtk go test` may run sandboxed by default; see
  [`RTK.md`](../shared/references/agent-runtime/RTK.md) for the cases that
  require elevated execution.
- Git operations listed under "Git Permissions" should request escalation for
  the specific Git command rather than broadening sandbox write access.
- Local wrapper docs that carry machine-specific or secret-bearing values live
  under the agent home (for example `~/.codex/POSTGRES_AUDIT.local.md`), never
  in this repository. Codex honors a `CODEX_HOME` override; resolve the agent
  home as `${CODEX_HOME:-~/.codex}` rather than assuming the default.
