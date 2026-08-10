# Branch Context

Branch Context (`BC`) is optional, branch-scoped persistent working context
for coding-agent workflows. It supports resumability, decision traceability,
handoffs, and durable investigation context without requiring every repository
or developer to adopt it.

## When to use this reference

Read and follow this reference only when the active agent bootstrap explicitly
sources it. BC is intentionally separate from general agent runtime guidance:
consumers opt in through their normal startup/bootstrap mechanism, and may use
runtime guidance without enabling BC.

When this reference is sourced, BC is enabled only if a root resolves for the
working repository. If no root resolves, proceed normally without BC.

## Root resolution

Resolve the BC root in this order:

1. Explicit runtime override.
2. Bootstrap or developer-instruction override.
3. Repository-local `.context`.
4. Otherwise, BC is unresolved and disabled.

An override may be absolute or relative to the main repository root. If
`.context` is a symlink, access must include the resolved target, not only the
link path.

## Terms and paths

- `<branch-path>` is the exact output of `git branch --show-current`, including
  slashes.
- `<lane>` is the BC lane that contains the branch context.
- `<repo-name>` is the canonical repository identity: an explicit override, or
  otherwise the repository root basename. Never derive it from a worktree
  directory name.

All lane-managed content lives under a lane. The standard workflow lanes are
`_active`, `_done`, `_todo`, `_hold`, `_deferred`, `_idea`, `_research`, and
`_rejected`. Persistent lanes include `__audit`, `__review`, and `__util`;
additional double-underscore persistent lanes may be added when needed. Do not
pre-create lanes that the repository does not need.

Use semantic lane names in conversation (`active`, `done`, `audit`, and so on);
the underscore-prefixed directory names are implementation details.

## Structure

For a single repository, the usual active BC is:

```text
<bc-root>/_active/<branch-path>/CONTEXT.md
<bc-root>/_active/<branch-path>/STATE.md
```

For shared multi-repository work, the shared branch layer is:

```text
<bc-root>/<lane>/<branch-path>/CONTEXT.md
<bc-root>/<lane>/<branch-path>/STATE.md
```

The repository-local layer is nested beneath it:

```text
<bc-root>/<lane>/<branch-path>/<repo-name>/CONTEXT.md
<bc-root>/<lane>/<branch-path>/<repo-name>/STATE.md
```

Use the shared layer for cross-repository goals, coordination, and conclusions;
use the repository-local layer for concrete implementation findings and status.

`CONTEXT.md` records durable framing, working agreements, and stable decisions.
`STATE.md` records current progress, findings, handoff notes, and next steps.
Keep both concise, decision-first, evidence-backed, and non-secret.

## Plan capture

Unless the resolved BC explicitly overrides this policy, capture only
decision-complete plans that were created in explicit Plan Mode and approved
for implementation. Do not capture implicit planning performed during ordinary
agent execution.

Store plans inside the individual BC, never at the BC root:

```text
<individual-bc>/plans/001-brief-slug.md
```

Use a sequential, zero-padded number beginning at `001`; determine the next
number from existing plan files and do not renumber prior plans. A follow-up or
evaluation that belongs to the same approved plan remains with that plan unless
the user explicitly requests a distinct plan.

## Reading and writing

When reading a shared multi-repository BC, read shared `CONTEXT.md` and
`STATE.md` first, then repository-local files when present. If no active BC is
available, look in this order: `__audit`, `__review`, `_todo`, `_hold`,
`_deferred`, `_research`, `_idea`, `_done`, `_rejected`.

Write to the active lane by default. Update the shared layer only when the
user explicitly requests a shared or cross-repository change. Create missing
branch and repository directories as needed, but do not infer lane transitions.
When transitioning lanes, move rather than copy unless the user requests
otherwise, and preserve the `<branch-path>` suffix. After a move, update
self-references in the moved BC content, including script paths and examples,
to its new lane path; do not rewrite historical records that intentionally
describe the original move.

Treat requests to create or capture a BC as requests for a new BC artifact by
default, rather than updates to an existing lane copy. Keep one canonical copy
of a `CONTEXT.md` or `STATE.md` for a given lane, branch, and repository scope.

## Evidence, links, and commits

For material findings, record enough evidence to re-derive the conclusion,
such as identifiers, time windows, commands, source paths, or artifact
references. Preserve material negative findings. Store reusable methods as
well as their outputs; keep bulky raw artifacts repository-local by default.

Compress large BC log exports in place. Read them with gzip-aware tools such as
`zcat`, `gunzip -c`, or `jq <(gunzip -c ...)` rather than assuming plain-text
or uncompressed JSON inputs.

Use relative Markdown links for `Prev BC` and `Next BC` relationships so
repository browsers can follow them. Target a navigable document in the
neighboring lane, and update those links when moving a BC. Do not use
filesystem symlinks or pointer files for BC navigation.

When the BC root is its own Git repository, use `git -C <bc-root> ...` for BC
operations. Keep BC commits separate from product-code commits unless the user
explicitly requests otherwise.
