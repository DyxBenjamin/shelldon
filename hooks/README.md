# S.H.E.L.L. Hooks

These hooks are **bundled with the S.H.E.L.L. plugin** and activate automatically when the plugin is installed. No manual setup required.

If you installed S.H.E.L.L. standalone (without the plugin), you can use `bash hooks/install.sh` to wire them into your settings.json manually.

## What's Included

### `shell-activate.js` — SessionStart hook

- Runs once when agent starts
- Writes `strict` to `$CONFIG_DIR/.shell-active` (flag file)
- Emits S.H.E.L.L. rules as hidden SessionStart context
- Detects missing statusline config and emits setup nudge

### `shell-mode-tracker.js` — UserPromptSubmit hook

- Fires on every user prompt, checks for `/shell` commands (or `$shell` on Codex)
- Writes the active mode to the flag file when a shell command is detected
- Supports: `verbose`, `strict`, `axiomatic`, `soap`, `commit`, `review`, `compress`

### `shell-statusline.sh` / `shell-statusline.ps1` — Statusline badge script

- Reads `$CONFIG_DIR/.shell-active` and outputs a colored badge
- Shows `[S.H.E.L.L.]`, `[S.H.E.L.L.:AXIOMATIC]`, `[S.H.E.L.L.:SOAP]`, etc.

## Statusline Badge

The statusline badge shows which S.H.E.L.L. mode is active directly in your status bar.

**Plugin users:** If you do not already have a `statusLine` configured, the agent will detect that on your first session after install and offer to set it up for you. Accept and you're done.

If you already have a custom statusline, S.H.E.L.L. does not overwrite it and the agent stays quiet. Add the badge snippet to your existing script instead.

**Standalone users:** `install.sh` / `install.ps1` wires the statusline automatically if you do not already have a custom statusline. If you do, the installer leaves it alone and prints the merge note.

**Manual setup:** If you need to configure it yourself, add one of these to your `settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash /path/to/shell-statusline.sh"
  }
}
```

```json
{
  "statusLine": {
    "type": "command",
    "command": "powershell -ExecutionPolicy Bypass -File C:\\path\\to\\shell-statusline.ps1"
  }
}
```

**Custom statusline:** If you already have a statusline script, add this snippet to it:

```bash
shell_text=""
shell_flag="$HOME/.gemini/.shell-active" # or .claude or .codex
if [ -f "$shell_flag" ]; then
  shell_mode=$(cat "$shell_flag" 2>/dev/null)
  if [ "$shell_mode" = "strict" ] || [ -z "$shell_mode" ]; then
    shell_text=$'\033[38;5;172m[S.H.E.L.L.]\033[0m'
  else
    shell_suffix=$(echo "$shell_mode" | tr '[:lower:]' '[:upper:]')
    shell_text=$'\033[38;5;172m[S.H.E.L.L.:'"${shell_suffix}"$']\033[0m'
  fi
fi
```

Badge examples:
- `/shell` → `[S.H.E.L.L.]`
- `/shell axiomatic` → `[S.H.E.L.L.:AXIOMATIC]`
- `/shell soap` → `[S.H.E.L.L.:SOAP]`
- `/shell-commit` → `[S.H.E.L.L.:COMMIT]`
- `/shell-review` → `[S.H.E.L.L.:REVIEW]`

## How It Works

```
SessionStart hook ──writes "strict"──▶ $CONFIG_DIR/.shell-active ◀──writes mode── UserPromptSubmit hook
                                              │
                                           reads
                                              ▼
                                     Statusline script
                                    [S.H.E.L.L.:AXIOMATIC] │ ...
```

SessionStart stdout is injected as hidden system context — the agent sees it, users don't. The statusline runs as a separate process. The flag file is the bridge.

## Uninstall

If installed via plugin: disable the plugin — hooks deactivate automatically.

If installed via `install.sh`:
```bash
bash hooks/uninstall.sh
```

Or manually:
1. Remove `shell-activate.js`, `shell-mode-tracker.js`, and the matching statusline script from your hooks directory.
2. Remove the SessionStart, UserPromptSubmit, and statusLine entries from `settings.json`
3. Delete `.shell-active`
