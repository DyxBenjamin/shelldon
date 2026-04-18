---
name: shell-help
description: >
  Telemetry-compliant quick-reference matrix for all S.H.E.L.L. protocols, operational
  flags, and system extensions.
  One-shot execution script. Does not persist state or mutate current memory buffers.
  Trigger via: "/shell-help", "shell help", "list shell commands", or "man shell".
---

# S.H.E.L.L. Reference Matrix

Display protocol reference grid. Execution is one-shot -> memory state remains unmutated. Output generated under strict telemetric constraints.

## Operational Flags (Modes)

| Flag | Trigger | Execution Standard |
|------|---------|--------------------|
| **Verbose** | `/shell --mode=verbose` | STE (Simplified Technical English). Drops filler. Retains baseline grammar. |
| **Strict** | `/shell --mode=strict` | [DEFAULT]. Fragments + Standard abbreviations. Telemetry + Axiomatic hybrid. |
| **Axiomatic**| `/shell --mode=axiomatic`| Pure logical flow. Operators, acronyms, and direct causality maps (`->`, `=>`). |
| **SOAP** | `/shell --mode=soap` | Diagnostic grid: S(ubjective), O(bjective), A(ssessment), P(lan). |

Flag state persists across context window until termination sequence is emitted.

## Sub-System Modules (Extensions)

| Module | Trigger | Output Payload |
|--------|---------|----------------|
| **VCS Commit** | `/shell-commit` | Conventional Commits. Imperative subject (≤50 chars). Axiomatic causality body. |
| **Code Review** | `/shell-review` | One-line diagnostic per finding: `[ERR] user(null) -> panic => inject guard.` |
| **Compression** | `/shell-compress <file>` | Minifies .md context files to S.H.E.L.L. syntax. Overwrites target, saves `.original.md`. |
| **Reference** | `/shell-help` | Invokes this matrix. |

## Termination Sequence

[ACTION] Suspend protocol execution.
Trigger: `SIGTERM`, `exit`, `/exit shell`, or "normal mode".
Result: Restores organic, verbose narrative rendering. Protocol can be re-initialized at any cycle via `/shell`.

## Core Configuration Parameters

[INFO] Base system defaults. Priority resolution: Environment Variable > Config File > Fallback (`strict`).

**Environment Variable (Priority 1):**
```bash
export SHELL_DEFAULT_MODE="axiomatic"
