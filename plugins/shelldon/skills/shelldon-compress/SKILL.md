---
name: shell-compress
description: >
  S.H.E.L.L. protocol utility for context file minification (e.g., CLAUDE.md, memory logs,
  architecture decisions). Transmutes natural language into high-density telemetry and
  axiomatic logic to maximize context window efficiency. Preserves code, paths, and URLs
  with absolute fidelity.
  Trigger via: "/shell-compress <filepath>" or "compress memory file".
---

# S.H.E.L.L. Compression Protocol

## Objective
Minify natural language memory artifacts into deterministic S.H.E.L.L. syntax. The compressed output overwrites the target file, maintaining a lossless backup (`<filename>.original.md`) to prevent context corruption.

## Execution Trigger
`/shell-compress <filepath>`

## Execution Pipeline
1. Locate the `scripts/` directory relative to this `SKILL.md` execution environment.
2. Invoke structural minifier:
   `cd <directory_containing_this_SKILL.md> && python3 -m scripts <absolute_filepath>`
3. CLI Operation Sequence:
   - File type validation (bypass tokenization).
   - LLM S.H.E.L.L. translation pass.
   - Validation & checksum (bypass tokenization).
   - On error: Targeted LLM heuristic patch (no full re-runs).
   - Max retries: 2.
   - Failure state: Halt execution. Retain original file. Emit `[ERR]`.
4. Return operational state to standard output.

## Lexical Translation Rules

### Strip (Nullify)
- Articles: a, an, the.
- Adverbial bloat: just, really, basically, actually, simply, essentially, generally.
- Conversational wrappers: "sure", "certainly", "happy to", "I'd recommend".
- Hedging semantics: "might be worth", "could consider", "would be good to".
- Syntactic redundancy: "in order to" -> "to", "make sure to" -> "ensure", "the reason is because" -> "due to".

### Preserve (Immutable)
- Code blocks (fenced ``` and indented).
- Inline symbols (`backtick content`).
- URIs/URLs (absolute paths, markdown hyperlinks).
- File system paths (`/src/components/...`, `./config.yaml`).
- CLI Commands (`bun install`, `git rebase`, `docker build`).
- Technical taxonomy (frameworks, protocols, algorithms, types/interfaces).
- Environment variables (`$HOME`, `NODE_ENV`).
- SemVer identifiers, hashes, and numeric constants.

### Structural Integrity
- Markdown headings (`#`, `##`) remain exact; compress payload beneath.
- Hierarchy depth in nested bullets must persist.
- Ordered list sequences must persist.
- Frontmatter/YAML configuration blocks are read-only.

### S.H.E.L.L. Mapping
- Replace narrative with Telemetry (`[INFO]`, `[WARN]`, `[ERR]`) and Axiomatic logic (`->`, `=>`).
- Merge redundant directives into single logical operators.
- State actions imperatively: "Run tests" instead of "You should run tests".

**CRITICAL DIRECTIVE:**
Regions encapsulated by ``` are strictly read-only.
Do not: alter spacing, remove comments, reorder logic, or mutate syntax.
Inline code (`...`) is structurally locked.

## Translation Vectors (Examples)

**Scenario A: Operational Directive**
- *Original:* "You should always make sure to run the test suite before pushing any changes to the main branch. This is important because it helps catch bugs early and prevents broken builds from being deployed to production."
- *S.H.E.L.L.:* `[WARN] unverified push -> broken prod build => execute test suite before main branch merge.`

**Scenario B: Architectural Topology**
- *Original:* "The application uses a microservices architecture with the following components. The API gateway handles all incoming requests and routes them to the appropriate service. The authentication service is responsible for managing user sessions and JWT tokens."
- *S.H.E.L.L.:* `[INFO] Architecture: Microservices.`
  `- API Gateway -> request routing.`
  `- Auth Service -> session && JWT management.`

## System Boundaries
- Target isolation: Compress ONLY `.md`, `.txt`, or extensionless text files.
- Blacklist: NEVER mutate `.py`, `.ts`, `.js`, `.json`, `.yaml`, `.yml`, `.toml`, `.env`, `.lock`, `.css`, `.html`, `.sql`, `.sh`.
- Mixed-mode files: Compress narrative prose exclusively; ignore code blocks.
- Backup protocol: `FILE.original.md` is immutable. Never run compression against `.original.md` artifacts.
