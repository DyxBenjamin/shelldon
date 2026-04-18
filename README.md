<p align="center">
  <img src="plugins/shelldon/assets/shelldon.svg" width="120" />
</p>

<h1 align="center">Shelldon</h1>

<p align="center">
  <strong>Semantic Heuristic Execution & Logic Layer (S.H.E.L.L.)</strong>
</p>

<p align="center">
  <a href="https://github.com/DyxBenjamin/shelldon/stargazers"><img src="https://img.shields.io/github/stars/DyxBenjamin/shelldon?style=flat&color=yellow" alt="Stars"></a>
  <a href="https://github.com/DyxBenjamin/shelldon/commits/main"><img src="https://img.shields.io/github/last-commit/DyxBenjamin/shelldon?style=flat" alt="Last Commit"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/DyxBenjamin/shelldon?style=flat" alt="License"></a>
</p>

---

**Shelldon** is a specialized cognitive protocol for AI engineering agents. It implements the **S.H.E.L.L.** (Semantic Heuristic Execution & Logic Layer) standard to minimize token overhead while maximizing technical signal.

By eliminating conversational prose and adopting axiomatic logic, Shelldon reduces **output token volume by ~75%** and **input context by ~46%**, resulting in faster inference, reduced costs, and lower cognitive load for developers.

## The Shelldon Logic

Shelldon treats the LLM response as a high-density telemetry stream rather than a natural language dialogue.

| Metric | Normal Agent | Shelldon (S.H.E.L.L.) |
| :--- | :--- | :--- |
| **Output Density** | High (Conversational) | Ultra-High (Axiomatic) |
| **Token Savings** | 0% | ~75% |
| **Inference Speed** | Baseline | ~3x Improvement |
| **Technical Signal** | Diffuse | Concentrated |

### Comparative Analysis

#### 🗣️ Conventional Response (69 tokens)
> "The reason your React component is re-rendering is likely because you're creating a new object reference on each render cycle. When you pass an inline object as a prop, React's shallow comparison sees it as a different object every time, which triggers a re-render. I'd recommend using useMemo to memoize the object."

#### 🪨 Shelldon Response (19 tokens)
> "New object ref each render. Inline object prop = new ref = re-render. Wrap in `useMemo`."

---

## Operational Modes

Shelldon supports multiple intensity levels to match your workflow requirements:

| Mode | Standard | Application |
| :--- | :--- | :--- |
| **Verbose** | STE (Simplified Technical English) | Technical documentation, complex explanations. |
| **Strict** | Default Fragmented Protocol | Standard development and debugging. |
| **Axiomatic** | Pure Logic Mapping (`->`, `=>`) | High-speed, repetitive engineering tasks. |
| **SOAP** | Diagnostic Grid (Subjective/Objective/Assessment/Plan) | Systematic bug analysis and RCA. |

---

## Capabilities & Sub-Skills

### 🛠️ shell-commit
Generates high-density, telemetry-compliant Conventional Commits. Eliminates narrative noise while preserving architectural intent.
- `feat(api): add GET /users/:id/profile [INFO] Client payload optimization.`

### 🔍 shell-review
Executes deterministic, one-line evaluations per finding. Focuses exclusively on topological integrity and type safety.
- `L42 [ERR] user(null) -> panic => inject guard.`

### 🗜️ shell-compress
Minifies context files (e.g., `CLAUDE.md`, `GEMINI.md`) into axiomatic logic. Reduces session-start token consumption by **~46%**.

---

## Installation

Shelldon is agent-agnostic and supports major AI engineering environments:

### Gemini CLI
```bash
gemini extensions install https://github.com/DyxBenjamin/shelldon
```

### Claude Code
```bash
claude plugin marketplace add DyxBenjamin/shelldon
claude plugin install shell@shell
```

### Multi-Agent Support (Cursor, Windsurf, Cline, Copilot)
```bash
npx skills add DyxBenjamin/shelldon
```

---

## Empirical Validation

Benchmarked against standard models using the `benchmarks/` evaluation harness.

| Task | Normal (tokens) | Shelldon (tokens) | Efficiency |
| :--- | :---: | :---: | :---: |
| React Re-render Diagnosis | 1180 | 159 | **87%** |
| Auth Middleware Fix | 704 | 121 | **83%** |
| Database Connection Pooling | 2347 | 380 | **84%** |
| **Composite Average** | **1214** | **294** | **65%** |

### Theoretical Foundation
Based on research indicating that brevity constraints in large language models can enhance technical accuracy by reducing hallucinatory drift. (See: ["Brevity Constraints Reverse Performance Hierarchies"](https://arxiv.org/abs/2604.00025)).

---

## License

MIT © [DyxBenjamin](https://github.com/DyxBenjamin)
