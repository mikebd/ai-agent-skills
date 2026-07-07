# Code Quality

Purpose: reusable implementation-quality guidance for coding-agent work.

## Trigger semantics

Read and apply this document when planning or implementing:
- non-trivial code changes
- behavior changes
- defect fixes
- refactors of behavior-bearing code
- work where regression risk or contract ambiguity is meaningful

This document does not need to be read for documentation-only edits,
launcher/config-only changes, purely mechanical renames, or cases where
meaningful tests are not practical.

## Planning defaults

When planning implementation work, explicitly consider whether new tests are
valuable before changing code.

Prefer a red/green TDD sequence when behavior is changing, broken, uncertain,
or at risk of regression:
- Red: add or tighten tests that expose the desired behavior, current defect,
  or important risk.
- Green: make the smallest implementation change that satisfies those tests.
- Behavior-lock: preserve important existing behavior with focused regression
  coverage when refactoring or changing adjacent paths.

Do not force test ceremony when it adds little value. For trivial mechanical
edits, docs-only changes, local launcher/config updates, or workflows where
meaningful automated tests are not practical, state why additional tests are
not useful and choose the lightest reasonable validation.

## Test scope

Choose the narrowest test level that gives useful confidence:
- unit tests for local branching, parsing, mapping, formatting, and other
  deterministic logic
- integration or service-level tests for behavior that depends on storage,
  transport, framework wiring, generated code, or cross-component contracts
- behavior-locking tests for existing invariants that should survive refactors

Prefer adding durable regression coverage for defects and contract changes over
one-off manual checks.
