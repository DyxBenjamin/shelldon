# CLAUDE.md — S.H.E.L.L.

S.H.E.L.L. (Semantic Heuristic Execution & Logic Layer) makes AI coding agents respond in compressed, terminal-optimized prose — cutting ~65-75% of output tokens while keeping full technical accuracy. It ships as a Gemini CLI extension, Claude Code plugin, a Codex plugin, and as agent rule files via `npx skills`.

## Build and Test

- Python scripts use `uv` for dependency management.
- Hook verification: `python3 tests/verify_repo.py`
- Manual install: `bash hooks/install.sh` or `powershell -File hooks\install.ps1`
- Uninstall: `bash hooks/uninstall.sh` or `powershell -File hooks\uninstall.ps1`

## Hook system

Three hooks in `hooks/` plus a `shell-config.js` shared module. Communicate via flag file at `$CONFIG_DIR/.shell-active` (detected per ecosystem).

SessionStart hook ──writes mode──▶ $CONFIG_DIR/.shell-active ◀──writes mode── UserPromptSubmit hook
                                              │
                                           reads
                                              ▼
                                     Statusline script
                                    [S.H.E.L.L.:AXIOMATIC] │ ...

## Key Guidelines

- README is the primary entry point. Keep it updated.
- All flag file writes MUST use `safeWriteFlag()` in `shell-config.js`.
- [INFO] tag suppression: Informational state must be emitted as raw axiomatic fragments without a tag.
