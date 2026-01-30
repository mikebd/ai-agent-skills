# ai-agent-skills

Agentic workflow utilities and skills.

## Layout

- `codex/skills`: Source-of-truth Codex skills (folders with SKILL.md)
- `codex/packages`: Optional packaged .skill bundles for sharing
- `claude/skills`: Claude-specific skill/prompt formats
- `shared/scripts`: Cross-agent utilities
- `shared/references`: Cross-agent docs and references

## Codex install

Run:

  `./codex/sync-to-codex.sh`

This copies `codex/skills` into `~/.codex/skills`.

## Codex sync back

Run:

  `./codex/sync-from-codex.sh <skill-name>`

The `<skill-name>` parameter is required and must be a simple directory name.

This copies the specified skill: `~/.codex/skills/<skill-name>` into `codex/skills/<skill-name>`.
