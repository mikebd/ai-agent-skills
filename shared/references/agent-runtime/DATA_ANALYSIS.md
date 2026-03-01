# Data Analysis Cookbook

Last updated: 2026-02-27

## Goal
Fast ad-hoc EDA, statistics, and visualization workflows without creating a project unless needed.

## Current Footprint (Installed)
- qsv, xan, mlr (Miller), csvkit
- visidata
- duckdb, sqlite3
- jq, yq
- gnuplot, graphviz (dot)
- python3, uv
- R, Rscript
- parallel

## Adjacent Tools Worth Adding (Optional)
- radian: better interactive R REPL experience.
- jupyterlab (via uv tool): notebook workflow when needed.

## Project-less Python with uv (canonical)
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

## JSON and YAML Workflows
JSON to CSV preview:
```bash
jq -r '.[] | [.id,.name,.score] | @csv' data.json | qsv table
```

YAML to JSON plus query:
```bash
yq -o=json "." config.yaml | jq ".services[] | {name,port}"
```

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
- Start with qsv, xan, mlr, csvkit, jq, and yq for fast profiling and transforms.
- Use uv with `--no-project` for ad-hoc Python analysis and plotting.
- Use Rscript for quick statistical checks or ggplot output.
- Use duckdb or sqlite for heavier joins, group-by, and window logic.
- Use visidata for interactive terminal inspection.
- Use parallel for multi-file and batch workflows.
- Prefer writing temporary artifacts to /tmp unless persistence is requested.
