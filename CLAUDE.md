# CLAUDE.md — S.H.E.L.L.

## README is a product artifact

README = product front door. Treat like UI copy.

**Rules for any README change:**

- Readable by non-AI-agent users.
- Keep Before/After examples first.
- Install table always complete + accurate.
- What You Get table must sync with actual code.
- Benchmark numbers from real runs in `benchmarks/` and `evals/`.

---

## Project overview

S.H.E.L.L. (Semantic Heuristic Execution & Logic Layer) makes AI coding agents respond in compressed, terminal-optimized prose — cutting ~65-75% output tokens while keeping full technical accuracy. Ships as Gemini CLI extension, Claude Code plugin, Codex plugin, and rule files for other agents.

---

## File structure and what owns what

### Single source of truth files — edit only these

| File | What it controls |
|------|-----------------|
| `skills/shell/SKILL.md` | S.H.E.L.L. behavior: intensity modes, rules, auto-clarity, persistence. |
| `rules/shell-activate.md` | Always-on auto-activation rule body. |
| `skills/shell-commit/SKILL.md` | S.H.E.L.L. commit message behavior. |
| `skills/shell-review/SKILL.md` | S.H.E.L.L. code review behavior. |
| `skills/shell-help/SKILL.md` | Quick-reference card. |
| `skills/shell-compress/SKILL.md` | Compress sub-skill behavior. |

### Auto-generated / auto-synced — do not edit directly

| File | Synced from |
|------|-------------|
| `plugins/shell/skills/shell/SKILL.md` | `skills/shell/SKILL.md` |
| `shell.skill` | ZIP of `skills/shell/` directory |
| `.github/copilot-instructions.md` | `rules/shell-activate.md` |

---

## CI sync workflow

`.github/workflows/sync-skill.yml` triggers on main push when source files change.

---

## Hook system

Three hooks in `hooks/` plus a `shell-config.js` shared module. Communicate via flag file at `$CONFIG_DIR/.shell-active` (detected per ecosystem).

SessionStart hook ──writes mode──▶ $CONFIG_DIR/.shell-active ◀──writes mode── UserPromptSubmit hook
                                              │
                                           reads
                                              ▼
                                     Statusline script
                                    [S.H.E.L.L.:AXIOMATIC] │ ...

### `hooks/shell-config.js` — shared module

Exports `getDefaultMode()`, `safeWriteFlag()`, `readFlag()`, `getEcosystem()`, and `getConfigDir()`. Ecosystem-agnostic.

### `hooks/shell-activate.js` — SessionStart hook

Writes active mode to `.shell-active`. Emits S.H.E.L.L. ruleset. Nudges for statusline.

### `hooks/shell-mode-tracker.js` — UserPromptSubmit hook

Tracks mode changes via `/shell` (or `$shell` for Codex) commands. Natural-language triggers support. Per-turn reinforcement.

### `hooks/shell-statusline.sh` — Statusline badge

Outputs colored badge for terminal statuslines. Detects config directory automatically.

---

## Agent distribution

How S.H.E.L.L. reaches each agent type:

| Agent | Mechanism | Auto-activates? |
|-------|-----------|----------------|
| Gemini CLI | Extension with `GEMINI.md` context file | Yes |
| Claude Code | Plugin (hooks + skills) or standalone hooks | Yes |
| Codex | Plugin in `plugins/shell/` + `.codex/hooks.json` | Yes |
| Copilot | `.github/copilot-instructions.md` | Yes |

---

## Key rules for agents working here

- Edit source files in `skills/` for behavior changes.
- README most important file for user-facing impact.
- Benchmark and eval numbers must be real.
- All flag file writes MUST use `safeWriteFlag()` in `shell-config.js`.
- [INFO] tag suppression: Informational state must be emitted as raw axiomatic fragments without a tag.
