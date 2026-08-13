# Branch Context references

This directory contains the public, agent-neutral reference for Branch Context
(`BC`): branch-scoped persistent context for coding-agent work.

BC organizes working memory by branch and lane so long-running work does not
collapse into an undifferentiated scratch space. It supports resumability,
decision traceability, navigation, handoffs, and reproducible investigation,
audit, and design reasoning.

## Contents

- [`BRANCH_CONTEXT.md`](./BRANCH_CONTEXT.md): canonical agent behavior,
  structures, and lifecycle rules.

## Design philosophy

BC is intentionally concise, local, and self-auditable. External material can
be useful background, but it is not a normative dependency. This reduces drift
and the review and security risk of importing large opaque instruction sets.

BC is useful for solo development, durable shared reference material,
collaboration across developers or hosts, and multi-repository work that shares
one branch identity. BC may link to durable product documentation and preserve
the working decision or audit trail behind it. Product artifacts do not link
back to or depend on BC; durable product rationale remains in the product
repository itself.

## Opt-in bootstrap

BC is independent of agent runtime guidance. A consumer explicitly enables it
by sourcing [`BRANCH_CONTEXT.md`](./BRANCH_CONTEXT.md) through its normal agent
startup/bootstrap mechanism. A consumer may source runtime guidance without
sourcing BC, in which case BC does not apply.

When BC is sourced, it applies only when a BC root resolves for the working
repository. Otherwise, proceed without BC.

For Codex, add a BC source line to `developer_instructions` in
`~/.codex/config.toml`. If both runtime guidance and BC are wanted, their
independent source lines share the same configuration value:

```toml
developer_instructions = """
At session start, read /ABS/PATH/TO/ai-agent-skills/shared/references/agent-runtime/DEVELOPER_INSTRUCTIONS.md before running commands.
At session start, read /ABS/PATH/TO/ai-agent-skills/shared/references/branch-context/BRANCH_CONTEXT.md before running commands.
"""
```

Replace `/ABS/PATH/TO/ai-agent-skills` with the local clone path. Omit the
runtime line when BC is the only reference in use. The runtime reference does
not import or index BC; each consumer must explicitly source BC when wanted.

## Effective workflow

A practical BC-driven workflow is:

1. Gather durable context, constraints, and evidence into BC.
2. Synthesize and approve a plan from that context.
3. Execute the work breakdown.
4. Test, validate, and refine.
5. Review and hand off with current state and decisions recorded.

Use deliberate reasoning for planning, architecture, ambiguous cross-session
synthesis, review, and debugging. Routine execution can use a more efficient
default once the plan and constraints are clear.

## Effective specification inputs

Spec-driven development does not require a single formal specification. A
reliable curated set of inputs can define the problem, constraints, evidence,
and intended outcome.

Useful inputs include:

- Product or design documents, diagrams, and data models.
- Prior BCs, issue summaries, and exact identifiers or URLs.
- Relevant commit identifiers and change history.
- Reproduction examples, audit results, and incident timelines.
- Screenshots, payloads, logs, and query outputs.
- Clear success criteria and non-goals.

This working set should make the work reproducible without placing secrets in
BC.

## Root options

The lowest-friction solo pattern is a repository-local `.context` root. If it
is not intended to be committed with product code and worktrees may expose it
as a symlink, use this root-anchored `.gitignore` pattern:

```gitignore
# Agentic
## Worktrees may link `.context` as a symlink; `.context/` only matches dirs.
/.context
/.context/
```

The first pattern covers the symlink or file-like entry; the second covers a
real directory. Worktree use is an individual developer opt-in, not a
team-wide requirement.

An optional advanced pattern is a sibling BC root:

```text
<repository-parent>/<repository-name>-context
```

It provides clearer separation from product contents, avoids nested-repository
and symlink-specific friction, and can be a cleaner base for advanced solo or
shared work. It is more bootstrap-dependent, normally requires explicit tool
access to the external root, and is less convenient than a repository-local
`.context`.

## Shared BC and local paths

Shared BC should use canonical repository identities that are developer-neutral
by default. When a workflow genuinely needs machine-specific repository paths,
keep the mapping private and key it by a stable local identity such as lowercase
`<user>@<short-hostname>`:

```yaml
repo_path_overrides:
  developer@workstation:
    repository-name: /workspace/repository-name
```

Use host-specific path overrides only when the workflow needs a local path;
they are not part of the canonical BC identity.

If a BC root is versioned separately, choose durable storage branch names that
do not collide with other users' BC branches. Treat those storage branches as
long-lived context history, not branches that must merge with product work or
with each other. Use a team- or project-oriented name for shared BC storage.

## Validation and environment audits

BC works well for post-deployment validation and long-running environment audit
work across development, staging, and production environments. Useful sources
include logs, metrics, database audits, infrastructure state, and deployment
metadata.

For an audit workflow:

1. Capture validation scope and signal definitions in BC.
2. Store reusable scripts and command patterns at stable paths.
3. Record deployment boundaries and findings per environment.
4. Track follow-up checks and longitudinal validation in the same BC.

Large artifacts follow the compression and streaming-read rules in
[`BRANCH_CONTEXT.md`](./BRANCH_CONTEXT.md#methods-and-artifacts).

## Solo and shared collaboration

Solo BC work may use lightweight, batched commits when that improves flow. For
shared BC work, push more frequently, favor append-oriented updates where
practical, avoid repeatedly rewriting shared summary blocks, keep most detail
in repository-local files, and reserve shared branch files for genuinely shared
conclusions and coordination.

BC commit hygiene can be lighter than product-code hygiene, but structure and
clear ownership matter more when multiple writers are active.
