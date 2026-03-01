# ai-agent-skills

Agentic workflow utilities and skills.

## Layout

- `codex/skills`: Source-of-truth Codex skills (folders with SKILL.md)
- `codex/packages`: Optional packaged .skill bundles for sharing
- `claude/skills`: Claude-specific skill/prompt formats
- `shared/scripts`: Cross-agent utilities
- `shared/references`: Cross-agent docs and references
- `shared/references/agent-runtime`: Shared runtime guidance/docs reusable across agents

## Codex install

Run:

  `./codex/sync-to-codex.sh`

This copies `codex/skills` into `~/.codex/skills`.

## Codex sync back

Run:

  `./codex/sync-from-codex.sh <skill-name>`

The `<skill-name>` parameter is required and must be a simple directory name.

This copies the specified skill: `~/.codex/skills/<skill-name>` into `codex/skills/<skill-name>`.

## Agent Runtime Staging

`shared/references/agent-runtime` is where reusable non-secret runtime material is staged so local agent-home files can later be replaced by lightweight pointers/references.

Keep in `~/.codex` only machine-local/private state (tokens, local overrides, history, sqlite/session state).
For docs that need local defaults (for example env file paths or default DB schema), keep placeholders in repo docs and provide local wrappers in `~/.codex` (see `POSTGRES_AUDIT.local-wrapper.example.md`).
