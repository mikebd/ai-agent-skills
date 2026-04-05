# Data Analysis Cookbook

Last updated: 2026-04-05

## Goal
Fast ad-hoc EDA, statistics, and visualization workflows without creating a project unless needed.

Use this guide when the task is exploratory analysis, statistics, or visualization over local/exported data.

For format-specific extraction, querying, and reshaping workflows that also apply outside analysis tasks, use `TEXT_QUERYING.md`.

## Current Footprint (Installed)
- visidata
- duckdb, sqlite3
- gnuplot, graphviz (dot)
- python3, uv
- R, Rscript
- parallel
- Querying and text-shaping tools from `TEXT_QUERYING.md` (`csvkit`, `jg`, `jq`, `mlr`, `qsv`, `rg`, `xan`, `yq`, etc.)

## Adjacent Tools Worth Adding (Optional)
- radian: better interactive R REPL experience.
- jupyterlab (via uv tool): notebook workflow when needed.

## Project-less Python with uv (canonical)
Interpreter rule:
- Outside a tool-managed context, use `python3` for ad-hoc analysis commands.
- Do not assume a bare `python` shim exists.
- Inside `uv run ... python ...`, `python` is the interpreter selected by `uv`, which is the preferred project-less path when ephemeral dependencies are needed.

Run a script with ephemeral dependencies:
```bash
uv run --no-project --with pandas --with matplotlib python analysis.py
```

Inline one-off:
```bash
uv run --no-project --with polars --with seaborn python - <<'PY'
import polars as pl
print(pl.read_csv("data.csv").describe())
PY
```

Pinned versions:
```bash
uv run --no-project --with "pandas==2.3.2" --with "matplotlib>=3.9,<4" python analysis.py
```

## R Ad-hoc Patterns
Run a script:
```bash
Rscript analysis.R
```

Inline summary:
```bash
Rscript -e 'df <- read.csv("data.csv"); print(summary(df))'
```

Install common packages:
```bash
Rscript -e 'install.packages(c("dplyr","ggplot2"), repos="https://cloud.r-project.org")'
```

## CLI EDA Recipes
Schema and summary stats:
```bash
qsv headers data.csv
qsv stats data.csv
```

Category frequencies:
```bash
qsv frequency -s category data.csv | qsv table
```

Miller aggregations:
```bash
mlr --csv stats1 -a count,min,p50,mean,max -f value data.csv
mlr --csv group-by category then stats1 -a mean,p50 -f value data.csv
```

csvkit sampling and SQL:
```bash
csvcut -n data.csv
csvstat data.csv
csvsql --query "select category, avg(value) as avg_value from stdin group by category" data.csv
```

## Format Extraction Entry Point
Before heavier analysis, use `TEXT_QUERYING.md` to:
- inspect nested JSON, YAML, or TOML with `jg`, `jq`, and `yq`
- shape CSV or TSV inputs with `csvkit`, `mlr`, `qsv`, or `xan`
- filter raw logs or text exports with `awk`, `rg`, or `sed`

## SQL-Style Local Analytics
SQLite quick load and query:
```bash
sqlite3 /tmp/eda.db ".mode csv" ".import data.csv data"
sqlite3 /tmp/eda.db "select category, avg(value) from data group by 1 order by 2 desc limit 20;"
```

DuckDB direct file query:
```bash
duckdb -c "SELECT category, avg(value) AS avg_value FROM 'data.csv' GROUP BY 1 ORDER BY 2 DESC LIMIT 20;"
```

## Visualization Patterns
Gnuplot quick PNG:
```bash
qsv select x,y data.csv > /tmp/xy.csv
gnuplot -e "set datafile separator ','; set terminal pngcairo size 1200,700; set output 'plot.png'; plot '/tmp/xy.csv' using 1:2 with lines title 'series'"
```

Graphviz from edge list:
```bash
cat > /tmp/graph.dot <<'DOT'
digraph G {
  A -> B;
  B -> C;
  A -> C;
}
DOT
dot -Tpng /tmp/graph.dot -o graph.png
```

R ggplot output:
```bash
Rscript -e 'library(ggplot2); df<-read.csv("data.csv"); p<-ggplot(df,aes(x=x,y=y))+geom_point(); ggsave("plot.png",p,width=10,height=6,dpi=150)'
```

## Parallel Batch Patterns
Per-file row counts:
```bash
find data -name "*.csv" | parallel "echo -n {}\" \"; qsv count {}"
```

Per-file stats outputs:
```bash
find data -name "*.csv" | parallel "qsv stats {} > {.}.stats.csv"
```

## Session Guidance
- Start with the format/query tools in `TEXT_QUERYING.md` for profiling and extraction.
- Use uv with `--no-project` for ad-hoc Python analysis and plotting.
- Use Rscript for quick statistical checks or ggplot output.
- Use duckdb or sqlite for heavier joins, group-by, and window logic.
- Use visidata for interactive terminal inspection.
- Use parallel for multi-file and batch workflows.
- Prefer writing temporary artifacts to /tmp unless persistence is requested.
