#!/usr/bin/env node
// shell — SessionStart activation hook
//
// Runs on every session start:
//   1. Writes flag file at $CONFIG_DIR/.shell-active (statusline reads this)
//   2. Emits S.H.E.L.L. ruleset as hidden SessionStart context
//   3. Detects missing statusline config and emits setup nudge

const fs = require('fs');
const path = require('path');
const os = require('os');
const { getDefaultMode, safeWriteFlag, getConfigDir, getEcosystem } = require('./shell-config');

const ecosystem = getEcosystem();
const configDir = getConfigDir(ecosystem);
const flagPath = path.join(configDir, '.shell-active');
const settingsPath = path.join(configDir, 'settings.json');

const mode = getDefaultMode();

// "off" mode — skip activation entirely, don't write flag or emit rules
if (mode === 'off') {
  try { fs.unlinkSync(flagPath); } catch (e) {}
  process.stdout.write('OK');
  process.exit(0);
}

// 1. Write flag file (symlink-safe)
safeWriteFlag(flagPath, mode);

// 2. Emit full S.H.E.L.L. ruleset, filtered to the active intensity level.
//    Reads SKILL.md at runtime so edits to the source of truth propagate
//    automatically — no hardcoded duplication to go stale.

// Modes that have their own independent skill files.
const INDEPENDENT_MODES = new Set(['commit', 'review', 'compress']);

if (INDEPENDENT_MODES.has(mode)) {
  process.stdout.write('S.H.E.L.L. MODE ACTIVE — level: ' + mode + '. Behavior defined by /shell-' + mode + ' skill.');
  process.exit(0);
}

// Read SKILL.md — the single source of truth for S.H.E.L.L. behavior.
let skillContent = '';
try {
  skillContent = fs.readFileSync(
    path.join(__dirname, '..', 'skills', 'shell', 'SKILL.md'), 'utf8'
  );
} catch (e) { /* standalone install — will use fallback below */ }

let output;

if (skillContent) {
  // Strip YAML frontmatter
  const body = skillContent.replace(/^---[\s\S]*?---\s*/, '');

  // Filter intensity table: keep header rows + only the active level's row
  const filtered = body.split('\n').reduce((acc, line) => {
    // Intensity table rows start with | **level** |
    const tableRowMatch = line.match(/^\|\s*\*\*(\S+?)\*\*\s*\|/);
    if (tableRowMatch) {
      if (tableRowMatch[1] === mode) {
        acc.push(line);
      }
      return acc;
    }

    // Example lines start with "- level:" — keep only lines matching active level
    const exampleMatch = line.match(/^- (\S+?):\s/);
    if (exampleMatch) {
      if (exampleMatch[1] === mode) {
        acc.push(line);
      }
      return acc;
    }

    acc.push(line);
    return acc;
  }, []);

  output = 'S.H.E.L.L. MODE ACTIVE — level: ' + mode + '\n\n' + filtered.join('\n');
} else {
  // Fallback when SKILL.md is not found.
  output =
    'S.H.E.L.L. MODE ACTIVE — level: ' + mode + '\n\n' +
    'Respond terse like smart shell. All technical substance stay. Only fluff die.\n\n' +
    '## Persistence\n\n' +
    'ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift. Still active if unsure. Off only: "exit" / "normal mode".\n\n' +
    'Current level: **' + mode + '**. Switch: `/shell verbose|strict|axiomatic|soap`.\n\n' +
    '## Rules\n\n' +
    'Drop: articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course/happy to), hedging. ' +
    'Fragments OK. Short synonyms. Technical terms exact. Code blocks unchanged. Errors quoted exact. ' +
    'Enforce telemetry tags ([WARN], [ERR], [OK]). Omit [INFO] tag.\n\n' +
    'Pattern: `([TELEMETRY]) [thing] [action] [reason]. [next step].`\n\n' +
    'Not: "Sure! I\'d be happy to help you with that. The issue you\'re experiencing is likely caused by..."\n' +
    'Yes: "Bug in auth middleware. Token expiry check use `<` not `<=`. Fix:"\n\n' +
    '## Auto-Clarity\n\n' +
    'Drop S.H.E.L.L. for: security warnings, irreversible action confirmations, multi-step sequences where fragment order risks misread, user asks to clarify or repeats question. Resume S.H.E.L.L. after clear part done.\n\n' +
    '## Boundaries\n\n' +
    'Code/commits/PRs: write normal. "exit" or "normal mode": revert. Level persist until changed or session end.';
}

// 3. Detect missing statusline config — nudge agent to help set it up
try {
  let hasStatusline = false;
  if (fs.existsSync(settingsPath)) {
    const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
    if (settings.statusLine) {
      hasStatusline = true;
    }
  }

  if (!hasStatusline && (ecosystem === 'claude' || ecosystem === 'gemini')) {
    const isWindows = process.platform === 'win32';
    const scriptName = isWindows ? 'shell-statusline.ps1' : 'shell-statusline.sh';
    const scriptPath = path.join(__dirname, scriptName);
    const command = isWindows
      ? `powershell -ExecutionPolicy Bypass -File "${scriptPath}"`
      : `bash "${scriptPath}"`;
    const statusLineSnippet =
      '"statusLine": { "type": "command", "command": ' + JSON.stringify(command) + ' }';
    output += "\n\n" +
      "STATUSLINE SETUP NEEDED: The S.H.E.L.L. plugin includes a statusline badge showing active mode " +
      "(e.g. [S.H.E.L.L.], [S.H.E.L.L.:AXIOMATIC]). It is not configured yet. " +
      "To enable, add this to " + settingsPath + ": " +
      statusLineSnippet + " " +
      "Proactively offer to set this up for the user on first interaction.";
  }
} catch (e) {
  // Silent fail
}

process.stdout.write(output);
