# Branch Context

Branch Context (`BC`) is optional, branch-scoped persistent working context
for coding-agent workflows. It improves resumability, decision traceability,
cross-session continuity, navigation, handoffs, and reproducible investigation
context without requiring every repository or developer to adopt it.

## When to use this reference

Read and follow this reference only when the active agent bootstrap explicitly
sources it. BC is intentionally separate from general agent runtime guidance:
consumers opt in through their normal startup/bootstrap mechanism, and may use
runtime guidance without enabling BC.

When this reference is sourced, BC is enabled only if a root resolves for the
working repository. If no root resolves, proceed normally without BC.

## Quick index

- [Root resolution](#root-resolution)
- [Terms and paths](#terms-and-paths)
- [Lane model](#lane-model)
- [Structure](#structure)
- [File roles](#file-roles)
- [Reading](#reading)
- [Writing and lifecycle](#writing-and-lifecycle)
- [Plan capture](#plan-capture)
- [Methods and artifacts](#methods-and-artifacts)
- [Links and commits](#links-and-commits)

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
- `<lane>` is the BC lane that contains branch-scoped context.
- `<repo-name>` is the canonical repository identity: an explicit override, or
  otherwise the repository root basename. Never derive it from a worktree
  directory name.

## Lane model

All lane-managed BC content lives under a lane. Do not store lane-managed
content outside lanes, and do not pre-create lanes a repository does not need.

Workflow-state lanes:

- `_active`: current work in progress.
- `_done`: completed work retained for handoff and later reference.
- `_todo`: planned work not yet active.
- `_hold`: work paused for an external input or dependency.
- `_deferred`: intentionally postponed, lower-priority work.
- `_idea`: speculative proposals not ready for committed work.
- `_research`: exploratory investigation.
- `_rejected`: considered work that is not proceeding.

Persistent non-workflow lanes:

- `__audit`: ongoing system health, periodic checks, and operational audits.
- `__review`: review work on other developers' branches.
- `__util`: reusable utilities, stable reference material, and long-lived
  content that does not fit a workflow-state lane.
- Other double-underscore persistent lanes may be added when a durable purpose
  warrants them.

Use semantic lane names in prompts and interpretation (`active`, `done`,
`audit`, `review`, and so on); the underscore-prefixed directory names are
implementation details.

Persistent lanes are intentionally longer-lived than workflow-state lanes. A
BC may be promoted into one when stable scripts, outputs, recurring audits,
recurring review work, reusable utilities, or other durable reference material
matter more than its transient workflow state. Treat the promoted lane as the
canonical location unless the user explicitly requests another transition.

## Structure

For a single repository, the usual active BC is:

```text
<bc-root>/_active/<branch-path>/CONTEXT.md
<bc-root>/_active/<branch-path>/STATE.md
```

For shared multi-repository work, use a shared branch layer:

```text
<bc-root>/<lane>/<branch-path>/CONTEXT.md
<bc-root>/<lane>/<branch-path>/STATE.md
```

Nest each repository-local layer beneath it:

```text
<bc-root>/<lane>/<branch-path>/<repo-name>/CONTEXT.md
<bc-root>/<lane>/<branch-path>/<repo-name>/STATE.md
```

Shared files carry cross-repository goals, coordination, and conclusions.
Repository-local files carry concrete implementation constraints, findings,
audit detail, and progress. The default shared-work assumption is that
participating repositories use the same `<branch-path>`; different branch
names are an advanced, explicitly managed case.

## File roles

Use `CONTEXT.md` for durable framing, working agreements, stable assumptions,
and cross-session decisions. Use `STATE.md` for current progress, findings,
handoff notes, next steps, and active status.

Prefer concise, dated, decision-first notes over diary-style logging. For
material findings, record enough evidence to re-derive the conclusion, such as
identifiers, time windows, exact scripts or commands, source paths, or artifact
references. Record negative findings when they materially affect conclusions.

## Reading

When reading shared multi-repository BC:

1. Resolve `<branch-path>`.
2. Read shared `CONTEXT.md` and `STATE.md` first when present.
3. Read repository-local `CONTEXT.md` and `STATE.md` for `<repo-name>` when
   present.

If no active BC exists, search fallback lanes in this order: `__audit`,
`__review`, `_todo`, `_hold`, `_deferred`, `_research`, `_idea`, `_done`, and
`_rejected`. Within a lane, prefer shared files, then repository-local files.
Inspect other files under the resolved BC path only when they are relevant to
the task.

## Writing and lifecycle

Write to the active lane by default. Update shared branch files only when the
user explicitly requests a shared or cross-repository change. Create missing
branch and repository directories as needed, but do not infer lane transitions.

Treat requests to create or capture a BC as requests for a new BC artifact or
path by default, rather than an update to an existing lane copy. Keep at most
one canonical copy of a `CONTEXT.md` or `STATE.md` for a given lane, branch,
and repository scope.

When transitioning lanes, move rather than copy unless the user requests
otherwise, preserve the `<branch-path>` suffix, and update self-references in
the moved content, including script paths and examples. Do not rewrite
historical records that intentionally describe the original move.

## Plan capture

Unless the resolved BC explicitly overrides this policy, capture only
decision-complete plans created in explicit Plan Mode and approved for
implementation. Do not capture implicit planning performed during ordinary
agent execution.

Store plans inside the individual BC, never at the BC root:

```text
<individual-bc>/plans/001-brief-slug.md
```

Use a sequential, zero-padded number beginning at `001`; determine the next
number from existing plan files and do not renumber prior plans. A follow-up or
evaluation that belongs to the same approved plan remains with that plan unless
the user explicitly requests a distinct plan.

## Methods and artifacts

When a workflow repeats, preserve its method as well as its outputs. This can
include reusable scripts, stable command patterns, manifests, and signal
definitions. Keep bulky raw artifacts repository-local by default, and reserve
shared branch files for genuinely shared conclusions and coordination.

Compress large BC log or audit exports in place. Read them with gzip-aware
tools such as `zcat`, `gunzip -c`, or `jq <(gunzip -c ...)` rather than assuming
plain-text or uncompressed JSON inputs. Small control and summary artifacts do
not need compression by default.

## Links and commits

Preserve reciprocal `Prev BC` and `Next BC` links when a BC chain matters for
later reconstruction. Use relative Markdown links in `CONTEXT.md` or
`STATE.md`, target a navigable document in the neighboring lane, and update
those links when moving a BC. Do not use filesystem symlinks or pointer files
for BC navigation.

BC commit hygiene can be lighter than product-code commit hygiene, especially
for solo work. When the BC root is its own Git repository, use
`git -C <bc-root> ...` for BC operations and keep BC commits separate from
product-code commits unless the user explicitly requests otherwise.
