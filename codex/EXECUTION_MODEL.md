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
