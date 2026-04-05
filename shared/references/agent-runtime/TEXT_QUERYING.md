# Text Querying Cookbook

Last updated: 2026-04-05

## Goal
Fast local inspection, extraction, and transformation of structured, semi-structured, and plain-text files without creating a project unless needed.

Use this guide when the task is reading, searching, filtering, or reshaping local text-like artifacts such as JSON, YAML, TOML, CSV, TSV, logs, config files, and line-oriented exports, including cases that are not full data-analysis tasks.

## Current Footprint (Installed)
- jg, jq, yq
- csvkit, mlr (Miller), qsv, xan
- duckdb, sqlite3
- awk, rg, sed
- python3, uv

## Tool Selection
- Use `jg` for fast path-oriented queries across JSON-family formats, especially when the same query may target JSON, YAML, TOML, JSONL, or STDIN.
- Use `jq` for precise JSON transforms, projections, reductions, and JSON-to-JSON reshaping.
- Use `yq` when the source of truth is YAML and format-preserving YAML handling matters before or after querying.
- Use `csvkit`, `mlr`, `qsv`, or `xan` for tabular text such as CSV and TSV.
- Use `sqlite3` or `duckdb` when joins, window functions, or repeated SQL-style exploration are simpler than shell pipelines.
- Use `awk`, `rg`, and `sed` for plain text, logs, and line-oriented unstructured data.

## Not Currently Recommended
- `trdsql`: deferred for now. It overlaps with `duckdb` for SQL-style local analysis and with `jg`, `jq`, and `yq` for structured-text querying. Prefer `duckdb` for analysis and `jg`/`jq`/`yq` for extraction and shaping. Reconsider if SQL-first querying across small mixed-format files becomes a common workflow.

## JSON / YAML / TOML Patterns
Preview a nested field anywhere in a document:
```bash
jg '**.name' data.json
```

Treat a query as a literal field name at any depth:
```bash
jg --fixed-string service config.yaml
```

Force input format when reading from STDIN:
```bash
cat settings.toml | jg -f toml '**.port'
```

Count matches without printing values:
```bash
jg --count '**.id' data.json
```

Compact JSON-only transform:
```bash
jq -c '.items[] | {id, score}' data.json
```

YAML to JSON plus downstream query:
```bash
yq -o=json '.' config.yaml | jq '.services[] | {name, port}'
```

## Tabular Text Patterns
Inspect schema and summary:
```bash
qsv headers data.csv
qsv stats data.csv
```

Select columns and pretty-print:
```bash
qsv select id,name,score data.csv | qsv table
```

Grouped stats:
```bash
mlr --csv group-by category then stats1 -a mean,p50 -f value data.csv
```

SQL over CSV without importing to a persistent project:
```bash
duckdb -c "SELECT category, avg(value) FROM 'data.csv' GROUP BY 1 ORDER BY 2 DESC;"
```

## Plain Text And Logs
Search with context:
```bash
rg -n -C 2 'timeout|error|failed' logs/
```

Extract fields from line-oriented text:
```bash
awk -F',' '{print $1,$4}' data.csv
```

Targeted rewrite for ad-hoc cleanup:
```bash
sed -n '1,20p' config.env
```

## Composition Patterns
JSON to CSV preview:
```bash
jq -r '.[] | [.id,.name,.score] | @csv' data.json | qsv table
```

YAML to tabular summary:
```bash
yq -o=json '.' config.yaml | jq -r '.services[] | [.name,.port] | @csv' | qsv table
```

Mixed query then SQL:
```bash
jg --compact '**.service' events.yaml | duckdb -c "SELECT count(*) FROM read_json_auto('/dev/stdin');"
```

## Session Guidance
- Start with the narrowest tool that matches the file format and output shape you need.
- Prefer `jg` for cross-format traversal and discovery, then switch to `jq` or SQL when the transformation becomes more exacting.
- Prefer `rg` for unstructured text before building heavier parsing pipelines.
- Prefer writing temporary artifacts to `/tmp` unless persistence is requested.
