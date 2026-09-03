# RMAR Document Ownership Map

Purpose: single source of truth for what each RMAR document governs.

## Ownership
- [`ACRONYMS.md`](./ACRONYMS.md): stable shorthand for prompting against RMAR and related agent docs.
- [`AI_AGENT_LAUNCHER.md`](./AI_AGENT_LAUNCHER.md): AI coding-agent launcher source resolution, command selection, diagnostics, and completion for agent, launcher, session, and worktree tasks.
- [`CODE_QUALITY.md`](./CODE_QUALITY.md): implementation planning quality defaults, TDD/red-green workflow, behavior-locking tests, and practical test-scope decisions.
- [`DATA_ANALYSIS.md`](./DATA_ANALYSIS.md): ad-hoc offline EDA, statistics, and visualization workflows.
- [`DEVELOPER_INSTRUCTIONS.md`](./DEVELOPER_INSTRUCTIONS.md): agent-neutral startup/runtime behavior contract used by agent config pointers.
- [`POSTGRES_AUDIT.local-wrapper.example.md`](./POSTGRES_AUDIT.local-wrapper.example.md): local/private wrapper template; copy to private config and customize.
- [`POSTGRES_AUDIT.md`](./POSTGRES_AUDIT.md): reusable database-audit safety/workflow/runbook.
- [`RTK.md`](./RTK.md): command-selection and wrapper usage policy for RTK.
- [`TEXT_QUERYING.md`](./TEXT_QUERYING.md): local querying, extraction, and reshaping of structured, semi-structured, and plain-text files.

## Execution model overlays
Agent-specific mechanics (approval syntax, agent-home paths, sandbox behavior)
live in a per-agent overlay, not in [`DEVELOPER_INSTRUCTIONS.md`](./DEVELOPER_INSTRUCTIONS.md).
Read the overlay for the active agent alongside it.

- [`codex/EXECUTION_MODEL.md`](../../../codex/EXECUTION_MODEL.md): Codex sandbox/escalation model and `prefix_rule` approvals.
- [`claude/EXECUTION_MODEL.md`](../../../claude/EXECUTION_MODEL.md): Claude Code permission-rule model and `settings.json` approvals.

When adding support for another agent, add an overlay here rather than
introducing agent-specific wording into a shared doc.

## Trigger semantics policy
- Keep [`DEVELOPER_INSTRUCTIONS.md`](./DEVELOPER_INSTRUCTIONS.md) minimal and avoid duplicating task-specific trigger logic already owned by mapped docs.
- Keep global runtime/safety/approval policy in [`DEVELOPER_INSTRUCTIONS.md`](./DEVELOPER_INSTRUCTIONS.md).
- Each mapped RMAR doc must define its own task-specific trigger semantics ("read this when...").
- When adding a new mapped doc, add or verify trigger semantics in that doc instead of expanding [`DEVELOPER_INSTRUCTIONS.md`](./DEVELOPER_INSTRUCTIONS.md).
- Keep agent-specific mechanics out of mapped RMAR docs; put them in the execution model overlay for that agent.
