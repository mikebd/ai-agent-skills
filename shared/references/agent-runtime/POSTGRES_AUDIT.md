# POSTGRES_AUDIT.md

Purpose: reusable guidance for auditing live Postgres data safely and reproducibly across coding agent sessions.

Use this guide when the task involves auditing a live Postgres database or exporting audit snapshots.

## Safety rules (non-negotiable)
- Live database access is read-only.
- Prefer metadata-first checks before data pulls.
- Keep query volume and result volume minimal unless explicitly approved.
- Use bounded queries by default (`LIMIT`, time window, key-scoped joins).
- Never run DDL/DML (`CREATE`, `ALTER`, `DROP`, `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`).
- Set statement timeout for interactive audits when possible.

## Connection source
- Use a dedicated DB-only env file when available.
- Keep the env file path and default schema only in local wrapper docs (e.g. under `~/.codex`).
- Do not print secrets in chat output.
- Verify required keys exist before connecting: `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, optional `DB_SCHEMA`, `DB_SSL_MODE`.

## Preferred connection command
- Use Docker `psql` client:
  - `docker run --rm --network host -e PGPASSWORD="$DB_PASSWORD" postgres:17 psql "host=$DB_HOST port=$DB_PORT user=$DB_USER dbname=$DB_NAME sslmode=${DB_SSL_MODE:-require}" ...`

## Audit workflow
1. Confirm schema/table visibility with metadata (`to_regclass`, `pg_indexes`, FK map from `pg_constraint`).
2. Start from seed table(s) and gather key IDs.
3. Traverse related tables via FK chains using ID-scoped joins.
4. Keep related-table queries time-bounded when the request requires it.
5. Export once to local snapshot for deep analysis; avoid repeated production scans.

## Snapshot/export workflow
- Snapshot path convention:
  - `.context/<branch>/prod-snapshots/<UTCSTAMP>/`
- Include:
  - seed table export,
  - FK-related table exports,
  - `fk_map.tsv`,
  - `manifest.txt` with row counts/bytes,
  - snapshot metadata (`branch`, `commit_sha`, `commit_timestamp`, `snapshot_generated_at_utc`).
- Preferred format: CSV with header.

## Analysis artifacts
- Save derived analyses beside snapshot data, for example:
  - `temporal_signal_manifest.{md,json}`
  - `temporal_negative_manifest.{md,json}`
- Each analysis artifact should include:
  - scope,
  - input files,
  - exact signal definitions,
  - counts,
  - candidate row IDs.

## Post-snapshot analysis (offline-first)
- After export, perform deeper analysis against local snapshot data when possible.
- Preferred tools and recipes are in `DATA_ANALYSIS.md` (`qsv`, `duckdb`, `uv`, `jq`, `mlr`, etc.).
- Re-query live databases only when a local snapshot cannot answer the question.

## Query design guidance
- Filter on indexed columns where possible.
- Avoid `SELECT *` unless explicitly requested.
- For broad audits, start with aggregate summaries then sample rows.
- When joining large tables, pre-select key IDs in CTEs and join against those IDs.

## Session reporting checklist
- State exactly what was queried.
- State whether any requested tables were absent.
- Report row counts and key IDs, not large raw payloads.
- Confirm no writes were executed.

## Escalation and permissions
- If Docker socket or network access is blocked by sandbox, request escalation.
- Keep escalated commands narrowly scoped to read-only objectives.

## Before/after rerun comparison protocol
Use this when upcoming work may overwrite existing result rows.

1. Capture a **before** snapshot with full exports and manifests.
2. Record immutable context in snapshot metadata:
   - `branch`, `commit_sha`, `commit_timestamp`, `snapshot_generated_at_utc`.
3. Execute reruns.
4. Capture an **after** snapshot in a new timestamped folder.
5. Re-run the same analysis manifests for both snapshots.
6. Compare using stable keys and grouped metrics, not mutable row IDs alone.

### Preferred comparison keys
- Final results: `(run_id, source_data_source_id)`
- Intermediates: `(run_id, source_data_source_id, analysis_kind, group_kind, level, start_date, end_date)`

### Required comparison outputs
- Row-count deltas by table.
- Temporal-signal deltas (same definitions before/after).
- Fallback/non-temporal incidence deltas.
- Empty-result incidence deltas.
- Representative changed examples with IDs and previews.

### Reproducibility rule
- Keep signal definitions and scripts stable between snapshots.
- If definitions must change, produce both:
  - strict apples-to-apples diff with old definitions,
  - new-definition analysis as a separate section.

## Known issue: SQL quoting in inline snapshot scripts
- Common failure: inline SQL with nested shell quoting (especially `coalesce(...,'')`) causing syntax errors.
- Policy: use the known quote-safe `bash` script pattern on the first attempt (do not try ad-hoc quoting variants first).
- Keep summary outputs simple in the same run (`*.txt` scalars, small grouped `*.csv` counts).

### Quote-safe-first pattern
- Use `bash -lc 'set -euo pipefail'` (not `sh`) and helper functions:
  - `run_copy(sql, out)` for `\\copy (...) TO STDOUT WITH CSV HEADER`
  - `run_scalar(sql)` for single-value outputs
- For timestamp bounds in inline `\\copy` SQL, use cast literals only:
  - `'YYYY-MM-DD HH:MM:SS+00'::timestamptz`
  - avoid `TIMESTAMPTZ '...'` form in shell-embedded `\\copy` queries.
- Prefer scalar query shape without embedded empty-string literals when possible:
  - `select max(ar.created_at)::text ...` (instead of `coalesce(max(...)::text,'')`)
- Write scalars to files, then compose `manifest.txt` from those files.
- Keep all queries read-only and anchored to the target seed table IDs.

### First-attempt checklist
1. Use `bash` + `set -euo pipefail`.
2. Source env via `set -a; . <PROJECT_DB_ENV_FILE>; set +a`.
3. Resolve `DBS=${DB_SCHEMA:-<PROJECT_DEFAULT_SCHEMA>}` once.
4. Run exports with `run_copy` and scalars with `run_scalar`.
5. Use SQL-safe window literal variables (for example `WINDOW_START_SQL`,
   `WINDOW_END_SQL`) and reuse them across scoped queries.
6. Avoid nested quote gymnastics inside SQL; prefer simpler SQL forms.
7. Emit `max_analytics_run_created_at.txt` and include a ready-to-use future filter in `manifest.txt`.
