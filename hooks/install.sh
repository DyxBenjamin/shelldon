#!/bin/bash
# shell — one-command hook installer for Gemini CLI, Claude Code, and Codex
# Installs: SessionStart hook (auto-load rules) + UserPromptSubmit hook (mode tracking)
# Usage: bash hooks/install.sh
#   or:  bash hooks/install.sh --force   (re-install over existing hooks)
set -e

FORCE=0
for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=1 ;;
  esac
done

# Detect Windows
case "$OSTYPE" in
  msys*|cygwin*|mingw*)
    echo "WARNING: Running on Windows ($OSTYPE)."
    echo ""
    ;;
esac

# Require node
if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: 'node' is required to install the shell hooks (used to merge"
  echo "       the hook config into settings.json safely)."
  echo "       Install Node.js from https://nodejs.org and re-run this script."
  exit 1
fi

if [ -n "$GEMINI_CONFIG_DIR" ]; then
  ECO_DIR="$GEMINI_CONFIG_DIR"
elif [ -n "$CLAUDE_CONFIG_DIR" ]; then
  ECO_DIR="$CLAUDE_CONFIG_DIR"
elif [ -n "$CODEX_CONFIG_DIR" ]; then
  ECO_DIR="$CODEX_CONFIG_DIR"
elif [ -d "$HOME/.gemini" ]; then
  ECO_DIR="$HOME/.gemini"
elif [ -d "$HOME/.claude" ]; then
  ECO_DIR="$HOME/.claude"
elif [ -d "$HOME/.codex" ]; then
  ECO_DIR="$HOME/.codex"
else
  ECO_DIR="$HOME/.gemini" # Default
fi

HOOKS_DIR="$ECO_DIR/hooks"
SETTINGS="$ECO_DIR/settings.json"
REPO_URL="https://raw.githubusercontent.com/JuliusBrussee/shell/main/hooks"

HOOK_FILES=("package.json" "shell-config.js" "shell-activate.js" "shell-mode-tracker.js" "shell-statusline.sh")

# Resolve source
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
fi

# Check if already installed
ALREADY_INSTALLED=0
if [ "$FORCE" -eq 0 ]; then
  ALL_FILES_PRESENT=1
  for hook in "${HOOK_FILES[@]}"; do
    if [ ! -f "$HOOKS_DIR/$hook" ]; then
      ALL_FILES_PRESENT=0
      break
    fi
  done

  HOOKS_WIRED=0
  HAS_STATUSLINE=0
  if [ "$ALL_FILES_PRESENT" -eq 1 ] && [ -f "$SETTINGS" ]; then
    if SHELL_SETTINGS="$SETTINGS" node -e "
      const fs = require('fs');
      const settings = JSON.parse(fs.readFileSync(process.env.SHELL_SETTINGS, 'utf8'));
      const hasS.H.E.L.L.Hook = (event) =>
        Array.isArray(settings.hooks?.[event]) &&
        settings.hooks[event].some(e =>
          e.hooks && e.hooks.some(h => h.command && h.command.includes('shell'))
        );
      process.exit(
        hasS.H.E.L.L.Hook('SessionStart') &&
        hasS.H.E.L.L.Hook('UserPromptSubmit') &&
        !!settings.statusLine
          ? 0
          : 1
      );
    " >/dev/null 2>&1; then
      HOOKS_WIRED=1
      HAS_STATUSLINE=1
    fi
  fi

  if [ "$ALL_FILES_PRESENT" -eq 1 ] && [ "$HOOKS_WIRED" -eq 1 ] && [ "$HAS_STATUSLINE" -eq 1 ]; then
    ALREADY_INSTALLED=1
    echo "S.H.E.L.L. hooks already installed in $HOOKS_DIR"
    echo "  Re-run with --force to overwrite: bash hooks/install.sh --force"
    echo ""
  fi
fi

if [ "$ALREADY_INSTALLED" -eq 1 ] && [ "$FORCE" -eq 0 ]; then
  echo "Nothing to do. Hooks are already in place."
  exit 0
fi

if [ "$FORCE" -eq 1 ] && [ -f "$HOOKS_DIR/shell-activate.js" ]; then
  echo "Reinstalling shell hooks (--force)..."
else
  echo "Installing shell hooks..."
fi

# 1. Ensure hooks dir exists
mkdir -p "$HOOKS_DIR"

# 2. Copy or download hook files
for hook in "${HOOK_FILES[@]}"; do
  if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/$hook" ]; then
    cp "$SCRIPT_DIR/$hook" "$HOOKS_DIR/$hook"
  else
    curl -fsSL "$REPO_URL/$hook" -o "$HOOKS_DIR/$hook"
  fi
  echo "  Installed: $HOOKS_DIR/$hook"
done

# Make statusline script executable
chmod +x "$HOOKS_DIR/shell-statusline.sh"

# 3. Wire hooks + statusline into settings.json (idempotent)
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# Back up existing settings.json
cp "$SETTINGS" "$SETTINGS.bak"

# Pass paths via env vars
SHELL_SETTINGS="$SETTINGS" SHELL_HOOKS_DIR="$HOOKS_DIR" node -e "
  const fs = require('fs');
  const settingsPath = process.env.SHELL_SETTINGS;
  const hooksDir = process.env.SHELL_HOOKS_DIR;
  const managedStatusLinePath = hooksDir + '/shell-statusline.sh';
  const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
  if (!settings.hooks) settings.hooks = {};

  // SessionStart
  if (!settings.hooks.SessionStart) settings.hooks.SessionStart = [];
  const hasStart = settings.hooks.SessionStart.some(e =>
    e.hooks && e.hooks.some(h => h.command && h.command.includes('shell'))
  );
  if (!hasStart) {
    settings.hooks.SessionStart.push({
      hooks: [{
        type: 'command',
        command: 'node \"' + hooksDir + '/shell-activate.js\"',
        timeout: 5,
        statusMessage: 'Loading S.H.E.L.L. mode...'
      }]
    });
  }

  // UserPromptSubmit
  if (!settings.hooks.UserPromptSubmit) settings.hooks.UserPromptSubmit = [];
  const hasPrompt = settings.hooks.UserPromptSubmit.some(e =>
    e.hooks && e.hooks.some(h => h.command && h.command.includes('shell'))
  );
  if (!hasPrompt) {
    settings.hooks.UserPromptSubmit.push({
      hooks: [{
        type: 'command',
        command: 'node \"' + hooksDir + '/shell-mode-tracker.js\"',
        timeout: 5,
        statusMessage: 'Tracking S.H.E.L.L. mode...'
      }]
    });
  }

  // Statusline
  if (!settings.statusLine) {
    settings.statusLine = {
      type: 'command',
      command: 'bash \"' + managedStatusLinePath + '\"'
    };
    console.log('  Statusline badge configured.');
  } else {
    const cmd = typeof settings.statusLine === 'string'
      ? settings.statusLine
      : (settings.statusLine.command || '');
    if (cmd.includes(managedStatusLinePath)) {
      console.log('  Statusline badge already configured.');
    } else {
      console.log('  NOTE: Existing statusline detected — shell badge NOT added.');
      console.log('        See hooks/README.md to add the badge to your existing statusline.');
    }
  }

  fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
  console.log('  Hooks wired in settings.json');
"

echo ""
echo "Done! Restart your agent to activate."
echo ""
echo "What's installed:"
echo "  - SessionStart hook: auto-loads S.H.E.L.L. rules every session"
echo "  - Mode tracker hook: updates statusline badge when you switch modes"
echo "    (/shell strict, /shell axiomatic, /shell-commit, etc.)"
echo "  - Statusline badge: shows [SHELL] or [SHELL:AXIOMATIC] etc."
