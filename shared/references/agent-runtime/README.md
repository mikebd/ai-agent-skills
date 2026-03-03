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

See [`DOC_MAP.md`](./DOC_MAP.md) for the single-source ownership map of RMAR documents.

## Agent-agnostic adaptation

If you use a different agent, adapt the same model:

- configure that agent's startup/system instruction hook to reference a repo-managed runtime doc
- keep wrapper/tool guidance in a separate reference doc
- add local-only wrapper docs where secrets or machine-specific defaults are required

## Example: Codex bootstrap via `~/.codex/config.toml`

1. Clone this repo locally.
2. Add (or update) `developer_instructions` in `~/.codex/config.toml`:

```toml
developer_instructions = """
At session start, read /ABS/PATH/TO/ai-agent-skills/shared/references/agent-runtime/DEVELOPER_INSTRUCTIONS.md before running commands.
"""
```

Replace `/ABS/PATH/TO/ai-agent-skills` with your local clone path.

For Codex specifically, you should also see startup behavior follow the configured `developer_instructions` entrypoint.
