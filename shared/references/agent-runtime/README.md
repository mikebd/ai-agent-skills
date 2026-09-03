# Agent Runtime References

This directory contains reusable, non-secret runtime guidance that can be adapted to different AI coding agents.

## What this directory is for

Use this directory as a versioned source of truth for:

- startup/runtime instructions
- command wrapper conventions
- domain-specific runbooks (for example database audits or analysis workflows)

The general pattern is:

1. Keep reusable guidance in repo-managed docs (this folder).
2. Keep local agent-home config thin, pointing to those docs.
3. Keep machine-local/private values out of repo files.

## Doc ownership

See [`DOC_MAP.md`](./DOC_MAP.md) for the single-source ownership map of RMAR
documents and the per-agent execution model overlays.

## Agent-agnostic adaptation

[`DEVELOPER_INSTRUCTIONS.md`](./DEVELOPER_INSTRUCTIONS.md) is agent-neutral. It
describes execution in terms of *constrained execution*, *elevated execution*,
*scoped approval*, and `<agent-home>`; a per-agent execution model overlay maps
those onto real mechanisms. Supported overlays today:

- [`codex/EXECUTION_MODEL.md`](../../../codex/EXECUTION_MODEL.md)
- [`claude/EXECUTION_MODEL.md`](../../../claude/EXECUTION_MODEL.md)

To add another agent:

- configure that agent's startup/system instruction hook to reference
  [`DEVELOPER_INSTRUCTIONS.md`](./DEVELOPER_INSTRUCTIONS.md) plus a new
  execution model overlay
- keep wrapper/tool guidance in a separate reference doc
- add local-only wrapper docs where secrets or machine-specific defaults are required

## Example: Codex bootstrap via `~/.codex/config.toml`

1. Clone this repo locally.
2. Add (or update) `developer_instructions` in `~/.codex/config.toml`:

```toml
developer_instructions = """
At session start, read /ABS/PATH/TO/ai-agent-skills/shared/references/agent-runtime/DEVELOPER_INSTRUCTIONS.md and /ABS/PATH/TO/ai-agent-skills/codex/EXECUTION_MODEL.md before running commands.
"""
```

Replace `/ABS/PATH/TO/ai-agent-skills` with your local clone path.

For Codex specifically, you should also see startup behavior follow the configured `developer_instructions` entrypoint.


## Example: Claude Code bootstrap via `~/.claude/CLAUDE.md`

1. Clone this repo locally.
2. Copy [`claude/CLAUDE.md.example`](../../../claude/CLAUDE.md.example) to
   `~/.claude/CLAUDE.md`, or merge its contents into an existing one:

```markdown
@/ABS/PATH/TO/ai-agent-skills/shared/references/agent-runtime/DEVELOPER_INSTRUCTIONS.md
@/ABS/PATH/TO/ai-agent-skills/claude/EXECUTION_MODEL.md
```

3. Replace `/ABS/PATH/TO/ai-agent-skills` with your local clone path.

`@`-prefixed lines are imports: Claude Code inlines those files into the
session at startup, so the runtime contract is in context deterministically. If
you would rather have them read on demand,
[`claude/CLAUDE.md.pointer.example`](../../../claude/CLAUDE.md.pointer.example)
uses plain instruction lines instead.

Optionally merge
[`claude/settings.json.example`](../../../claude/settings.json.example) into
`~/.claude/settings.json` to pre-authorize the command prefixes the runtime
contract expects, rather than approving them one prompt at a time.
