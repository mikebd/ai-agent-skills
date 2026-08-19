# Branch Context

Branch Context (`BC`) is optional, branch-scoped persistent working context
for coding-agent workflows. It improves resumability, decision traceability,
durable work decomposition, cross-session continuity, navigation, handoffs,
and reproducible investigation context without requiring every repository or
developer to adopt it.

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
- [Product insulation](#product-insulation)
- [Reading](#reading)
- [Instruction freshness](#instruction-freshness)
- [Writing and lifecycle](#writing-and-lifecycle)
- [Work breakdown structures](#work-breakdown-structures)
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
- `<individual-bc>` is the directory containing the BC files for one shared or
  repository-local scope.
- `<repo-name>` is the canonical repository identity: an explicit override, or
  otherwise the repository root basename. Never derive it from a worktree
  directory name.
- `<work-package-id>` is a stable identifier local to one WBS, written as a
  zero-padded `WP-NNN` value such as `WP-001`.

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

An individual BC may also contain an optional work breakdown structure:

```text
<individual-bc>/WBS.md
```

Do not pre-create `WBS.md`; create it only under the policy in
[Work breakdown structures](#work-breakdown-structures).

## File roles

Use `CONTEXT.md` for durable framing, working agreements, stable assumptions,
and cross-session decisions. Use `STATE.md` for current progress, findings,
handoff notes, next steps, and active status.

Use `WBS.md` for durable deliverable-oriented decomposition, package
relationships, and package status when the work benefits from that structure.
Use `plans/` for approved implementation baselines. Do not duplicate the full
WBS in `STATE.md` or turn the WBS into an implementation-task checklist.

Prefer concise, dated, decision-first notes over diary-style logging. For
material findings, record enough evidence to re-derive the conclusion, such as
identifiers, time windows, exact scripts or commands, source paths, or artifact
references. Record negative findings when they materially affect conclusions.

## Product insulation

BC is a one-way working layer: it may reference product artifacts, but product
artifacts must not reference, link to, or require a BC root, lane, WBS, work
package, or plan. Product source, tests, CI, contracts, configuration,
documentation, runbooks, release artifacts, and ADRs must remain understandable
and usable without BC access. Record durable product decisions and rationale
in the product repository itself, not only in BC.

Product tools may accept caller-provided input or output paths, or equivalent
configuration, that happen to point into BC. Treat those locations as opaque
artifact paths: do not discover, default to, traverse, parse, link to, or
derive product behavior from BC. Product-facing documentation may describe the
generic path or configuration interface, but must not require or prescribe a
BC location. Generic local worktree tooling may also create or repair a
`.context` link as workspace plumbing, provided it does not read BC content or
affect product behavior.

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

When an effective individual BC contains `WBS.md`, read it after `CONTEXT.md`
and `STATE.md` before selecting, planning, or implementing work. Read only the
captured plans relevant to the selected work packages unless broader plan
history is needed.

## Instruction freshness

When an agent edits an instruction document that applies to its current work,
it must reread that document before continuing. The edited instructions take
effect immediately in the current session; do not require a manual reload or
session restart.

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

## Work breakdown structures

A BC work breakdown structure (`WBS`) is an optional, living delivery map for
work that benefits from multiple independently planned or delivered packages,
dependencies, delivery boundaries, or repository scopes. It is a lightweight
software-delivery aid, not a formal project-management system.

Create `WBS.md` only when the user requests it or approves an agent's
recommendation to decompose the work. Do not require a WBS merely because work
may span multiple files or commits; keep straightforward work in the normal
BC files and approved plans.

Keep at most one canonical `WBS.md` per individual BC. Put cross-repository
decomposition at the shared scope and repository-specific decomposition at the
repository-local scope. Link related packages across scopes rather than
duplicating ownership of the same work.

### Work packages

Describe deliverables rather than low-level implementation tasks. Assign each
work package the next sequential `<work-package-id>` and never renumber or
reuse an existing identifier. Each package records:

- Outcome and acceptance criteria.
- `Parent`, or `none`.
- `Depends on`, or `none`.
- Status: `planned`, `in progress`, `blocked`, `complete`, `deferred`,
  `cancelled`, or `superseded`.
- Links to associated plans, or `none` until plans exist.
- Scope, delivery boundary, or lineage when it is not otherwise clear.

Use a flat WBS by default. Add parent-child relationships when they improve
decomposition or rollup. Explicit `Parent` fields are authoritative. When any
parent-child relationships exist, maintain a concise hierarchy tree as a
secondary view and update it in the same change as the package records.

Hierarchy does not imply delivery order. Record ordering constraints through
explicit `Depends on` fields; package numbering and document order imply
neither dependency nor priority. Packages without unmet dependencies may
proceed in parallel. An optional sequence or delivery-wave view may summarize
the dependency graph, but the package fields remain authoritative.

Treat non-leaf packages as rollups and normally plan actionable leaf packages.
A parent is complete only when its required children and its own acceptance
criteria are complete.

### Lifecycle and lineage

Keep the WBS current as delivery proceeds. Update package status directly and
append concise dated history for material additions, splits, transfers,
cancellations, acceptance changes, or dependency changes. Preserve the prior
identifiers and relationships needed to reconstruct those changes. Use
`STATE.md` for the current focus and handoff rather than copying the WBS.

Use lineage relationships for structural changes; do not use `split` or
`transferred` as execution statuses:

- A transfer moves the selected package's remaining scope to another BC. It
  does not imply moving any other non-terminal packages. Mark the source
  `superseded`. If the destination has or independently warrants a WBS, assign
  the receiving package its own local identifier and add reciprocal
  `Transferred to` and `Transferred from` links. Otherwise, link the source
  package to the destination BC's customary `CONTEXT.md` or `STATE.md` and
  record the source lineage there. Do not create a destination WBS solely to
  receive a transfer.
- A full split partitions one package into multiple successors. Mark the
  source `superseded` and add reciprocal `Split to` and `Split from` links.
- A partial split extracts only part of a package. Keep the source active,
  revise its remaining outcome and acceptance criteria, record the dated scope
  change, and link each extracted successor with reciprocal split links.

Work-package identifiers are local to their WBS, so cross-BC lineage identifies
the other BC and its local package when one exists. Ensure that transferred
scope has only one authoritative active location.

### Plans, runtime tools, and commits

A work package may require multiple plans, and one plan may advance multiple
tightly coupled packages. Link both directions when practical. Plan numbering
remains chronological and independent of work-package identifiers. Completing
a plan does not complete a package unless the package's acceptance criteria
are satisfied.

WBS work packages are durable BC concepts, distinct from agent runtime goals,
tasks, checklists, and tool-managed plans. An agent may project a selected
package into runtime tooling and derive temporary tasks from approved plans,
but runtime state does not replace or automatically synchronize with
`WBS.md`.

Treat package and plan delivery boundaries as guidance for atomic commits, not
as mandatory one-to-one mappings. A package may span multiple product commits,
and a tightly coupled commit may advance multiple packages. BC may record
product commit identifiers as delivery evidence; product commit messages must
not depend on BC or work-package identifiers.

## Plan capture

Unless the resolved BC explicitly overrides this policy, capture only
decision-complete plans created in explicit Plan Mode and approved for
implementation. Capture an approved plan automatically on the first
subsequent turn that permits writes, before implementation or other changes;
do not wait for a separate capture request. Do not capture implicit planning
performed during ordinary agent execution. This capture policy applies only
when an effective individual BC is already in use for the work. If no current
BC is in use, explicit Plan Mode and plan approval proceed without creating or
selecting a BC just to store the plan.

The lane does not affect capture eligibility. When the effective individual BC
is in `_done`, capture an approved review or follow-up plan there rather than
moving the BC back to `_active` solely to store the plan. This preserves a
stable done-lane path for links from the related pull request and other
references.

When an approved explicit plan creates a new BC, do not create a `plans/`
directory or consume `plans/001-...` in that new BC merely to capture the
plan. Create only the customary `CONTEXT.md` and `STATE.md`, plus any unique
artifacts called for by the approved plan, which may include an approved
`WBS.md`. If a different effective BC was already in use when the plan was
approved, capture the plan in that originating BC as usual.

Store plans inside the individual BC, never at the BC root:

```text
<individual-bc>/plans/001-brief-slug.md
```

Use a sequential, zero-padded number beginning at `001`; determine the next
number from existing plan files and do not renumber prior plans.

When a WBS exists, identify the work packages advanced by each plan and link
the plan from those package records. The relationship is many-to-many; neither
a plan nor a package must have a one-to-one counterpart.

### Plan lifecycle and amendments

A captured plan may be rewritten while it is being groomed and before its
implementation begins. When implementation begins, its substantive content is
the frozen baseline that governed the work. Do not rewrite that baseline to
make the plan appear to have anticipated later facts, decisions, or outcomes.
Substantive content includes the goal, decisions, scope, boundaries,
implementation approach, and acceptance criteria.

This lifecycle applies to captured `plans/` records only. It does not freeze a
living WBS, prescribe the contents of a new BC, or add plan-capture artifacts
to a new BC created by a plan.

After the baseline freezes:

- A compact current status field may change. Record implementation start,
  completion, abandonment, and other material lifecycle transitions in dated
  entries so the history remains reconstructable.
- Correct typos, formatting, and broken paths or links in the frozen content
  only when the edit does not change meaning. Append a dated maintenance note
  identifying the repair.
- Append a dated amendment when a stale assertion, assumption, or decision
  needs current clarification. State what changed and why, preserve the
  original content, and distinguish the historical implementation baseline
  from the guidance that applies to future work.
- An explicitly approved amendment may authorize a minor corrective follow-up
  only when it preserves the original goal and does not change architecture,
  public or private APIs, schemas, migrations, security boundaries,
  authorization boundaries, or other material commitments. The amendment's
  substantive content freezes when its implementation begins.
- Capture any material new outcome, boundary change, or independently useful
  follow-up as the next sequential approved plan rather than extending the
  frozen plan.

When applying this lifecycle to a plan already marked implemented, treat its
last committed implemented form as the frozen baseline. If no such version is
available, use the last reliably recorded form known to have governed the
implementation. Do not reconstruct earlier history by default.

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
