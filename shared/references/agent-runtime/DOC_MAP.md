# RMAR Document Ownership Map

Purpose: single source of truth for what each RMAR document governs.

## Ownership
- [`ACRONYMS.md`](./ACRONYMS.md): stable shorthand for prompting against RMAR and related agent docs.
- [`DATA_ANALYSIS.md`](./DATA_ANALYSIS.md): ad-hoc offline analysis tooling and recipes.
- [`DEVELOPER_INSTRUCTIONS.md`](./DEVELOPER_INSTRUCTIONS.md): startup/runtime behavior contract used by agent config pointers.
- [`POSTGRES_AUDIT.local-wrapper.example.md`](./POSTGRES_AUDIT.local-wrapper.example.md): local/private wrapper template; copy to private config and customize.
- [`POSTGRES_AUDIT.md`](./POSTGRES_AUDIT.md): reusable database-audit safety/workflow/runbook.
- [`RTK.md`](./RTK.md): command-selection and wrapper usage policy for RTK.

## Trigger semantics policy
- Keep [`DEVELOPER_INSTRUCTIONS.md`](./DEVELOPER_INSTRUCTIONS.md) minimal and avoid duplicating task-specific trigger logic already owned by mapped docs.
- Keep global runtime/safety/approval policy in [`DEVELOPER_INSTRUCTIONS.md`](./DEVELOPER_INSTRUCTIONS.md).
- Each mapped RMAR doc must define its own task-specific trigger semantics ("read this when...").
- When adding a new mapped doc, add or verify trigger semantics in that doc instead of expanding [`DEVELOPER_INSTRUCTIONS.md`](./DEVELOPER_INSTRUCTIONS.md).
