# POSTGRES_AUDIT Local Wrapper (Example)

Purpose: keep machine/project-specific defaults out of git while layering them on top of the shared repo guidance.

Local-only file location (recommended):
- `~/.codex/POSTGRES_AUDIT.local.md`

## Local defaults (do not commit)
- DB env file path: `<PROJECT_DB_ENV_FILE>`
- Default schema fallback: `<PROJECT_DEFAULT_SCHEMA>`
- Optional read-only shim commands in `~/.local/bin`:
  - pipeline DB shim: `<PROJECT_PIPELINE_PSQL_RO_SHIM>`
  - core/platform DB shim: `<PROJECT_CORE_PSQL_RO_SHIM>`

## How to apply during sessions
1. Read this local wrapper first.
2. Then read shared guidance from:
   - `shared/references/agent-runtime/POSTGRES_AUDIT.md`
3. Substitute local defaults into shared placeholders:
   - `<PROJECT_DB_ENV_FILE>`
   - `<PROJECT_DEFAULT_SCHEMA>`
   - `<PROJECT_PIPELINE_PSQL_RO_SHIM>`
   - `<PROJECT_CORE_PSQL_RO_SHIM>`

## Example local values
- Omitted intentionally. Keep all concrete values only in your local `~/.codex/POSTGRES_AUDIT.local.md`.

## Optional local shim policy
- If an applicable shim command is available, use it as the first-choice connection command for snapshot/audit work.
- Keep shim paths machine-local (for example under `~/.local/bin`).
- The shim may delegate to any local read-only wrapper implementation; do not encode that implementation path in shared docs.
- Fall back to the shared Docker `psql` command only when no applicable shim is configured.
