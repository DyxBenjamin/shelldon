#!/usr/bin/env node
// shell — UserPromptSubmit hook to track which S.H.E.L.L. mode is active
// Inspects user input for /shell commands and writes mode to flag file

const fs = require('fs');
const path = require('path');
const os = require('os');
const { getDefaultMode, safeWriteFlag, readFlag, getConfigDir, getEcosystem } = require('./shell-config');

const ecosystem = getEcosystem();
const configDir = getConfigDir(ecosystem);
const flagPath = path.join(configDir, '.shell-active');

let input = '';
process.stdin.on('data', chunk => { input += chunk; });
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const prompt = (data.prompt || '').trim().toLowerCase();

    // Natural language activation
    if (/\b(activate|enable|turn on|start|talk like)\b.*\b(shell|shell)\b/i.test(prompt) ||
        /\b(shell|shell)\b.*\b(mode|activate|enable|turn on|start)\b/i.test(prompt)) {
      if (!/\b(stop|disable|turn off|deactivate)\b/i.test(prompt)) {
        const mode = getDefaultMode();
        if (mode !== 'off') {
          safeWriteFlag(flagPath, mode);
        }
      }
    }

    // Match /shell commands (or $shell for Codex)
    const cmdPrefix = ecosystem === 'codex' ? '$' : '/';
    if (prompt.startsWith(cmdPrefix + 'shell')) {
      const parts = prompt.split(/\s+/);
      const cmd = parts[0]; 
      const arg = parts[1] || '';

      let mode = null;

      if (cmd === cmdPrefix + 'shell-commit') {
        mode = 'commit';
      } else if (cmd === cmdPrefix + 'shell-review') {
        mode = 'review';
      } else if (cmd === cmdPrefix + 'shell-compress') {
        mode = 'compress';
      } else if (cmd === cmdPrefix + 'shell' || cmd === cmdPrefix + 'shell:shell') {
        if (arg === 'verbose') mode = 'verbose';
        else if (arg === 'strict') mode = 'strict';
        else if (arg === 'axiomatic') mode = 'axiomatic';
        else if (arg === 'soap') mode = 'soap';
        else mode = getDefaultMode();
      }

      if (mode && mode !== 'off') {
        safeWriteFlag(flagPath, mode);
      } else if (mode === 'off') {
        try { fs.unlinkSync(flagPath); } catch (e) {}
      }
    }

    // Detect deactivation
    if (/\b(stop|disable|deactivate|turn off)\b.*\b(shell|shell)\b/i.test(prompt) ||
        /\b(shell|shell)\b.*\b(stop|disable|deactivate|turn off)\b/i.test(prompt) ||
        /\bnormal mode\b/i.test(prompt) ||
        prompt === 'exit' || prompt === cmdPrefix + 'exit shell') {
      try { fs.unlinkSync(flagPath); } catch (e) {}
    }

    // Per-turn reinforcement
    const INDEPENDENT_MODES = new Set(['commit', 'review', 'compress']);
    const activeMode = readFlag(flagPath);
    if (activeMode && !INDEPENDENT_MODES.has(activeMode)) {
      process.stdout.write(JSON.stringify({
        hookSpecificOutput: {
          hookEventName: "UserPromptSubmit",
          additionalContext: "S.H.E.L.L. MODE ACTIVE (" + activeMode + "). " +
            "Drop articles/filler/pleasantries/hedging. Fragments OK. " +
            "Enforce telemetry tags ([WARN], [ERR], [OK]). Omit [INFO] tag. " +
            "Code/commits/security: write normal."
        }
      }));
    }
  } catch (e) {
    // Silent fail
  }
});
