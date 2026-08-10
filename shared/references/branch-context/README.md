# Branch Context references

This directory contains the public, agent-neutral reference for Branch Context
(`BC`): branch-scoped persistent context for coding-agent work.

BC helps preserve resumability, decision traceability, navigation, handoffs,
and reproducible investigation context. It is intentionally concise, local,
and self-auditable rather than dependent on external instruction sources.

## Opt-in use

BC is independent of agent runtime guidance. To enable it, explicitly source
[`BRANCH_CONTEXT.md`](./BRANCH_CONTEXT.md) through the same startup/bootstrap
mechanism used for other reusable agent references. A consumer may source
runtime guidance without sourcing BC, in which case BC does not apply.

When BC is sourced, it applies only when a BC root resolves for the working
repository. Otherwise, proceed without BC.

## Working model

BC supports a practical, spec-driven workflow:

1. Capture durable context, constraints, and evidence.
2. Synthesize and approve a plan.
3. Implement, validate, and refine.
4. Record handoff-ready progress and decisions.

A working specification may be a curated set rather than one formal document.
Useful inputs include issue summaries, prior BCs, commit identifiers, exact
reproduction examples, audit findings, screenshots, payloads, logs, and clear
success criteria or non-goals. Keep enough evidence to make a conclusion
reproducible, but do not store secrets.

## Contents

- [`BRANCH_CONTEXT.md`](./BRANCH_CONTEXT.md): canonical behavior, structures,
  and lifecycle rules for agents and maintainers.

## Adoption

Keep the reference itself versioned in this repository. Keep local bootstrap
configuration, absolute paths, and private repository-specific overrides in
the consumer's own private or repository-local configuration.

BC content is non-secret working context. A repository may expose its BC root
as `.context`, including through a worktree symlink. When that root is not
intended to be committed with product code, use:

```gitignore
# Agentic
## Worktrees may link `.context` as a symlink; `.context/` only matches dirs.
/.context
/.context/
```

The first pattern covers the symlink or file-like entry; the second covers a
real directory.
