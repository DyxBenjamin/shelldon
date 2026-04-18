<p align="center">
  <img src="plugins/shelldon/assets/shelldon.svg" width="120" />
</p>

<h1 align="center">S.H.E.L.L.</h1>

<p align="center">
  <strong>Semantic Heuristic Execution & Logic Layer</strong>
</p>

<p align="center">
  <a href="https://github.com/DyxBenjamin/shelldon/stargazers"><img src="https://img.shields.io/github/stars/DyxBenjamin/shelldon?style=flat&color=yellow" alt="Stars"></a>
  <a href="https://github.com/DyxBenjamin/shelldon/commits/main"><img src="https://img.shields.io/github/last-commit/DyxBenjamin/shelldon?style=flat" alt="Last Commit"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/DyxBenjamin/shelldon?style=flat" alt="License"></a>
</p>

<p align="center">
  <a href="#before--after">Before/After</a> •
  <a href="#install">Install</a> •
  <a href="#operational-modes">Modes</a> •
  <a href="#shell-skills">Skills</a> •
  <a href="#benchmarks">Benchmarks</a> •
  <a href="#evals">Evals</a>
</p>

---

A [Gemini CLI](https://github.com/google/gemini-cli) skill/plugin, [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin, and Codex plugin that makes agent talk in S.H.E.L.L. (Semantic Heuristic Execution & Logic Layer) — cutting **~75% of output tokens** while keeping full technical accuracy. Now with [terse commits](#shell-commit), [one-line code reviews](#shell-review), and a [compression tool](#shell-compress) that cuts **~46% of input tokens** every session.

Based on the viral observation that compressed-speak dramatically reduces LLM token usage without losing technical substance.

## Before / After

<table>
<tr>
<td width="50%">

### 🗣️ Normal Gemini (69 tokens)

> "The reason your React component is re-rendering is likely because you're creating a new object reference on each render cycle. When you pass an inline object as a prop, React's shallow comparison sees it as a different object every time, which triggers a re-render. I'd recommend using useMemo to memoize the object."

</td>
<td width="50%">

### 🪨 S.H.E.L.L. Gemini (19 tokens)

> "New object ref each render. Inline object prop = new ref = re-render. Wrap in `useMemo`."

</td>
</tr>
<tr>
<td>

### 🗣️ Normal Gemini

> "Sure! I'd be happy to help you with that. The issue you're experiencing is most likely caused by your authentication middleware not properly validating the token expiry. Let me take a look and suggest a fix."

</td>
<td>

### 🪨 S.H.E.L.L. Gemini

> "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"

</td>
</tr>
</table>

**Same fix. 75% less word. Brain still big.**

**Pick your mode:**

<table>
<tr>
<td width="25%">

#### 🪶 Verbose

> "Your component re-renders because you create a new object reference each render. Inline object props fail shallow comparison every time. Wrap it in `useMemo`."

</td>
<td width="25%">

#### 🪨 Strict

> "New object ref each render. Inline object prop = new ref = re-render. Wrap in `useMemo`."

</td>
<td width="25%">

#### 🔥 Axiomatic

> "[WARN] state(render) -> ref(new) => DOM(repaint) || resolution: `useMemo()`."

</td>
<td width="25%">

#### 🧼 SOAP

> "S: Unwarranted re-renders. O: Inline object prop. A: Ref equality check fails. P: Implement `useMemo`."

</td>
</tr>
</table>

**Same answer. You pick how many word.**

```
┌─────────────────────────────────────┐
│  TOKENS SAVED          ████████ 75% │
│  TECHNICAL ACCURACY    ████████ 100%│
│  SPEED INCREASE        ████████ ~3x │
│  VIBES                 ████████ OOG │
└─────────────────────────────────────┘
```

- **Faster response** — less token to generate = speed go brrr
- **Easier to read** — no wall of text, just the answer
- **Same accuracy** — all technical info kept, only fluff removed ([science say so](https://arxiv.org/abs/2604.00025))
- **Save money** — ~71% less output token = less cost
- **Fun** — every code review become telemetry telemetry

## Install

Pick your agent. One command. Done.

| Agent | Install |
|-------|---------|
| **Gemini CLI** | `gemini extensions install https://github.com/DyxBenjamin/shelldon` |
| **Claude Code** | `claude plugin marketplace add DyxBenjamin/shelldon && claude plugin install shell@shell` |
| **Codex** | Clone repo → `/plugins` → Search "S.H.E.L.L." → Install |
| **Cursor** | `npx skills add DyxBenjamin/shelldon -a cursor` |
| **Windsurf** | `npx skills add DyxBenjamin/shelldon -a windsurf` |
| **Copilot** | `npx skills add DyxBenjamin/shelldon -a github-copilot` |
| **Cline** | `npx skills add DyxBenjamin/shelldon -a cline` |
| **Any other** | `npx skills add DyxBenjamin/shelldon` |

Install once. Use in every session for that install target after that. One rock. That it.

### What You Get

Auto-activation is built in for Gemini CLI, Claude Code, and the repo-local Codex setup below. `npx skills add` installs the skill for other agents, but does **not** install repo rule/instruction files, so S.H.E.L.L. does not auto-start there unless you add the always-on snippet below.

| Feature | Gemini CLI | Claude Code | Codex | Cursor | Windsurf | Cline | Copilot |
|---------|:-----------:|:-----:|:----------:|:------:|:--------:|:-----:|:-------:|
| S.H.E.L.L. mode | Y | Y | Y | Y | Y | Y | Y |
| Auto-activate every session | Y | Y | Y¹ | —² | —² | —² | —² |
| `/shelldon` command | Y | Y | Y¹ | — | — | — | — |
| Mode switching (verbose/strict/axiomatic/soap) | Y | Y | Y¹ | Y³ | Y³ | — | — |
| Statusline badge | — | Y⁴ | — | — | — | — | — |
| shell-commit | Y | Y | — | Y | Y | Y | Y |
| shell-review | Y | Y | — | Y | Y | Y | Y |
| shell-compress | Y | Y | Y | Y | Y | Y | Y |
| shell-help | Y | Y | — | Y | Y | Y | Y |

> [!NOTE]
> Auto-activation works differently per agent: Gemini CLI uses `GEMINI.md` context files, Claude Code uses SessionStart hooks, this repo's Codex dogfood setup uses `.codex/hooks.json`. Cursor/Windsurf/Cline/Copilot can be made always-on, but `npx skills add` installs only the skill, not the repo rule/instruction files.
>
> ¹ Codex uses `$shell` syntax, not `/shelldon`. This repo ships `.codex/hooks.json`, so shell auto-starts when you run Codex inside this repo. The installed plugin itself gives you `$shell`; copy the same hook into another repo if you want always-on behavior there too. shell-commit and shell-review are not in the Codex plugin bundle — use the SKILL.md files directly.
> ² Add the "Want it always on?" snippet below to those agents' system prompt or rule file if you want session-start activation.
> ³ Cursor and Windsurf receive the full SKILL.md with all intensity levels. Mode switching works on-demand via the skill; no slash command.
> ⁴ Available in Claude Code, but plugin install only nudges setup. Standalone `install.sh` / `install.ps1` configures it automatically when no custom `statusLine` exists.

<details>
<summary><strong>Gemini CLI — full details</strong></summary>

```bash
gemini extensions install https://github.com/DyxBenjamin/shelldon
```

Update: `gemini extensions update shell` · Uninstall: `gemini extensions uninstall shell`

Auto-activates via `GEMINI.md` context file. Also ships custom Gemini commands:
- `/shelldon` — switch intensity level (verbose/strict/axiomatic/soap)
- `/shelldon-commit` — generate high-density commit message
- `/shelldon-review` — one-line code review

</details>

<details>
<summary><strong>Claude Code — full details</strong></summary>

The plugin install gives you skills + auto-loading hooks. If no custom `statusLine` is configured, S.H.E.L.L. nudges Claude to offer badge setup on first session.

```bash
claude plugin marketplace add DyxBenjamin/shelldon
claude plugin install shell@shell
```

**Standalone hooks (without plugin):** If you prefer not to use the plugin system:
```bash
# macOS / Linux / WSL
bash <(curl -s https://raw.githubusercontent.com/DyxBenjamin/shelldon/main/hooks/install.sh)

# Windows (PowerShell)
irm https://raw.githubusercontent.com/DyxBenjamin/shelldon/main/hooks/install.ps1 | iex
```

Or from a local clone: `bash hooks/install.sh` / `powershell -File hooks\install.ps1`

Uninstall: `bash hooks/uninstall.sh` or `powershell -File hooks\uninstall.ps1`

**Statusline badge:** Shows `[S.H.E.L.L.]`, `[S.H.E.L.L.:AXIOMATIC]`, etc. in your status bar.

- **Plugin install:** If you do not already have a custom `statusLine`, Claude should offer to configure it on first session
- **Standalone install:** Configured automatically by `install.sh` / `install.ps1` unless you already have a custom statusline
- **Custom statusline:** Installer leaves your existing statusline alone. See [`hooks/README.md`](hooks/README.md) for the merge snippet

</details>

<details>
<summary><strong>Codex — full details</strong></summary>

**macOS / Linux:**
1. Clone repo → Open Codex in the repo directory → `/plugins` → Search "S.H.E.L.L." → Install
2. Repo-local auto-start is already wired by `.codex/hooks.json` + `.codex/config.toml`

**Windows:**
1. Enable symlinks first: `git config --global core.symlinks true` (requires Developer Mode or admin)
2. Clone repo → Open VS Code → Codex Settings → Plugins → find "S.H.E.L.L." under local marketplace → Install → Reload Window
3. Codex hooks are currently disabled on Windows, so use `$shell` to start manually

This repo also ships `.codex/hooks.json` and enables hooks in `.codex/config.toml`, so S.H.E.L.L. auto-activates while you run Codex inside this repo on macOS/Linux. The installed plugin gives you `$shell`; if you want always-on behavior in other repos too, copy the same `SessionStart` hook there and enable:

```toml
[features]
codex_hooks = true
```

</details>

<details>
<summary><strong>Cursor / Windsurf / Cline / Copilot — full details</strong></summary>

`npx skills add` installs the skill file only — it does **not** install the agent's rule/instruction file, so S.H.E.L.L. does not auto-start. For always-on, add the "Want it always on?" snippet below to your agent's rules or system prompt.

| Agent | Command | Not installed | Mode switching | Always-on location |
|-------|---------|--------------|:--------------:|--------------------|
| Cursor | `npx skills add DyxBenjamin/shelldon -a cursor` | `.cursor/rules/shelldon.mdc` | Y | Cursor rules |
| Windsurf | `npx skills add DyxBenjamin/shelldon -a windsurf` | `.windsurf/rules/shelldon.md` | Y | Windsurf rules |
| Cline | `npx skills add DyxBenjamin/shelldon -a cline` | `.clinerules/shelldon.md` | — | Cline rules or system prompt |
| Copilot | `npx skills add DyxBenjamin/shelldon -a github-copilot` | `.github/copilot-instructions.md` + `AGENTS.md` | — | Copilot custom instructions |

Uninstall: `npx skills remove shell`

Copilot works with Chat, Edits, and Coding Agent.

</details>

<details>
<summary><strong>Any other agent (opencode, Roo, Amp, Goose, Kiro, and 40+ more)</strong></summary>

[npx skills](https://github.com/vercel-labs/skills) supports 40+ agents:

```bash
npx skills add DyxBenjamin/shelldon           # auto-detect agent
npx skills add DyxBenjamin/shelldon -a amp
npx skills add DyxBenjamin/shelldon -a augment
npx skills add DyxBenjamin/shelldon -a goose
npx skills add DyxBenjamin/shelldon -a kiro-cli
npx skills add DyxBenjamin/shelldon -a roo
# ... and many more
```

Uninstall: `npx skills remove shell`

> **Windows note:** `npx skills` uses symlinks by default. If symlinks fail, add `--copy`: `npx skills add DyxBenjamin/shelldon --copy`

**Important:** These agents don't have a hook system, so S.H.E.L.L. won't auto-start. Say `/shelldon` or "activate shell mode" to activate each session.

**Want it always on?** Paste this into your agent's system prompt or rules file — S.H.E.L.L. will be active from the first message, every session:

```
Execute as headless S.H.E.L.L. terminal. Technical substance exact. Only fluff die.
Drop: articles, filler (just/really/basically), pleasantries, hedging.
Fragments OK. Axiomatic causality (->, =>). Code unchanged.
Enforce: Telemetry prefixes ([WARN], [ERR], [OK]). Omit [INFO] tag.
Pattern: ([TELEMETRY]) [Entity] -> [State] => [Next Step].
ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
Code/commits/PRs: normal. Off: "exit" / "normal mode".
```

Where to put it:
| Agent | File |
|-------|------|
| opencode | `.config/opencode/AGENTS.md` |
| Roo | `.roo/rules/shelldon.md` |
| Amp | your workspace system prompt |
| Others | your agent's system prompt or rules file |

</details>

## Usage

Trigger with:
- `/shelldon` or Codex `$shell`
- "activate shell mode"
- "talk in shell mode"
- "less tokens please"

Stop with: "exit" or "normal mode"

### Operational Modes

| Level | Trigger | What it do |
|-------|---------|------------|
| **Verbose** | `/shelldon verbose` | Drop filler, keep grammar. Professional but no fluff |
| **Strict** | `/shelldon strict` | [DEFAULT]. Drop articles, fragments, telemetry hybrid |
| **Axiomatic** | `/shelldon axiomatic` | Pure logical flow. Telegraphic. Operators only |
| **SOAP** | `/shelldon soap` | S(ubjective), O(bjective), A(ssessment), P(lan) |

Level stick until you change it or session end.

## S.H.E.L.L. Skills

### shell-commit

`/shelldon-commit` — high-density commit messages. Conventional Commits. ≤50 char subject. Axiomatic causality body.

### shell-review

`/shelldon-review` — one-line diagnostic per finding: `L42 [ERR] user(null) -> panic => inject guard.`

### shell-help

`/shelldon-help` — telemetry-compliant quick-reference matrix. All modes and system extensions.

### shell-compress

`/shelldon-compress <filepath>` — S.H.E.L.L. make Gemini *speak* with fewer tokens. **Compress** make Gemini *read* fewer tokens.

Your `GEMINI.md` or `CLAUDE.md` loads on **every session start**. S.H.E.L.L. Compress rewrites memory files into axiomatic logic so agent reads less — without you losing the human-readable original.

```
/shelldon-compress GEMINI.md
```

```
GEMINI.md          ← compressed (Gemini reads this every session — fewer tokens)
GEMINI.original.md ← human-readable backup (you read and edit this)
```

| File | Original | Compressed | Saved |
|------|----------:|----------:|------:|
| `shell-md-preferences.md` | 706 | 285 | **59.6%** |
| `project-notes.md` | 1145 | 535 | **53.3%** |
| `shell-md-project.md` | 1122 | 636 | **43.3%** |
| `todo-list.md` | 627 | 388 | **38.1%** |
| `mixed-with-code.md` | 888 | 560 | **36.9%** |
| **Average** | **898** | **481** | **46%** |

Code blocks, URLs, file paths, commands, headings, dates, version numbers — anything technical passes through untouched. Only prose gets compressed. See the full [shell-compress README](skills/shelldon-compress/SKILL.md) for details. [Security note](skills/shelldon-compress/SECURITY.md): Snyk flags this as High Risk due to subprocess/file patterns — it's a false positive.

## Benchmarks

Real token counts from the Gemini API:

<!-- BENCHMARK-TABLE-START -->
| Task | Normal (tokens) | S.H.E.L.L. (tokens) | Saved |
|------|---------------:|----------------:|------:|
| Explain React re-render bug | 1180 | 159 | 87% |
| Fix auth middleware token expiry | 704 | 121 | 83% |
| Set up PostgreSQL connection pool | 2347 | 380 | 84% |
| Explain git rebase vs merge | 702 | 292 | 58% |
| Refactor callback to async/await | 387 | 301 | 22% |
| Architecture: microservices vs monolith | 446 | 310 | 30% |
| Review PR for security issues | 678 | 398 | 41% |
| Docker multi-stage build | 1042 | 290 | 72% |
| Debug PostgreSQL race condition | 1200 | 232 | 81% |
| Implement React error boundary | 3454 | 456 | 87% |
| **Average** | **1214** | **294** | **65%** |

*Range: 22%–87% savings across prompts.*
<!-- BENCHMARK-TABLE-END -->

> [!IMPORTANT]
> S.H.E.L.L. only affects output tokens — thinking/reasoning tokens are untouched. S.H.E.L.L. no make brain smaller. S.H.E.L.L. make *mouth* smaller. Biggest win is **readability and speed**, cost savings are a bonus.

A March 2026 paper ["Brevity Constraints Reverse Performance Hierarchies in Language Models"](https://arxiv.org/abs/2604.00025) found that constraining large models to brief responses **improved accuracy by 26 percentage points** on certain benchmarks and completely reversed performance hierarchies. Verbose not always better. Sometimes less word = more correct.

## Evals

S.H.E.L.L. not just claim 75%. S.H.E.L.L. **prove** it.

The `evals/` directory has a three-arm eval harness that measures real token compression against a proper control — not just "verbose vs skill" but "terse vs skill". Because comparing S.H.E.L.L. to verbose Gemini conflate the skill with generic terseness. That cheating. S.H.E.L.L. not cheat.

```bash
# Run the eval
uv run python evals/llm_run.py

# Read results
uv run --with tiktoken python evals/measure.py
```

## Star This Repo

If S.H.E.L.L. save you mass token, mass money — leave mass star. ⭐

[![Star History Chart](https://api.star-history.com/svg?repos=DyxBenjamin/shelldon&type=Date)](https://star-history.com/#DyxBenjamin/shelldon&Date)

## License

MIT — free like mass mammoth on open plain.
