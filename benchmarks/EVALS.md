# Evals

Measures real token compression of S.H.E.L.L. skills.

## Architecture

- `benchmarks/main.py` — Unified CLI for running and reporting.
- `benchmarks/prompts/` — YAML defined prompts.
- `benchmarks/core/` — Execution and metrics logic.
- `benchmarks/data/` — Snapshots and results.

## Usage

From the `benchmarks/` directory:

```bash
# Run full suite (default flash)
bun run bench

# Run with specific models
bun run bench:flash
bun run bench:pro

# Generate markdown report
bun run report

# Generate plots (requires plotly/kaleido)
bun run plot
```

## Why this design

- **Snapshot-based**: Commits results to git for CI consistency.
- **YAML Prompts**: Categorized and structured test cases.
- **Control Arm**: Isolates skill impact from generic terseness.
