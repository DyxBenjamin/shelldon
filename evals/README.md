# Evals

Measures real token compression of S.H.E.L.L. skills by running the same
prompts through the active agent under three conditions and comparing the
generated output token counts.

## The three arms

| Arm | System prompt |
|-----|--------------|
| `__baseline__` | none |
| `__terse__` | `Answer concisely.` |
| `<skill>` | `Answer concisely.\n\n{SKILL.md}` |

The honest delta for any skill is **`<skill>` vs `__terse__`** — i.e.
how much the skill itself adds on top of a plain "be terse" instruction.

## Why this design

- **Real LLM output**, not hand-written examples.
- **Same agent CLI** the skills target.
- **Snapshot committed to git** for deterministic and free CI runs.
- **Control arm** isolates the skill's contribution from the generic
  "be terse" effect.

## Files

- `prompts/en.txt` — fixed list of dev questions, one per line.
- `llm_run.py` — runs agent CLI per (prompt, arm), captures real LLM output, writes `snapshots/results.json`.
- `measure.py` — reads the snapshot, counts tokens, prints a markdown table.
- `snapshots/results.json` — committed source of truth.

## Refresh the snapshot

```bash
uv run python evals/llm_run.py
```

This calls the agent once per prompt × (N skills + 2 control arms). Use
a small model to keep it cheap:

```bash
SHELL_EVAL_MODEL=claude-3-haiku-20240307 uv run python evals/llm_run.py
```

## Read the snapshot (no LLM, no API key, runs in CI)

```bash
uv run --with tiktoken python evals/measure.py
```

## Adding a prompt

Append a line to `prompts/en.txt`, then refresh the snapshot.

## Adding a skill

Drop a `skills/<name>/SKILL.md`, then refresh the snapshot. `llm_run.py`
picks up every skill directory automatically.

## What this does NOT measure

- **Fidelity** — does the compressed answer preserve the technical
  claims?
- **Latency or cost** — out of scope.
- **Exact agent tokens** — Absolute numbers are approximate.
