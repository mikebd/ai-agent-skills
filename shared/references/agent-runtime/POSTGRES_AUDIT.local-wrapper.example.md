# POSTGRES_AUDIT Local Wrapper (Example)

Purpose: keep machine/project-specific defaults out of git while layering them on top of the shared repo guidance.

Local-only file location (recommended):
- `~/.codex/POSTGRES_AUDIT.local.md`

## Local defaults (do not commit)
- DB env file path: `<PROJECT_DB_ENV_FILE>`
- Default schema fallback: `<PROJECT_DEFAULT_SCHEMA>`

## How to apply during sessions
1. Read this local wrapper first.
2. Then read shared guidance from:
   - `shared/references/agent-runtime/POSTGRES_AUDIT.md`
3. Substitute local defaults into shared placeholders:
   - `<PROJECT_DB_ENV_FILE>`
   - `<PROJECT_DEFAULT_SCHEMA>`

## Example local values
- Omitted intentionally. Keep all concrete values only in your local `~/.codex/POSTGRES_AUDIT.local.md`.
