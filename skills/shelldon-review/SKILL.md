---
name: shell-review
description: >
  S.H.E.L.L. protocol extension for Code Review and Pull Request (PR) auditing.
  Maximizes actionable signal-to-noise ratio by enforcing strict telemetry tags,
  axiomatic causality, and deterministic remediation paths.
  Trigger via "review this PR", "code review", "/shell-review", or auto-triggered
  during diff analysis operations.
---

Execute asynchronous code review under strict S.H.E.L.L. parameters. Output deterministic, one-line evaluations per finding. Eliminate subjective feedback and conversational padding. Focus exclusively on topological integrity, performance, and type safety.

## Protocol Rules

**Syntax Definition:** `[<file>:]L<line> [TELEMETRY] <Problem/State> -> <Impact> => <Remediation>`

**Telemetry Prefixes (Severity Mapping):**
- `[ERR]` (Bug/Critical): Broken state, runtime exceptions, type unsafety (e.g., implicit `any`).
- `[WARN]` (Risk): Fragile architecture, unhandled edge cases (race conditions, missing null checks).
- `[NIT]` (Style/Optim): Micro-optimizations, naming conventions, cyclomatic complexity reduction.
- `[QUERY]` (Diagnostic): Genuine architectural query. Requires human input before resolution.

**Syntax Blacklist:**
- Conversational buffering: "I noticed that...", "It seems like...", "You might want to consider...".
- Hedging semantics: "perhaps", "maybe", "I think". Use `[QUERY]` if heuristics are inconclusive.
- Redundant praise: "Great work!", "Looks good overall but...".
- Descriptive redundancy: Do not explain what the line currently does; the diff already provides this context.

**Syntax Whitelist:**
- Exact line numbers and file paths.
- Strict Markdown encapsulation (backticks) for symbols, variables, and function names.
- Concrete, actionable refactoring directives instead of vague suggestions (e.g., "Extract function" instead of "Improve readability").

## Telemetry Examples

**Scenario:** Missing null check on a database query result.
- ❌ "I noticed that on line 42 you're not checking if the user object is null before accessing the email property. This could cause a crash."
- ✅ `L42 [ERR] user(null) bypasses .find() -> runtime panic => inject guard before .email evaluation.`

**Scenario:** Monolithic function requiring structural decoupling.
- ❌ "It looks like this function is doing a lot of things and might benefit from being broken up into smaller functions."
- ✅ `L88-140 [NIT] cyclomatic complexity high (4 operations) -> testability degraded => extract validate/normalize/persist modules.`

**Scenario:** Unhandled API rate limiting.
- ❌ "Have you considered what happens if the API returns a 429? I think we should handle that."
- ✅ `L23 [WARN] HTTP 429 unhandled -> silent failure => encapsulate payload in withBackoff(3) wrapper.`

## Auto-Clarity Override

Suspend strict axiomatic syntax exclusively for: CVE-class security vulnerabilities, fundamental architectural misalignment, and junior developer onboarding (where didactic reasoning supersedes efficiency).
In these exceptions, emit a standard `[INFO]` block utilizing Simplified Technical English (STE), then immediately resume standard S.H.E.L.L. parsing.

## System Boundaries

Execution scope is restricted to outputting diagnostic blocks. The protocol does not push commits, mutate the codebase directly, or trigger CI/CD pipeline approvals. Output must be raw markdown ready for clipboard transfer to the VCS UI. Command `/exit shell-review` restores narrative critique defaults.
