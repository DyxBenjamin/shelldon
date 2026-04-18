#!/bin/bash
# shell — uninstaller for the SessionStart + UserPromptSubmit hooks
# Removes: hook files in ~/.gemini/hooks, settings.json entries, and the flag file
# Usage: bash hooks/uninstall.sh
#   or:  bash <(curl -s https://raw.githubusercontent.com/JuliusBrussee/shell/main/hooks/uninstall.sh)
set -e

GEMINI_DIR="${GEMINI_CONFIG_DIR:-$HOME/.gemini}"
HOOKS_DIR="$GEMINI_DIR/hooks"
SETTINGS="$GEMINI_DIR/settings.json"
FLAG_FILE="$GEMINI_DIR/.shell-active"

HOOK_FILES=("package.json" "shell-config.js" "shell-activate.js" "shell-mode-tracker.js" "shell-statusline.sh")

# Detect if shell is installed as a plugin (check plugin cache)
PLUGIN_INSTALLED=0
if [ -d "$GEMINI_DIR/plugins" ]; then
  if find "$GEMINI_DIR/plugins" -path "*/shell*" -name "plugin.json" -print -quit 2>/dev/null | grep -q .; then
    PLUGIN_INSTALLED=1
  fi
fi

if [ "$PLUGIN_INSTALLED" -eq 1 ]; then
  echo "S.H.E.L.L. appears to be installed as a Gemini CLI plugin."
  echo "To uninstall the plugin, use the Gemini CLI extension manager."
  echo ""
  echo "This script removes standalone hooks (installed via install.sh)."
  echo "Continuing with standalone hook removal..."
  echo ""
fi

echo "Uninstalling shell hooks..."

# 1. Remove hook files
REMOVED_FILES=0
for hook in "${HOOK_FILES[@]}"; do
  if [ -f "$HOOKS_DIR/$hook" ]; then
    rm "$HOOKS_DIR/$hook"
    echo "  Removed: $HOOKS_DIR/$hook"
    REMOVED_FILES=$((REMOVED_FILES + 1))
  fi
done

if [ "$REMOVED_FILES" -eq 0 ]; then
  echo "  No hook files found in $HOOKS_DIR"
fi

# 2. Remove shell entries from settings.json (idempotent)
if [ -f "$SETTINGS" ]; then
  # Require node for the same reason install.sh does — safe JSON editing
  if ! command -v node >/dev/null 2>&1; then
    echo "WARNING: 'node' not found — cannot safely edit settings.json."
    echo "         Remove the shell SessionStart and UserPromptSubmit"
    echo "         entries from $SETTINGS manually."
  else
    # Back up before editing, same policy as install.sh
    cp "$SETTINGS" "$SETTINGS.bak"

    # Pass paths via env vars — avoids shell injection if $HOME contains single quotes
    SHELL_SETTINGS="$SETTINGS" SHELL_HOOKS_DIR="$HOOKS_DIR" node -e "
      const fs = require('fs');
      const settingsPath = process.env.SHELL_SETTINGS;
      const hooksDir = process.env.SHELL_HOOKS_DIR;
      const managedStatusLinePath = hooksDir + '/shell-statusline.sh';
      const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));

      const isS.H.E.L.L.Entry = (entry) =>
        entry && entry.hooks && entry.hooks.some(h =>
          h.command && h.command.includes('shell')
        );

      let removed = 0;
      if (settings.hooks) {
        for (const event of ['SessionStart', 'UserPromptSubmit']) {
          if (Array.isArray(settings.hooks[event])) {
            const before = settings.hooks[event].length;
            settings.hooks[event] = settings.hooks[event].filter(e => !isS.H.E.L.L.Entry(e));
            removed += before - settings.hooks[event].length;
            // Drop the event key if it's now empty (keeps settings.json tidy)
            if (settings.hooks[event].length === 0) {
              delete settings.hooks[event];
            }
          }
        }
        // Drop settings.hooks if it's now empty
        if (Object.keys(settings.hooks).length === 0) {
          delete settings.hooks;
        }
      }

      // Remove statusLine if it references shell
      if (settings.statusLine) {
        const cmd = typeof settings.statusLine === 'string'
          ? settings.statusLine
          : (settings.statusLine.command || '');
        if (cmd.includes(managedStatusLinePath)) {
          delete settings.statusLine;
          console.log('  Removed shell statusLine from settings.json');
        }
      }

      fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
      console.log('  Removed ' + removed + ' shell hook entries from settings.json');
    "
  fi
fi

# 3. Clean up backup file left by installer
if [ -f "$SETTINGS.bak" ]; then
  rm "$SETTINGS.bak"
  echo "  Removed: $SETTINGS.bak"
fi

# 4. Remove flag file
if [ -f "$FLAG_FILE" ]; then
  rm "$FLAG_FILE"
  echo "  Removed: $FLAG_FILE"
fi

echo ""
echo "Done! Restart Gemini CLI to complete the uninstall."

# Guidance for other agents
echo ""
echo "Other agents:"
echo "  gemini extensions uninstall shell  # Gemini CLI"
